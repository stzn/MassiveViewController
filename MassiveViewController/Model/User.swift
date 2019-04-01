//
//  User.swift
//  MassiveViewController
//
//  Created by shiz on 2019/03/23.
//  Copyright © 2019 shiz. All rights reserved.
//

import Foundation

struct User: Decodable {
    let id: String
    let name: String
    let type: UserType
}

enum UserType: Int, Decodable {
    case normal = 1, preminum
}
