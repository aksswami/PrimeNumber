//
//  CounterTests.swift
//  CounterTests
//
//  Created by Amit Kumar Swami on 16/8/22.
//

import XCTest
@testable import Counter

class CounterTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        Current = .mock
    }

    func testIncrAndDecrTapped() throws {
        assert(
            initialValue: CounterViewState(count: 2),
            reducer: counterViewReducer,
            steps:
                Step(.send, .counter(.incrTapped)) { state in state.count = 3 },
            Step(.send, .counter(.incrTapped)) { state in state.count = 4 },
            Step(.send, .counter(.decrTapped)) { state in state.count = 3 }
        )
    }
    
    func testNthPrimeButtonHappyFlow() throws {
        Current.nthPrime = { _ in
                .sync { 17 }
        }
        
        assert(
            initialValue: CounterViewState(
                alertNthPrime: nil,
                isNthPrimeButtonDisabled: false
            ),
            reducer: counterViewReducer,
            steps:
                Step(.send, .counter(.nthPrimeButtonTapped)) {
                    $0.isNthPrimeButtonDisabled = true
                },
            Step(.receive, .counter(.nthPrimeResponse(17))) {
                $0.alertNthPrime = PrimeAlert(prime: 17)
                $0.isNthPrimeButtonDisabled = false
            },
            Step(.send, .counter(.alertDismissButtonTapped)) {
                $0.alertNthPrime = nil
            }
        )
    }
    
    
    func testNthPrimeButtonUnhappyFlow() throws {
        Current.nthPrime = { _ in .sync { nil }}
        
        assert(
            initialValue: CounterViewState(
                alertNthPrime: nil,
                isNthPrimeButtonDisabled: false
            ),
            reducer: counterViewReducer,
            steps:
                Step(.send, .counter(.nthPrimeButtonTapped)) {
                    $0.isNthPrimeButtonDisabled = true
                },
            Step(.receive, .counter(.nthPrimeResponse(nil))) {
                $0.isNthPrimeButtonDisabled = false
            }
        )
    }
    
    func testPrimeModal() throws {
        assert(
            initialValue: CounterViewState(
                count: 2,
                favoritePrimes: [3, 5]
            ),
            reducer: counterViewReducer,
            steps:
                Step(.send,  .primeModal(.saveFavoritePrimeTapped)) { $0.favoritePrimes = [3, 5, 2] },
            Step(.send,  .primeModal(.removeFavoritePrimeTapped)) { $0.favoritePrimes = [3, 5] }
        )
    }
}
