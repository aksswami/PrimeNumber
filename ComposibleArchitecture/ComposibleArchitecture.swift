//
//  ComposbileArchitecture.swift
//  ComposibleArchitecture
//
//  Created by Amit Kumar Swami on 16/8/22.
//

import Foundation
import SwiftUI
import Combine

struct Parallel<A> {
    let run: (@escaping (A) -> Void) -> Void
}
//public typealias Effect<Action> = (@escaping (Action) -> Void) -> Void


//public struct Effect<A> {
//    public let run: (@escaping (A) -> Void) -> Void
//
//    public init(run: @escaping (@escaping (A) -> Void) -> Void) {
//        self.run = run
//    }
//
//    public func map<B>(_ f: @escaping (A) -> B) -> Effect<B> {
//        return Effect<B>(run: { callback in self.run { a in callback(f(a)) }})
//    }
//}

public struct Effect<Output>: Publisher {
    public typealias Failure = Never
    
    let publisher: AnyPublisher<Output, Failure>
    
    public func receive<S>(
        subscriber: S
    ) where S : Subscriber, Never == S.Failure, Output == S.Input {
        publisher.receive(subscriber: subscriber)
    }
}

extension Publisher where Failure == Never {
    public func eraseToEffect() -> Effect<Output> {
        return Effect(publisher: self.eraseToAnyPublisher())
    }
}

public typealias Reducer<Value, Action> = (inout Value, Action) -> [Effect<Action>]

public final class Store<Value, Action>: ObservableObject {
    private let reducer: Reducer<Value, Action>
    @Published public private(set) var value: Value
    private var viewCancellable: Cancellable?
    private var effectCancellables: Set<AnyCancellable> = []
    
    public init(initialValue: Value, reducer: @escaping Reducer<Value, Action>) {
        self.reducer = reducer
        self.value = initialValue
    }
    
    public func send(_ action: Action) {
        let effects = self.reducer(&self.value, action)
        effects.forEach { effect in
            var effectCancellable: AnyCancellable?
            var didComplete = false
            effectCancellable = effect.sink(
                receiveCompletion: { [weak self] _ in
                    didComplete = true
                    guard let effectCancellable = effectCancellable else {
                        return
                    }
                    self?.effectCancellables.remove(effectCancellable)
                },
                receiveValue: self.send
            )
            if !didComplete, let effectCancellable = effectCancellable {
                self.effectCancellables.insert(effectCancellable)
            }
        }
//        DispatchQueue.global().async {
//            effects.forEach { effect in
//                guard let action = effect() else {
//                    return
//                }
//                DispatchQueue.main.async {
//                    self.send(action)
//                }
//            }
//        }
    }
    
    // ((Value) -> LocalValue) -> (Store<Value, _>) -> Store<LocalValue, _>
    // ((A) -> B) -> (Store<A,_>) -> Store<B, _>
    // map: ((A) -> B) -> (F<A>) -> F<B>
    
    
    public func view<LocalValue, LocalAction>(
        value toLocalValue: @escaping (Value) -> LocalValue,
        action toGlobalAction: @escaping (LocalAction) -> Action
    ) -> Store<LocalValue, LocalAction> {
        let localStore = Store<LocalValue, LocalAction>(
            initialValue: toLocalValue(value)) { localValue, localAction in
                self.send(toGlobalAction(localAction))
                localValue = toLocalValue(self.value)
                return []
            }
        localStore.viewCancellable = self.$value.sink { [weak localStore] newValue in
            localStore?.value = toLocalValue(newValue)
        }
        
        return localStore
    }
    
    
    // ((LocalAction) -> Action) -> (Store<_, Action>) -> Store<_, LocalAction>
    // ((B) -> A) -> (Store<_, A>) -> Store<_, B>
    // ((B) -> A) -> (F<A>) -> F<B>
    
    //    func view<LocalAction>(
    //        _ f: @escaping (LocalAction) -> Action
    //    ) -> Store<Value, LocalAction> {
    //        return Store<Value, LocalAction>(
    //            initialValue: value,
    //            reducer: { value, localAction in
    //                self.send(f(localAction))
    //                value = self.value
    //            })
    //    }
}


func transform<A, B, Action>(
    _ reducer: (A, Action) -> A,
    _ f: (A) -> B
) -> (B, Action) -> B {
    fatalError()
}


public func combine<Value, Action>(
    _ reducers: Reducer<Value, Action>...
) -> Reducer<Value, Action> {
    return { value, action in
        return reducers.flatMap { $0(&value, action) }
    }
}

public func pullback<LocalValue, GlobalValue, LocalAction, GlobalAction>(
    _ reducer: @escaping Reducer<LocalValue, LocalAction>,
    value: WritableKeyPath<GlobalValue, LocalValue>,
    action: WritableKeyPath<GlobalAction, LocalAction?>
) -> Reducer<GlobalValue, GlobalAction> {
    return { globalValue, globalAction -> [Effect<GlobalAction>] in
        guard let localAction = globalAction[keyPath: action] else { return [] }
        let localEffects = reducer(&globalValue[keyPath: value], localAction)
        
        return localEffects.map { localEffect in
            localEffect
                .map { localAction -> GlobalAction in
                    var globalAction = globalAction
                    globalAction[keyPath: action] = localAction
                    return globalAction
                }
                .eraseToEffect()
//            Effect { callback in
//                let cancel = localEffect.sink { localAction in
//                    var globalAction = globalAction
//                    globalAction[keyPath: action] = localAction
//                    callback(globalAction)
//                }
//            }
        }
    }
}

public func logging<Value, Action>(
    _ reducer: @escaping Reducer<Value, Action>
) -> Reducer<Value, Action> {
    return { value, action in
        let effects = reducer(&value, action)
        let newValue = value
        return [
            .fireAndForget {
                print("Action: \(action)")
                print("Value:")
                dump(newValue)
                print("---")
            }
        ] + effects
    }
}


extension Effect {
    public static func fireAndForget(work: @escaping () -> Void) -> Effect {
        return Deferred { () -> Empty<Output, Never> in
            work()
            return Empty(completeImmediately: true)
        }.eraseToEffect()
    }
}

extension Effect {
    public static func sync(work: @escaping () -> Output) -> Effect {
        return Deferred {
            Just(work())
        }
        .eraseToEffect()
    }
}

// (Never) -> A
extension Publisher where Output == Never, Failure == Never {
    public func fireAndForget<A>() -> Effect<A> {
        return self.map(absurd).eraseToEffect()
    }
}
func absurd<A>(_ never: Never) -> A {}
