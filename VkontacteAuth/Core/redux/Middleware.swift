//
//  Middleware.swift
//  VkontacteAuth
//
//  Created by Николай Казанин on 07.07.2022.
//

import Combine

typealias Middleware<State, Action> = (State, Action) -> AnyPublisher<Action, Never>

enum Middlewares {
    @Injected static private var userSessionRepository: UserSessionRepository
    @Injected static private var requestManager: RequestManager

    static let getProfileInfoMiddleware: Middleware<AppState, AppActions> = { state, action in
        guard action == .requestProfileInfo,
        let token = userSessionRepository.readUserSession()?.getToken() else { return Empty(completeImmediately: true).eraseToAnyPublisher() }
        
        let request = ProfileInfoRequest()
        let publisher = PassthroughSubject<AppActions, Never>()
        Task {
            do {
                let response: APIResponse = try await requestManager.initRequest(with: request)
                let user = response.response.first!.toDomain()
                publisher.send(.userInfoLoaded(user))
                publisher.send(completion: .finished)
            } catch {
                print(error)
            }
        }
        
        return publisher.eraseToAnyPublisher()
    }
    
    static let userSessionManagingMiddleware: Middleware<AppState, AppActions> = { state, action in
        switch action {
        case .authenticationFinished(let userSession):
            _ = try? userSessionRepository.save(userSession: userSession)
        case .logOut:
            userSessionRepository.deleteUserSession()
        default:
            break
        }
        
        return Empty(completeImmediately: true).eraseToAnyPublisher()
    }
    
    static let loggerMiddleware: Middleware<AppState, AppActions> = { state, action in
        print("-------")
        print("«\(action)» action dispatched")
        print("New state: \(state)")
        print("-------")
        print()
        return Empty(completeImmediately: true).eraseToAnyPublisher()
    }
}
