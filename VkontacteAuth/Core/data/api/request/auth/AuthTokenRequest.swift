//
//  AuthTokenRequest.swift
//  VkontacteAuth
//
//  Created by Николай Казанин on 06.07.2022.
//

import Foundation

enum AuthTokenRequest: RequestProtocol {
    case auth
    
    var host: String {
        "oauth.vk.com"
    }
    
    var path: String {
        "/authorize"
    }
    
    var urlParams: [String : String?] {
        ["client_id": APIConstants.clientID,
         "display": "mobile",
         "redirect_uri": "https://oauth.vk.com/blank.html",
         "response_type": "token"]
    }
    
    var addAuthorizationToken: Bool {
        false
    }
    
    var requestType: RequestType {
        .POST
    }

}
