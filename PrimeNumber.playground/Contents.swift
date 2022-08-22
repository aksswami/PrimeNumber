//import ComposibleArchitecture
//import FavoritePrimes
//import PrimeModal
//import Counter
import SwiftUI
import PlaygroundSupport

public struct Effect<A> {
    public let run: (@escaping (A) -> Void) -> Void
    
    public init(run: @escaping (@escaping (A) -> Void) -> Void) {
        self.run = run
    }
    
    public func map<B>(_ f: @escaping (A) -> B) -> Effect<B> {
        return Effect<B>(run: { callback in self.run { a in callback(f(a)) }})
    }
}

public class EagarEffect<A> {
    public var value: A?
    var callbacks: [(A) -> Void] = []
    var lock = os_unfair_lock()
    
    init(run: @escaping ((A) -> Void) -> Void) {
        run { value in
            let callbacks: [(A) -> Void]
            os_unfair_lock_lock(&self.lock)
            callbacks = self.callbacks
            self.value = value
            os_unfair_lock_unlock(&self.lock)
            callbacks.forEach { $0(value) }
        }
    }
    
    func run(_ callback: @escaping (A) -> Void) {
        let value: A?
        os_unfair_lock_lock(&self.lock)
        if let aValue = self.value {
            value = aValue
        } else {
            value = nil
        }
        self.callbacks.append(callback)
        os_unfair_lock_unlock(&self.lock)
        if let value = value {
            callback(value)
        }
    }
}

let effect = EagarEffect<Int> { callback in
    print(41)
    callback(41)
}

effect.run { value in
    print(value)
}



import Dispatch
import Combine

let aIntInTwoSeconds = Effect<Int> { callback in
    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
        callback(42)
    }
}

//aIntInTwoSeconds.run { int in print(int) }

//aIntInTwoSeconds.map { $0 * $0 }.run { int in print(int) }

//Publishers.ini
//AnyPublisher.init
var count = 0
let iterator = AnyIterator<Int> {
    count += 1
    return count
}

//Array(iterator.prefix(10))

let aFutureInt = Deferred {
    Future<Int, Never> { callback in
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            print("Hello from the future")
            callback(.success(42))
        }
    }
}

//aFutureInt.subscribe(AnySubscriber<Int, Never>(
//    receiveSubscription: { subscription in
//        print("subscription")
//        subscription.request(Subscribers.Demand.unlimited)
//    },
//    receiveValue: { value in
//        print("value", value)
//        return .unlimited
//    },
//    receiveCompletion: { completed in
//        print("Completion", completed)
//    }) )
//
//let cancellable = aFutureInt.sink { int in
//    print(int)
//}
//cancellable.cancel()

let passThrough = PassthroughSubject<Int, Never>.init()
let currentValue = CurrentValueSubject<Int, Never>.init(2)
let c1 = passThrough.sink { x in
    print("passthrough x", x)
}

let c2 = currentValue.sink { x in
    print("currentValue x", x)
}
passThrough.send(42)
currentValue.send(42)
passThrough.send(1729)
currentValue.send(42)

//aFutureInt.sink { int in
//    print(int)
//}

// 1. Publishers
// 2. Subscribers




/*
 1. State
 2. Mutate state
 3. Break into small modules
 4. Side effects
 5. Testing
 */
//PlaygroundPage.current.setLiveView(
//    CounterView(
//        store: Store<CounterViewState, CounterViewAction>(
//            initialValue: (5, [1, 2]),
//            reducer: counterViewReducer)))

//PlaygroundPage.current.setLiveView(
//    NavigationView {
//        FavoritePrimesView(
//            store: Store<[Int], FavoritePrimesAction>(
//                initialValue: [2, 5],
//                reducer: favoritePrimesReducer))
//    })
//let store = Store<Int, Void>(initialValue: 0) { count, _ in
//    count += 1
//}
//
//store.send(())
//store.send(())
//store.send(())
//store.send(())
//store.send(())
//store.send(())
//
//store.value
//
//let newStore = store.view { $0 }
//
//newStore.value
//
//newStore.send(())
//newStore.send(())
//newStore.send(())
//newStore.send(())
//newStore.send(())
//
//newStore.value
//store.value
//
//
//store.send(())
//store.send(())
//
//
//newStore.value
//store.value
//
//var xs = [1, 2, 4]
//var ys = xs.map { $0 }
//
//ys.append(5)
//
//xs
//ys
