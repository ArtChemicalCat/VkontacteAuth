//
//  Actions.swift
//  VkontacteAuth
//
//  Created by Николай Казанин on 07.07.2022.
//

import Foundation

enum AppActions: CustomStringConvertible {
    case logIn
    case authenticationFinished(UserSession)
    case authViewDismissed
    
    case requestProfileInfo
    case userInfoLoaded(User)
    case logOut
    
    var description: String {
        switch self {
        case .logIn:
            return "login"
        case .authenticationFinished:
            return "authenticationFinished"
        case .authViewDismissed:
            return "authViewDismissed"
        case .requestProfileInfo:
            return "requestProfileInfo"
        case .userInfoLoaded:
            return "userInfoLoaded"
        case .logOut:
            return "logOut"
        }
    }
}

