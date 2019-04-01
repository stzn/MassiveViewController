//
//  ErrorProvider.swift
//  MassiveViewController
//
//  Created by shiz on 2019/03/31.
//  Copyright © 2019 shiz. All rights reserved.
//

import UIKit

protocol ErrorProvider: AnyObject {
    func errorViewController(message: String?) -> UIViewController
}

extension ErrorProvider {
    func errorViewController(message: String?) -> UIViewController {
        let vc = ErrorViewController.instantiate(message: message)
        return vc
    }
}

extension ErrorProvider  where Self: UIViewController {
    func showErrorView(_ error: Error) {
        let vc = errorViewController(message: error.localizedDescription)
        addChild(viewController: vc)
    }
    
    func removeIfErrorDisplayed() {
        if let error = children.first(where: { $0 is ErrorViewController }) {
            removeChild(viewController: error)
        }
    }
}
