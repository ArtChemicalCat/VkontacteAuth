//
//  APIResponse.swift
//  VkontacteAuth
//
//  Created by Николай Казанин on 07.07.2022.
//

import Foundation

struct APIResponse: Decodable {
    let response: [UserDTO]
}

struct UserDTO: Decodable {
    let id: Int
    let firstName: String
    let lastName: String
    let city: CityDTO
    let photo400Orig: URL?
    
    func toDomain() -> User {
        return User(id: id,
                    photoURL: photo400Orig,
                    firstName: firstName,
                    lastName: lastName,
                    city: city.title)
    }
}

struct CityDTO: Decodable {
    let id: Int
    let title: String
}
