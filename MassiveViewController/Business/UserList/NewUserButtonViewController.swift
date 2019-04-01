//
//  NewUserButtonViewController.swift
//  MassiveViewController
//
//  Created by shiz on 2019/03/31.
//  Copyright © 2019 shiz. All rights reserved.
//

import UIKit

protocol NewUserButtonViewControllerDelegate: AnyObject {
    func didInput(_ name: String)
}

final class NewUserButtonViewController: UIViewController, AlertHandler {

    weak var delegate: NewUserButtonViewControllerDelegate?
    
    func showRegistrationModal() {
        
        let controller = UIAlertController(
            title: "新規登録",
            message: "入力して登録ボタンを押してください",
            preferredStyle: .alert)
        
        let register = UIAlertAction(title: "登録", style: .default) { [weak self] _ in
            
            guard let strongSelf = self else { return }
            
            guard let name = controller.textFields?[0].text else {
                strongSelf.showAlert("名前を入力してください")
                return
            }
            
            strongSelf.delegate?.didInput(name)
            controller.dismiss(animated: true)
        }
        controller.addAction(register)
        
        let cancel = UIAlertAction(title: "キャンセル", style: .cancel) { _ in
            controller.dismiss(animated: true)
        }
        controller.addAction(cancel)
        
        controller.addTextField { (textField) in
            textField.placeholder = "名前を入力してください"
        }
        self.present(controller, animated: true)
    }
}
