//
//  ProfileUserInteractons.swift
//  VkontacteAuth
//
//  Created by Николай Казанин on 07.07.2022.
//

import Foundation

protocol ProfileUserInteractions {
    func requestUserInfo()
    func logOut()
}

final class ReduxProfileUserInteractions: ProfileUserInteractions {
    private let store: AppStore
    private let requestManager: RequestManagerProtocol
    private let sessionRepository: UserSessionRepository
    
    init(store: AppStore,
         requestManager: RequestManagerProtocol = RequestManager(),
         sessionRepository: UserSessionRepository = .init()) {
        self.store = store
        self.requestManager = requestManager
        self.sessionRepository = sessionRepository
    }
    
    func requestUserInfo() {
        store.dispatch(AppActions.requestProfileInfo)
        let request = ProfileInfoRequest()
        Task {
            do {
                let response: APIResponse = try await requestManager.initRequest(with: request)
                let user = response.response.first!.toDomain()
                store.dispatch(AppActions.userInfoLoaded(user))
            } catch {
                print(error)
            }
        }
    }
    
    func logOut() {
        store.dispatch(.logOut)
        sessionRepository.deleteUserSession()
    }
}
