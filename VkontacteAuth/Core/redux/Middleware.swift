//
//  Middleware.swift
//  VkontacteAuth
//
//  Created by Николай Казанин on 07.07.2022.
//

import Combine

typealias Middleware<State, Action> = (State, Action) -> AnyPublisher<Action, Never>

enum Middlewares {
    static let loggerMiddleware: Middleware<AppState, AppActions> = { state, action in
        print("-------")
        print("«\(action)» action dispatched")
        print("New state: \(state)")
        print("-------")
        print()
        return Empty().eraseToAnyPublisher()
    }
}
