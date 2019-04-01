//
//  ErrorViewController.swift
//  VISITSKit
//
//  Created by shiz on 2019/03/28.
//  Copyright © 2019 shiz. All rights reserved.
//

import UIKit

protocol ErrorViewControllerDelegate: AnyObject {
    func didRetry()
}

final class ErrorViewController: UIViewController {

    weak var delegate: ErrorViewControllerDelegate?

    @IBOutlet weak var errorMessage: UILabel!

    private var message: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.errorMessage.text = message
    }

    private func setMessage(_ message: String?) {
        if let message = message {
            self.message = message
        } else {
            self.message = "エラーが発生しました。"
        }
    }

    @IBAction func retry(_ sender: Any) {
        delegate?.didRetry()
    }

    static func instantiate(message: String?) -> ErrorViewController {
        let vc = ErrorViewController(nibName: String(describing: self), bundle: Bundle(for: self))
        vc.setMessage(message)
        return vc
    }
}
