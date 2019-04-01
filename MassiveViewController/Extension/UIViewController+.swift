//
//  UIViewController+.swift
//  VISITSKit
//
//  Created by shiz on 2019/03/28.
//  Copyright © 2019 shiz. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func addChild(viewController: UIViewController) {
        viewController.willMove(toParent: self)
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(viewController.view)

        NSLayoutConstraint.activate([
            viewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            viewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            viewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            viewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            ])

        addChild(viewController)
        viewController.didMove(toParent: self)
    }

    func removeChild(viewController: UIViewController) {
        viewController.willMove(toParent: nil)
        viewController.view.removeFromSuperview()
        viewController.removeFromParent()
        viewController.didMove(toParent: nil)
    }

    public func removeAllChildViewControllers() {
        children.forEach { removeChild(viewController: $0) }
    }

    public func removePreviousChildrenAndAdd(viewController: UIViewController?) {
        guard let viewController = viewController else {
            return
        }
        removeAllChildViewControllers()
        addChild(viewController: viewController)
    }
}
