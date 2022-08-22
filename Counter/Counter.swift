//
//  Counter.swift
//  Counter
//
//  Created by Amit Kumar Swami on 16/8/22.
//

import Foundation
import SwiftUI
import ComposibleArchitecture
import PrimeModal
import Combine

public typealias CounterState = (
    alertNthPrime: PrimeAlert?,
    count: Int,
    isNthPrimeButtonDisabled: Bool
//    isPrime: Bool?
)

public func counterReducer(state: inout CounterState, action: CounterAction) -> [Effect<CounterAction>] {
    switch action {
    case .decrTapped:
        state.count -= 1
//        state.isPrime = nil
        return []

    case .incrTapped:
        state.count += 1
//        state.isPrime = nil
        return []

    case .nthPrimeButtonTapped:
        state.isNthPrimeButtonDisabled = true
        return [
//            nthPrime(state.count)
            Current.nthPrime(state.count)
            .map(CounterAction.nthPrimeResponse)
            .receive(on: DispatchQueue.main)
            .eraseToEffect()
        ]
    case let .nthPrimeResponse(prime):
        state.alertNthPrime = prime.map(PrimeAlert.init(prime:))
        state.isNthPrimeButtonDisabled = false
        return []

    case .alertDismissButtonTapped:
        state.alertNthPrime = nil
        return []
    }
}

public enum CounterAction: Equatable {
    case decrTapped
    case incrTapped
    case nthPrimeButtonTapped
    case nthPrimeResponse(Int?)
    case alertDismissButtonTapped
}

public struct PrimeAlert: Identifiable, Equatable {
    let prime: Int
    public var id: Int { self.prime }
}

func ordinal(_ n: Int) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .ordinal
    return formatter.string(for: n) ?? ""
}

public let counterViewReducer: Reducer<CounterViewState, CounterViewAction> = combine(
    pullback(counterReducer, value: \.counter, action: \.counter),
    pullback(primeModalReducer, value: \.primeModal, action: \.primeModal)
)

struct CounterEnvironment {
    var nthPrime: (Int) -> Effect<Int?>
}

extension CounterEnvironment {
    static let live = CounterEnvironment(nthPrime: Counter.nthPrime)
}
// swiftlint:disable identifier_name 
var Current = CounterEnvironment.live

#if DEBUG
extension CounterEnvironment {
    static let mock = CounterEnvironment(nthPrime: { _ in
            .sync { 17 }
    })
}
#endif

public struct CounterViewState: Equatable {
    public var alertNthPrime: PrimeAlert?
    public var count: Int
    public var favoritePrimes: [Int]
    public var isNthPrimeButtonDisabled: Bool
//    public var isPrime: Bool? = nil

    public init(
        alertNthPrime: PrimeAlert? = nil,
        count: Int = 0,
        favoritePrimes: [Int] = [],
        isNthPrimeButtonDisabled: Bool = false
    ) {
        self.alertNthPrime = alertNthPrime
        self.count = count
        self.favoritePrimes = favoritePrimes
        self.isNthPrimeButtonDisabled = isNthPrimeButtonDisabled
    }

    var counter: CounterState {
        get { (self.alertNthPrime, self.count, self.isNthPrimeButtonDisabled) }
        set { (self.alertNthPrime, self.count, self.isNthPrimeButtonDisabled) = newValue }
    }

    var primeModal: PrimeModalState {
        get { PrimeModalState(count: self.count, favoritePrimes: self.favoritePrimes) }
        set { (self.count, self.favoritePrimes) = (newValue.count, newValue.favoritePrimes) }
    }
}

public enum CounterViewAction: Equatable {
    case counter(CounterAction)
    case primeModal(PrimeModalAction)

    var counter: CounterAction? {
        get {
            guard case let .counter(value) = self else { return nil }
            return value
        }
        set {
            guard case .counter = self, let newValue = newValue else { return }
            self = .counter(newValue)
        }
    }

    var primeModal: PrimeModalAction? {
        get {
            guard case let .primeModal(value) = self else { return nil }
            return value
        }
        set {
            guard case .primeModal = self, let newValue = newValue else { return }
            self = .primeModal(newValue)
        }
    }
}
public struct CounterView: View {
    @ObservedObject var store: Store<CounterViewState, CounterViewAction>
    @State var isPrimeModalShown = false
    //    @State var alertNthPrime: PrimeAlert?
    //    @State var isNthPrimeButtonDisabled = false

    public init(store: Store<CounterViewState, CounterViewAction>) {
        self.store = store
    }

    public var body: some View {
        VStack {
            HStack {
                Button("-") { self.store.send(.counter(.decrTapped)) }
                Text("\(self.store.value.count)")
                Button("+") { self.store.send(.counter(.incrTapped)) }
            }
            Button("Is this prime?") { self.isPrimeModalShown = true }
            Button(
                "What is the \(ordinal(self.store.value.count)) prime?",
                action: self.nthPrimeButtonAction
            )
            .disabled(store.value.isNthPrimeButtonDisabled)
        }
        .font(.title)
        .navigationTitle("Counter demo")
        .sheet(isPresented: self.$isPrimeModalShown) {
            IsPrimeModalView(
                store: self.store.view(
                    value: { PrimeModalState(
                        count: $0.count,
                        favoritePrimes: $0.favoritePrimes
//                        isPrime: $0.isPrime
                    )
                    },
                    action: { .primeModal($0) }
                )
            )
        }
        .alert(
            item: .constant(store.value.alertNthPrime)
        ) { alert in
            Alert(
                title: Text("The \(ordinal(self.store.value.count)) prime is \(alert.prime)"),
                dismissButton: .default(Text("Ok")) {
                    self.store.send(.counter(.alertDismissButtonTapped))
                }
            )
        }
    }

    func nthPrimeButtonAction() {
        self.store.send(.counter(.nthPrimeButtonTapped))
        //        self.isNthPrimeButtonDisabled = true
        //        nthPrime(self.store.value.count) { prime in
        //            self.alertNthPrime = prime.map(PrimeAlert.init(prime:))
        //            self.isNthPrimeButtonDisabled = false
        //        }
    }
}
