//
//  Reducer.swift
//  VkontacteAuth
//
//  Created by Николай Казанин on 07.07.2022.
//

typealias Reducer<State, Action> = (State, Action) -> State

enum Reducers {
    static let authReducer: Reducer<AppState, AppActions> = { state, action in
        switch action {
        case .logIn:
            let newState = AppState.notSignedIn(.authenticationScreen)
            return newState
            
        case .authenticationFinished(let session):
            let loggedInState = LoggedInState(userSession: session)
            let newState = AppState.signedIn(loggedInState)
            return newState
            
        case .authViewDismissed:
            guard state == .notSignedIn(OnboardingState.authenticationScreen)  else { return state }
            let newState = AppState.notSignedIn(OnboardingState.welcomeScreen)
            return newState
        case .requestProfileInfo:
            guard let session = state.getSession() else {
                return AppState.notSignedIn(.welcomeScreen)
            }
            let loggedInState = LoggedInState(userSession: session, isLoading: true)
            let newState = AppState.signedIn(loggedInState)
            
            return newState
        case .userInfoLoaded(let user):
            guard let session = state.getSession() else { return AppState.notSignedIn(.welcomeScreen)}

            let newState = AppState.signedIn(LoggedInState(userSession: session,
                                                           isLoading: false,
                                                           user: user))
            return newState
        case .logOut:
            let newState = AppState.notSignedIn(.welcomeScreen)
            return newState
        }
    }
}
