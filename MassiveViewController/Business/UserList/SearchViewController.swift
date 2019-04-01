//
//  SearchViewController.swift
//  MassiveViewController
//
//  Created by shiz on 2019/03/31.
//  Copyright © 2019 shiz. All rights reserved.
//

import UIKit

protocol SearchViewControllerDelegate: AnyObject {
    func didInputText(_ text: String?)
    func didSelectFilter(_ type: UserType?)
}

final class SearchViewController: UIViewController {

    // MARK: IBOutlet
    
    @IBOutlet private var searchBar: UISearchBar!
    @IBOutlet private var filterButton: UIButton!

    weak var delegate: SearchViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setSearchBarDelegate()
    }
    
    private func setSearchBarDelegate() {
        searchBar.delegate = self
    }
}

// MARK: フィルター機能

extension SearchViewController {
    
    @IBAction func filter(_ sender: Any) {
        showUserTypeFilterModal()
    }

    func showUserTypeFilterModal() {
        let controller = UIAlertController(title: "絞り込み",
                                           message: "選択してください", preferredStyle: .actionSheet)
        
        let normal = UIAlertAction(title: "通常会員", style: .default) { [weak self] _ in
            
            guard let strongSelf = self else { return }
            
            strongSelf.delegate?.didSelectFilter(.normal)
            controller.dismiss(animated: true)
        }
        controller.addAction(normal)
        
        let preminum = UIAlertAction(title: "プレミアム会員", style: .default) { [weak self] _ in
            
            guard let strongSelf = self else { return }
            
            strongSelf.delegate?.didSelectFilter(.preminum)
            controller.dismiss(animated: true)
        }
        controller.addAction(preminum)
        
        let none = UIAlertAction(title: "絞り込みしない", style: .default) { [weak self] _ in
            
            guard let strongSelf = self else { return }
            
            strongSelf.delegate?.didSelectFilter(nil)
            controller.dismiss(animated: true)
        }
        controller.addAction(none)
        
        let cancel = UIAlertAction(title: "キャンセル", style: .cancel) { _ in
            controller.dismiss(animated: true)
        }
        controller.addAction(cancel)
        self.present(controller, animated: true)
    }
}

// MARK: UISearchBarDelegate
// - 名前検索機能

extension SearchViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.search(_:)), object: searchBar)
        perform(#selector(self.search(_:)), with: searchBar, afterDelay: 0.75)
    }
    
    @objc func search(_ searchBar: UISearchBar) {
        
        var searchKeyword: String? = nil
        if let keyWord = searchBar.text,
            keyWord.trimmingCharacters(in: .whitespaces) != "" {
            searchKeyword = keyWord
        }
        delegate?.didInputText(searchKeyword)
    }
}


