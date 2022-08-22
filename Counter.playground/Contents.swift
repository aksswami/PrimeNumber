//: A UIKit based Playground for presenting user interface

import UIKit
import PlaygroundSupport
@testable import Counter
import SwiftUI
import ComposibleArchitecture

Current = .mock
Current.nthPrime = { _ in
        .sync { 121342312313 }
}

PlaygroundPage.current.setLiveView(
    NavigationView {
        CounterView(
            store: Store<CounterViewState, CounterViewAction>(
                initialValue: CounterViewState(
                    alertNthPrime: nil,
                    count: 21_111_111_111_113,
                    favoritePrimes: [],
                    isNthPrimeButtonDisabled: false
                ),
                reducer: logging(counterViewReducer)
            )
        )
    }
)
