//
//  PrimeNumberApp.swift
//  Shared
//
//  Created by Amit Kumar Swami on 16/8/22.
//

import SwiftUI
import ComposibleArchitecture
//import Counter
@main
struct PrimeNumberApp: App {
    var body: some Scene {
        WindowGroup {
//            NavigationView {
//                CounterView(
//                    store: Store<CounterViewState, CounterViewAction>(
//                        initialValue: CounterViewState(
//                            alertNthPrime: nil,
//                            count: 0,
//                            favoritePrimes: [],
//                            isNthPrimeButtonDisabled: false
//                        ),
//                        reducer: logging(counterViewReducer)
//                    )
//                )
//            }
            ContentView(
                store: Store(
                    initialValue: AppState(),
                    //      reducer: logging(activityFeed(appReducer))
                    reducer:
//                        with(
                        appReducer
//                        compose(
//                            logging,
//                            activityFeed
//                        )
//                    )
                )
            )
        }
    }
}
