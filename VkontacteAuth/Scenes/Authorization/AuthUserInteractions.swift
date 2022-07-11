//
//  AuthUserInteractions.swift
//  VkontacteAuth
//
//  Created by Николай Казанин on 07.07.2022.
//

import Foundation

protocol AuthUserInteractions {
    func logIn()
    func createUserSession(token: APIToken, userID: Int)
    func authViewDismissed()
}

final class ReduxAuthUserInteractions: AuthUserInteractions {
    private let store: AppStore
    private let sessionRepository: UserSessionRepository
    
    init(store: AppStore, sessionRepository: UserSessionRepository) {
        self.store = store
        self.sessionRepository = sessionRepository
    }
    
    func logIn() {
        store.dispatch(.logIn)
    }
    
    func createUserSession(token: APIToken, userID: Int) {
        let userSession = UserSession(userID: userID, token: token)
        _ = try? sessionRepository.save(userSession: userSession)
        
        store.dispatch(.authenticationFinished(userSession))
    }
    
    func authViewDismissed() {
        store.dispatch(.authViewDismissed)
    }
}
