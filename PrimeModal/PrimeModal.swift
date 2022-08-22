//
//  PrimeModal.swift
//  PrimeModal
//
//  Created by Amit Kumar Swami on 16/8/22.
//

import Foundation
import SwiftUI
import ComposibleArchitecture

//public typealias PrimeModalState = (count: Int, favoritePrimes: [Int], isPrime: Bool?)
public struct PrimeModalState: Equatable {
    public var count: Int
    public var favoritePrimes: [Int] = []
//    public var isPrime: Bool? = nil

    public init(
        count: Int,
        favoritePrimes: [Int]) {
        self.count = count
        self.favoritePrimes = favoritePrimes
//        self.isPrime = isPrime
    }
}

public func primeModalReducer(state: inout PrimeModalState, action: PrimeModalAction) -> [Effect<PrimeModalAction>] {
    switch action {
    case .removeFavoritePrimeTapped:
        state.favoritePrimes.removeAll(where: { $0 == state.count })
        return []
        
    case .saveFavoritePrimeTapped:
        state.favoritePrimes.append(state.count)
        return []
        
//    case .checkPrime:
//        return [
////            isPrime(state.count)
////            .map(PrimeModalAction.isPrime)
////            .eraseToEffect()
//        ]
//    case let .isPrime(prime):
//        state.isPrime = prime
//        return []
    }
}


public enum PrimeModalAction {
    case saveFavoritePrimeTapped
    case removeFavoritePrimeTapped
//    case checkPrime
//    case isPrime(Bool)
}

public struct IsPrimeModalView: View {
    @ObservedObject var store: Store<PrimeModalState, PrimeModalAction>
    
    public init(store: Store<PrimeModalState, PrimeModalAction>) {
        self.store = store
    }
    
    public var body: some View {
        VStack {
//            if let isPrime = self.store.value.isPrime {
                if isPrime(self.store.value.count) {
                    Text("\(self.store.value.count) is prime 🎉")
                    if self.store.value.favoritePrimes.contains(self.store.value.count) {
                        Button("Remove from favorite primes") {
                            self.store.send(.removeFavoritePrimeTapped)
                        }
                    } else {
                        Button("Save to favorite primes") {
                            self.store.send(.saveFavoritePrimeTapped)
                        }
                    }
                } else {
                    Text("\(self.store.value.count) is not prime :(")
                }
//            } else {
//                ProgressView()
//            }
        }
//        .onAppear{ self.store.send(.checkPrime) }
    }
}


private func isPrime (_ p: Int) -> Bool {
//    Effect { callback in
        if p <= 1 { return false }
        if p <= 3 { return true }
        for i in 2...Int(sqrtf(Float(p))) {
            if p % i == 0 { return false }
        }
        return true
//    }
//    .run(on: .global(qos: .background))
//    .receive(on: .main)
}


//private func isPrime (_ p: Int) -> Effect<Bool> {
//    Effect { callback in
//        if p <= 1 { return callback(false) }
//        if p <= 3 { return callback(true) }
//        for i in 2...Int(sqrtf(Float(p))) {
//            if p % i == 0 { return callback(false) }
//        }
//        return callback(true)
//    }
//    .run(on: .global(qos: .background))
//    .receive(on: .main)
//}
