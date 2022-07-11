//
//  APIToken.swift
//  VkontacteAuth
//
//  Created by Николай Казанин on 06.07.2022.
//

import Foundation

struct APIToken {
    let accessToken: String
    let expiresIn: Int
    var requestedAt: Date = .now
}

extension APIToken: Codable { }
extension APIToken: Equatable { }

extension APIToken {
    var isTokenValid: Bool {
        expiresAt.compare(.now) == .orderedDescending
    }
    
    var expiresAt: Date {
        Calendar.current.date(byAdding: .second, value: expiresIn, to: requestedAt) ?? Date()
    }
}

extension APIToken {
    init(accessToken: String, expiresIn: Int) {
        self.accessToken = accessToken
        self.expiresIn = expiresIn
    }
}
