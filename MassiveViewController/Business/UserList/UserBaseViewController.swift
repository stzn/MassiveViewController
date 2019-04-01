//
//  UserBaseViewController.swift
//  MassiveViewController
//
//  Created by shiz on 2019/03/23.
//  Copyright © 2019 shiz. All rights reserved.
//

import UIKit

final class UserBaseViewController: UIViewController, LoadingHandler {
    
    static let storyboardName = "UserList"
    
    lazy var userListViewController: UserListViewController = {
        let viewController = self.children.first(where: { $0 is UserListViewController } ) as! UserListViewController
        return viewController
    }()

    lazy var newUserViewController: NewUserButtonViewController = {
        let viewController = NewUserButtonViewController()
        viewController.delegate = self
        addChild(viewController: viewController)
        return viewController
    }()
    
    // MARK: ライフサイクルイベント
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setSearchControllerDelegate()
        navigationItem.title = "ユーザー一覧"
    }
    
    private func setSearchControllerDelegate() {
        if let searchController = self.children.first(
            where: { $0 is SearchViewController } ) as? SearchViewController {
            searchController.delegate = self
        }
    }
}

// MARK: SearchViewControllerDelegate(検索機能)

extension UserBaseViewController: SearchViewControllerDelegate {
    func didInputText(_ text: String?) {
        userListViewController.search(by: text)
    }
    
    func didSelectFilter(_ type: UserType?) {
        userListViewController.filter(by: type)
    }
}

// MARK:  新規ユーザー登録機能

extension UserBaseViewController: NewUserButtonViewControllerDelegate {
    func didInput(_ name: String) {
        userListViewController.insertNewUser(name: name)
    }
}

extension UserBaseViewController {
    @IBAction func registerNewUser(_ sender: Any) {
        newUserViewController.showRegistrationModal()
    }
}

// MARK: Helper

func asyncAfter(_ deadline: TimeInterval = 1.0, action: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + deadline, execute: action)
}



