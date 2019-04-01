//
//  APIError.swift
//  MassiveViewController
//
//  Created by shiz on 2019/03/27.
//  Copyright © 2019 shiz. All rights reserved.
//

import Foundation

enum APIError: Error {
    case invalidPath
    case parseError(Error)
    case failToFetch
}

