//
//  FavoritePrimes.swift
//  FavoritePrimes
//
//  Created by Amit Kumar Swami on 16/8/22.
//

import Foundation
import SwiftUI
import ComposibleArchitecture
import Combine

public func favoritePrimesReducer(state: inout [Int], action: FavoritePrimesAction) -> [Effect<FavoritePrimesAction>] {
    switch action {
    case let .deleteFavoritePrimes(indexSet):
        for index in indexSet {
            state.remove(at: index)
        }
        return []
        
    case let .loadedFavoritePrimes(primes):
        state = primes
        return []
        
    case .saveButtonTapped:
        return [
            Current.fileClient
                .save("favorite-prime.json", try! JSONEncoder().encode(state))
                .fireAndForget()
        ]
//            saveEffect(favoritePrimes: state)]
        
    case .loadButtonTapped:
        return [
            Current.fileClient
                .load("favorite-prime.json")
                .compactMap { $0 }
                .decode(type: [Int].self, decoder: JSONDecoder())
                .catch { error in Empty(completeImmediately: true) }
                .map(FavoritePrimesAction.loadedFavoritePrimes)
                .eraseToEffect()
        ]
    }
}

//private func saveEffect(favoritePrimes: [Int]) -> Effect<FavoritePrimesAction> {
//    return .fireAndForget {
//        let data = try! JSONEncoder().encode(favoritePrimes)
//        let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
//        let documentURL = URL(fileURLWithPath: documentPath)
//        let favoritePrimeURL = documentURL.appendingPathComponent("favorite-prime.json")
//        try! data.write(to: favoritePrimeURL)
//    }
//}


struct FileClient {
    var load: (String) -> Effect<Data?>
    var save: (String, Data) -> Effect<Never>
}

extension FileClient {
    static let live = FileClient(
        load: { filename -> Effect<Data?> in
            Effect<Data?>.sync {
                let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
                let documentURL = URL(fileURLWithPath: documentPath)
                let favoritePrimeURL = documentURL.appendingPathComponent(filename)
                return try? Data(contentsOf: favoritePrimeURL)
            }
            
        }, save: { filename, data in
            return .fireAndForget {
                let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
                let documentURL = URL(fileURLWithPath: documentPath)
                let favoritePrimeURL = documentURL.appendingPathComponent(filename)
                try! data.write(to: favoritePrimeURL)
            }
        })
}

struct FavoritePrimesEnvironment {
    var fileClient: FileClient
}

extension FavoritePrimesEnvironment {
    static let live = FavoritePrimesEnvironment(fileClient: .live)
}

var Current = FavoritePrimesEnvironment.live

#if DEBUG
extension FavoritePrimesEnvironment {
    static let mock = FavoritePrimesEnvironment(
        fileClient: FileClient(
            load: { _ in Effect<Data?>.sync {
                try! JSONEncoder().encode([2, 31])
            }},
            save: { _, _ in .fireAndForget {}}
        )
    )
}
#endif
//struct Environment {
//    var date: () -> Date
//}
//
//extension Environment {
//    static let live = Environment(date: Date.init)
//}
//
//extension Environment {
//    static let mock = Environment(date: { Date.init(timeIntervalSince1970: 1234567890) })
//}
//
//#if DEBUG
//var Current = Environment.live
//#else
//let Current = Environment.live
//#endif

//private let loadEffect = Effect<FavoritePrimesAction?>.sync {
//
//    let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
//    let documentURL = URL(fileURLWithPath: documentPath)
//    let favoritePrimeURL = documentURL.appendingPathComponent("favorite-prime.json")
//    guard let data = try? Data(contentsOf: favoritePrimeURL),
//          let favoritePrimes = try? JSONDecoder().decode([Int].self, from: data)
//    else { return nil }
//    return FavoritePrimesAction.loadedFavoritePrimes(favoritePrimes)
//}

public enum FavoritePrimesAction: Equatable {
    case deleteFavoritePrimes(IndexSet)
    case loadedFavoritePrimes([Int])
    case saveButtonTapped
    case loadButtonTapped
    
    var deleteFavoritePrimes: IndexSet? {
        get {
            guard case let .deleteFavoritePrimes(value) = self else { return nil }
            return value
        }
        set {
            guard case .deleteFavoritePrimes = self, let newValue = newValue else { return }
            self = .deleteFavoritePrimes(newValue)
        }
    }
    
    var loadedFavoritePrimes: [Int]? {
        get {
            guard case let .loadedFavoritePrimes(value) = self else { return nil }
            return value
        }
        set {
            guard case .loadedFavoritePrimes = self, let newValue = newValue else { return }
            self = .loadedFavoritePrimes(newValue)
        }
    }
}

public struct FavoritePrimesView: View {
    @ObservedObject var store: Store<[Int], FavoritePrimesAction>
    
    public init(store: Store<[Int], FavoritePrimesAction>) {
        self.store = store
    }
    
    public var body: some View {
        List {
            ForEach(self.store.value, id: \.self) { prime in
                Text("\(prime)")
            }
            .onDelete { indexSet in
                self.store.send(.deleteFavoritePrimes(indexSet))
            }
        }
        .navigationBarTitle("Favorite Primes")
        .toolbar {
            HStack {
                Button("Save") {
                    self.store.send(.saveButtonTapped)
                }
                
                Button("Load") {
                    self.store.send(.loadButtonTapped)
                }
            }
        }
    }
}


func compute(_ x: Int) -> (Int, [String]) {
    let computation = x * x + 1
    return (computation, ["Computed \(computation)"])
}
