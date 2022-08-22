//: A UIKit based Playground for presenting user interface

import UIKit
import PlaygroundSupport
@testable import FavoritePrimes
import SwiftUI
import ComposibleArchitecture

Current = .mock

Current.fileClient.load = { _ in
    Effect.sync {
        try! JSONEncoder().encode(Array(1...1000))
    }
}
PlaygroundPage.current.setLiveView(
    NavigationView {
        FavoritePrimesView(
            store: Store<[Int], FavoritePrimesAction>(
                initialValue: [2, 3, 5, 7, 11],
                reducer: logging(favoritePrimesReducer)
            )
        )
    }
)
