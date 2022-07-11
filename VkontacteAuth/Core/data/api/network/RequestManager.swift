//
//  RequestManager.swift
//  VkontacteAuth
//
//  Created by Николай Казанин on 06.07.2022.
//

import Foundation

protocol RequestManagerProtocol {
    var apiManager: APIManagerProtocol { get }
    var parser: DataParserProtocol { get }
    func initRequest<T: Decodable>(with data: RequestProtocol) async throws -> T
}

final class RequestManager: RequestManagerProtocol {
    let apiManager: APIManagerProtocol
    let userSessionRepository: UserSessionRepository
    
    init(apiManager: APIManagerProtocol = APIManager(),
         userSessionRepository: UserSessionRepository = UserSessionRepository()) {
        self.apiManager = apiManager
        self.userSessionRepository = userSessionRepository
    }
    
    
    func initRequest<T: Decodable>(with data: RequestProtocol) async throws -> T {
        guard let userSession = userSessionRepository.readUserSession(),
              let token = userSession.getToken() else { throw "User session is not valid" }
        

        let data = try await apiManager.initRequest(with: data, authToken: token)
        let decoded: T = try parser.parse(data: data)
        return decoded
    }
}

extension RequestManagerProtocol {
    var parser: DataParserProtocol {
        DataParser()
    }
}
