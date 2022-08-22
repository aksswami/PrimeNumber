import Combine
import SwiftUI
import ComposibleArchitecture
import FavoritePrimes
import Counter

struct AppState {
    var count = 0
    var favoritePrimes: [Int] = []
    var loggedInUser: User?
    var activityFeed: [Activity] = []
    var alertNthPrime: PrimeAlert?
    var isNthPrimeButtonDisabled = false

    struct Activity {
        let timestamp: Date
        let type: ActivityType

        enum ActivityType {
            case addedFavoritePrime(Int)
            case removedFavoritePrime(Int)

            var addedFavoritePrime: Int? {
                get {
                    guard case let .addedFavoritePrime(value) = self else { return nil }
                    return value
                }
                set {
                    guard case .addedFavoritePrime = self, let newValue = newValue else { return }
                    self = .addedFavoritePrime(newValue)
                }
            }

            var removedFavoritePrime: Int? {
                get {
                    guard case let .removedFavoritePrime(value) = self else { return nil }
                    return value
                }
                set {
                    guard case .removedFavoritePrime = self, let newValue = newValue else { return }
                    self = .removedFavoritePrime(newValue)
                }
            }
        }
    }

    struct User {
        let id: Int
        let name: String
        let bio: String
    }
}

enum AppAction {
//    case counter(CounterAction)
//    case primeModal(PrimeModalAction)
    case counterView(CounterViewAction)
    case favoritePrimes(FavoritePrimesAction)

    var counterView: CounterViewAction? {
        get {
            guard case let .counterView(value) = self else { return nil }
            return value
        }
        set {
            guard case .counterView = self, let newValue = newValue else { return }
            self = .counterView(newValue)
        }
    }

    var favoritePrimes: FavoritePrimesAction? {
        get {
            guard case let .favoritePrimes(value) = self else { return nil }
            return value
        }
        set {
            guard case .favoritePrimes = self, let newValue = newValue else { return }
            self = .favoritePrimes(newValue)
        }
    }
}

func activityFeed(
    _ reducer: @escaping Reducer<AppState, AppAction>
) -> Reducer<AppState, AppAction> {
    return { state, action in
        switch action {
        case .counterView(.counter),
            .favoritePrimes(.loadedFavoritePrimes),
            .favoritePrimes(.saveButtonTapped),
            .favoritePrimes(.loadButtonTapped):
//                .counterView(.primeModal(.checkPrime)),
//                .counterView(.primeModal(.isPrime)):
            break
        case .counterView(.primeModal(.removeFavoritePrimeTapped)):
            state.activityFeed.append(.init(timestamp: Date(), type: .removedFavoritePrime(state.count)))

        case .counterView(.primeModal(.saveFavoritePrimeTapped)):
            state.activityFeed.append(.init(timestamp: Date(), type: .addedFavoritePrime(state.count)))

        case let .favoritePrimes(.deleteFavoritePrimes(indexSet)):
            for index in indexSet {
                state.activityFeed.append(.init(timestamp: Date(), type: .removedFavoritePrime(state.favoritePrimes[index])))
            }
        }

        return reducer(&state, action)
    }
}


// swiftlint:disable type_name
struct _KeyPath<Root, Value> {
    let get: (Root) -> Value
    let set: (inout Root, Value) -> Void
}

struct EnumKeyPath<Root, Value> {
    let embed: (Value) -> Root
    let extract: (Root) -> Value?
}

extension AppState {
    var counterView: CounterViewState {
        get {
            CounterViewState(
                alertNthPrime: alertNthPrime,
                count: count,
                favoritePrimes: favoritePrimes,
                isNthPrimeButtonDisabled: isNthPrimeButtonDisabled
            )
        }
        set {
            self.alertNthPrime = newValue.alertNthPrime
            count = newValue.count
            favoritePrimes = newValue.favoritePrimes
            isNthPrimeButtonDisabled = newValue.isNthPrimeButtonDisabled
        }
    }
}


let appReducer: Reducer<AppState, AppAction> = combine(
    pullback(counterViewReducer, value: \.counterView, action: \.counterView),
    pullback(favoritePrimesReducer, value: \.favoritePrimes, action: \.favoritePrimes)
)
// let appReducer: Reducer<AppState, AppAction> = pullback(_appReducer, value: \.self, action: \.self)

struct ContentView: View {
    @ObservedObject var store: Store<AppState, AppAction>

    var body: some View {
        NavigationView {
            List {
                NavigationLink(
                    "Counter demo",
                    destination: CounterView(
                        store: self.store
                            .view(
                                value: { $0.counterView },
                                action: { AppAction.counterView($0) }
                            )
                    )
                )
                NavigationLink(
                    "Favorite primes",
                    destination: FavoritePrimesView(
                        store: self.store
                            .view(
                                value: { $0.favoritePrimes },
                                action: { .favoritePrimes($0) }
                            )
                    )
                )
            }
            .navigationTitle("State management")
        }
    }
}
