//
//  UserSession.swift
//  VkontacteAuth
//
//  Created by Николай Казанин on 07.07.2022.
//

import Foundation

struct UserSession: Equatable {
    let userID: Int
    private let accessToken: APIToken
    
    init(userID: Int, token: APIToken) {
        self.accessToken = token
        self.userID = userID
    }
    
    func getToken() -> String? {
        guard isValid else { return nil }
        return accessToken.accessToken
    }
}

extension UserSession {
    var isValid: Bool {
        accessToken.isTokenValid
    }
}

extension UserSession: Codable {
    enum CodingKeys: String, CodingKey {
        case userID
        case accessToken
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let userID = try container.decode(Int.self, forKey: .userID)
        let accessToken = try container.decode(APIToken.self, forKey: .accessToken)
        
        self.init(userID: userID, token: accessToken)
    }
}

