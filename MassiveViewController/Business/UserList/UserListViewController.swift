//
//  UserListViewController.swift
//  MassiveViewController
//
//  Created by shiz on 2019/03/30.
//  Copyright © 2019 shiz. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

final class UserListViewController: UIViewController, LoadingHandler, StoryboardInstantiatable, ErrorProvider, EmptyProvider {

    // MARK: typealias

    typealias UserFetChCompletion = Completion<Result<[User], APIError>>
    
    // MARK: UserCellViewController

    private var viewControllersByIndexPath: [IndexPath: UserCellViewController] = [:]

    private func addContent(_ content: UIViewController) {
        addChild(content)
        content.didMove(toParent: self)
    }
    
    private func createNewUserCellViewController() -> UserCellViewController {
        let viewController
            = UserCellViewController.instantiate(storyboardName: UserBaseViewController.storyboardName)
        addContent(viewController)
        return viewController
    }
    
    // MARK: IBOutlet
 
    @IBOutlet private var tableView: UITableView!

    // MARK: Properties

    private let refreshControl = UIRefreshControl()

    // MARK: 画面状態管理

    private final class PageStatus {
        var pageNo: Int
        var hasNext: Bool
        var searchKeyword: String?
        var filterUserType: UserType?
        
        init(pageNo: Int, hasNext: Bool,
             serachKeyword: String?,
             filterCategory: UserType?) {
            
            self.pageNo = pageNo
            self.hasNext = hasNext
            self.searchKeyword = serachKeyword
            self.filterUserType = filterCategory
        }
        
        static let initail = PageStatus(
            pageNo: 1, hasNext: false, serachKeyword: nil, filterCategory: nil)
    }

    // MARK: ページ情報
    
    private let perPageCount = 10    
    private var isNextPageLoading = false
    private var users: [User] = []
    private var pageStatus = PageStatus.initail
    
    private func resetPage() {
        pageStatus.pageNo = 1
        users = []
    }
    
    // MARK: 画面状態管理

    private var state: DisplayState<[User]> = .empty {
        didSet {
            
            removeIfErrorOrEmptyDisplayed()
            
            switch state {
            case .loading:
                showLoading(self.tableView)
            case .showingData(let users):
                hideLoading()
                pageStatus.hasNext = users.count >= perPageCount
                self.users.append(contentsOf: users)
                tableView.reloadData()
            case .empty:
                hideLoading()
                pageStatus.hasNext = false
                if self.users.isEmpty {
                    showEmptyView()
                }
            case .error(let error):
                hideLoading()
                pageStatus.hasNext = false
                showErrorView(error)
            }
        }
    }
    
    private func removeIfErrorOrEmptyDisplayed() {
        removeIfErrorDisplayed()
        removeIfEmptyDisplayed()
    }

    private func changeState(by result: Result<[User], APIError>) {
        switch result {
        case .success(let users):
            if users.isEmpty {
                state = .empty
                return
            }
            state = .showingData(users)
        case .failure(let error):
            state = .error(error)
        }
    }

    // MARK: ライフイベント

    override func viewDidLoad() {
        super.viewDidLoad()
        setTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        load(completion: changeState)
    }
    
    private func setTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        refreshControl.addTarget(self, action: #selector(self.refresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
        tableView.tableFooterView = UIView()
    }
}

// MARK: ErrorViewControllerDelegate

extension UserListViewController: ErrorViewControllerDelegate {
    func didRetry() {
        refresh()
    }
}

// MARK: リフレッシュ機能

extension UserListViewController {
    @objc func refresh() {
        resetForReload()
        load(completion: changeState)
        refreshControl.endRefreshing()
    }
}

// MARK: ユーザー情報取得機能

extension UserListViewController {
    
    func search(by keyword: String?) {
        resetForReload()
        pageStatus.searchKeyword = keyword
        load(completion: changeState)
    }

    func filter(by type: UserType?) {
        resetForReload()
        pageStatus.filterUserType = type
        load(completion: changeState)
    }

    private func resetForReload() {
        resetPage()
        viewControllersByIndexPath = [:]
    }
    
    private func load(completion: @escaping UserFetChCompletion) {
        state = .loading
        dummyFetchListAPI(completion: completion)
    }
    
    private func loadNextPage(completion: @escaping UserFetChCompletion) {
        dummyFetchListAPI { [weak self] result in
            self?.isNextPageLoading = false
            completion(result)
        }
    }
    
    private func dummyFetchListAPI(completion: @escaping UserFetChCompletion) {
        let fileName = "UserPage\(pageStatus.pageNo)"
        guard let path = Bundle.main.path(forResource: fileName, ofType: "json") else {
            completion(.success([]))
            return
        }
        
        let url = URL(fileURLWithPath: path)
        do {
            let data = try Data(contentsOf: url)
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            var users = try decoder.decode([User].self, from: data)
            users = filterUsers(users)
            
            asyncAfter {
                completion(.success(users))
            }
        } catch {
            asyncAfter {
                completion(.failure(.parseError(error)))
            }
        }
    }
    
    private func filterUsers(_ users: [User]) -> [User] {
        var filteredUsers = users
        if let keyword = pageStatus.searchKeyword {
            filteredUsers = filteredUsers.filter { $0.name.contains(keyword) }
        }
        if let type = pageStatus.filterUserType {
            filteredUsers = filteredUsers.filter { $0.type == type }
        }
        return filteredUsers
    }
}


// MARK: UIScrollViewDelegate
// - ページング機能

extension UserListViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let contentSizeHeight = scrollView.contentSize.height
        let offset = scrollView.contentOffset.y
        let height = scrollView.frame.size.height
        let didReachBottom = contentSizeHeight - 20 <= (offset + height)
        let needLoadNextPage = didReachBottom && pageStatus.hasNext && !isNextPageLoading
        
        if needLoadNextPage {
            isNextPageLoading = true
            pageStatus.pageNo += 1
            loadNextPage(completion: changeState)
        }
    }
}

// MARK: UITableViewDataSource
// - 一覧表示機能

extension UserListViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard indexPath.row <= users.count - 1 else {
            return UITableViewCell()
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: UserCell.identifier) as! UserCell
        let user = users[indexPath.row]
        
        let viewController = reuseOrCreateUserCellController(at: indexPath)
        viewController.user = user
        viewController.delegate = self
        cell.hostedView = viewController.view

        return cell
    }
    
    private func reuseOrCreateUserCellController(at indexPath: IndexPath) -> UserCellViewController {
        if let vc = viewControllersByIndexPath[indexPath] {
            return vc
        } else {
            let viewController = createNewUserCellViewController()
            viewController.delegate = self
            viewControllersByIndexPath[indexPath] = viewController
            return viewController
        }
    }
}

// MARK: UserCellViewControllerDelegate

extension UserListViewController: UserCellViewControllerDelegate {
    func didErrorOccur(_ error: Error) {
        state = .error(error)
    }
}

// MARK: UITableViewDelegate
// - 画面遷移
// - ユーザー削除

extension UserListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let user = users[indexPath.row]
        print("go to detail of \(user.name)")
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            users.remove(at: indexPath.row)
            viewControllersByIndexPath[indexPath] = nil
            tableView.deleteRows(at: [indexPath], with: .none)
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
}

// MARK:  新規ユーザー登録機能

extension UserListViewController {
    func insertNewUser(name: String) {
        users.insert(User(id: UUID().uuidString, name: name, type: .normal), at: 0)
    }
    private func insertNewUser() {
        let indexPath = IndexPath(row: 0, section: 0)
        tableView.insertRows(at: [indexPath], with: .none)
    }
}
