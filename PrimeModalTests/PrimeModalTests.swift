//
//  PrimeModalTests.swift
//  PrimeModalTests
//
//  Created by Amit Kumar Swami on 16/8/22.
//

import XCTest
@testable import PrimeModal

class PrimeModalTests: XCTestCase {
    
    func testSaveFavoritePrimesTapped() throws {
        var state = PrimeModalState(count: 2, favoritePrimes: [3, 5])
        let effects = primeModalReducer(
            state: &state,
            action: .saveFavoritePrimeTapped)
        XCTAssertEqual(state, PrimeModalState(count: 2, favoritePrimes: [3, 5, 2]))
        XCTAssert(effects.isEmpty)
    }
    
    func testDeleteFavoritePrimesTapped() throws {
        var state = PrimeModalState(count: 3, favoritePrimes: [3, 5])
        let effects = primeModalReducer(
            state: &state,
            action: .removeFavoritePrimeTapped)
        XCTAssertEqual(state, PrimeModalState(count: 3, favoritePrimes: [5]))
        XCTAssert(effects.isEmpty)
    }
}
