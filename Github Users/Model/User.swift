//
//  User.swift
//  Github Users
//
//  Created by jeremie bitancor on 7/14/21.
//

import Foundation

struct User: Codable {
    let login: String
    let avatar_url: String
}

struct UserList: Codable {
    let userList: [User]
}
