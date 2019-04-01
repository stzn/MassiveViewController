//
//  AlertHandler.swift
//  MassiveViewController
//
//  Created by shiz on 2019/03/31.
//  Copyright © 2019 shiz. All rights reserved.
//

import UIKit

protocol AlertHandler: AnyObject {
    func showAlert(_ message: String, on viewController: UIViewController)
}

extension AlertHandler where Self: UIViewController {

    func showAlert(_ message: String, on viewController: UIViewController) {
        let controller = UIAlertController(title: "エラー", message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default) { _ in
            controller.dismiss(animated: true)
        }
        controller.addAction(ok)
        viewController.present(controller, animated: true)
    }

    func showAlert(_ message: String) {
        showAlert(message, on: self)
    }
}
