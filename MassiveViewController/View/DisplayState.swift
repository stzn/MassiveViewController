//
//  DisplayState.swift
//  MassiveViewController
//
//  Created by shiz on 2019/03/27.
//  Copyright © 2019 shiz. All rights reserved.
//

import Foundation

enum DisplayState<T> {
    case loading
    case showingData(T)
    case empty
    case error(Error)
}
