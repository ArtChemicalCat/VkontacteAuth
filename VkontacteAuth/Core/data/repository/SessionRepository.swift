//
//  SessionRepository.swift
//  VkontacteAuth
//
//  Created by Николай Казанин on 11.07.2022.
//

import Foundation

final class UserSessionRepository {
    private var docsURL: URL? {
        return FileManager
            .default
            .urls(for: .documentDirectory,
                  in: .allDomainsMask).first
    }
    
    func readUserSession() -> UserSession? {
        guard let docsURL = docsURL else { return nil }
        
        guard let jsonData = try? Data(contentsOf: docsURL.appendingPathComponent("user_session.json")) else {
            return nil
        }
        
        let decoder = JSONDecoder()
        guard let userSession = try? decoder.decode(UserSession.self, from: jsonData) else { return nil }
        guard userSession.isValid else {
            delete(userSession: userSession)
            return nil
        }
        return userSession
    }
    
    @discardableResult
    func save(userSession: UserSession) throws -> UserSession {
        let encoder = JSONEncoder()
        let jsonData = try! encoder.encode(userSession)
        
        guard let docsURL = docsURL else {
            throw "Documents directory can't be found"
        }
        
        try? jsonData.write(to: docsURL.appendingPathComponent("user_session.json"))
        return userSession
    }
    
    func deleteUserSession() {
        let session = readUserSession()
        delete(userSession: session)
    }
    
    private func delete(userSession: UserSession?) {
        guard let _ = userSession else { return }
        
        guard let docsURL = docsURL else { return }
        
        try? FileManager.default.removeItem(at: docsURL.appendingPathComponent("user_session.json"))
    }
}
