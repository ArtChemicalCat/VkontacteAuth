//
//  ProfileInfoRequest.swift
//  VkontacteAuth
//
//  Created by Николай Казанин on 07.07.2022.
//

import Foundation

struct ProfileInfoRequest: RequestProtocol {
    let path: String = "/method/users.get"
    let host: String = "api.vk.com"
    let requestType: RequestType = .GET
    
    var urlParams: [String : String?] = ["v": "5.131",
                                         "fields": "city, photo_400_orig"]
}
