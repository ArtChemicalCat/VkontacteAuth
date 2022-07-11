//
//  State.swift
//  VkontacteAuth
//
//  Created by Николай Казанин on 07.07.2022.
//

import Foundation

enum ScopedState<StateType: Equatable>: Equatable {
    case outOfScope
    case inScope(StateType)
}

enum AppState: Equatable, CustomStringConvertible {
    case signedIn(LoggedInState)
    case notSignedIn(OnboardingState)
    
    var description: String {
        switch self {
        case .signedIn(let loggedInState):
            return "signedIn(\(loggedInState))"
        case .notSignedIn(let onboardingState):
            return "notSignedIn(\(onboardingState))"
        }
    }
    
    func getSession() -> UserSession? {
        switch self {
        case let .signedIn(loggedInState):
            return loggedInState.userSession
        case .notSignedIn:
            return nil
        }
    }
}

extension AppState {
    init(from session: UserSession?) {
        guard let session = session else {
            self = .notSignedIn(.welcomeScreen)
            return
        }
        self = .signedIn(LoggedInState(userSession: session))
    }
}

enum OnboardingState: Equatable {
    case welcomeScreen
    case authenticationScreen
}

struct LoggedInState: Equatable, CustomStringConvertible {
    let userSession: UserSession
    var isLoading: Bool = false
    var user: User?
    
    var description: String {
        "Logged in with user: \(user?.fullName ?? "nil")"
    }
}
