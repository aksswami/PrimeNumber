////
////  Effects.swift
////  ComposibleArchitecture
////
////  Created by Amit Kumar Swami on 18/8/22.
////
//
//import Foundation
//
//extension Effect where A == (Data?, URLResponse?, Error?) {
//    public func decode<M: Decodable>(as type: M.Type) -> Effect<M?> {
//        self.map { data, _, _ in
//            data
//                .flatMap { try? JSONDecoder().decode(M.self, from: $0) }
//        }
//    }
//}
//
//extension Effect {
//    public func receive(on queue: DispatchQueue) -> Effect {
//        return Effect { callback in
//            self.run { a in
//                queue.async {
//                    callback(a)
//                }
//            }
//        }
//    }
//}
//
//extension Effect {
//    public func run(on queue: DispatchQueue) -> Effect {
//        return Effect { callback in
//            queue.async {
//                self.run(callback)
//            }
//        }
//    }
//}
//
//private var effectStatus: [String: Bool] = [:]
//extension Effect {
//    func cancellable(id: String) -> Effect {
//        return Effect { callback in
//            if effectStatus[id] ?? false {
//                self.run(callback)
//            } else {
//                return
//            }
//        }
//    }
//}
//
//public func dataTask(with url: URL) -> Effect<(Data?, URLResponse?, Error?)> {
//    return Effect { callback in
//        URLSession.shared.dataTask(with: url) { data, response, error in
//            callback((data, response, error))
//        }.resume()
//    }
//}
