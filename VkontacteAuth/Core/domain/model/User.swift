//
//  User.swift
//  VkontacteAuth
//
//  Created by Николай Казанин on 07.07.2022.
//

import Foundation

struct User: Equatable {
    let id: Int
    let photoURL: URL?
    let firstName: String
    let lastName: String
    var fullName: String {
        firstName + " " + lastName
    }
    let city: String
}
