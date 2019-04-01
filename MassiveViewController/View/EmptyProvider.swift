//
//  EmptyProvider.swift
//  MassiveViewController
//
//  Created by shiz on 2019/03/31.
//  Copyright © 2019 shiz. All rights reserved.
//

import UIKit

protocol EmptyProvider: AnyObject {
    func emptyViewController() -> UIViewController
}

extension EmptyProvider {
    func emptyViewController() -> UIViewController {
        let vc = EmptyViewController.instantiate()
        return vc
    }
}

extension EmptyProvider  where Self: UIViewController {
    func showEmptyView() {
        addChild(viewController: emptyViewController())
    }
    
    func removeIfEmptyDisplayed() {
        if let empty = children.first(where: { $0 is EmptyViewController }) {
            removeChild(viewController: empty)
        }
    }
}
