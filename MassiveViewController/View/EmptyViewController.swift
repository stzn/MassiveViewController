//
//  EmptyViewController.swift
//  VISITSKit
//
//  Created by shiz on 2019/03/28.
//  Copyright © 2019 shiz. All rights reserved.
//

import UIKit

final class EmptyViewController: UIViewController {
    @IBOutlet weak var emptyMessage: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    static func instantiate() -> EmptyViewController {
        return EmptyViewController(nibName: String(describing: self), bundle: Bundle(for: self))
    }
}
