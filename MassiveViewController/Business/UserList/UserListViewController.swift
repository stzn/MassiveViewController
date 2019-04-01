//
//  UserListViewController.swift
//  MassiveViewController
//
//  Created by shiz on 2019/03/23.
//  Copyright © 2019 shiz. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

final class UserListViewController: UIViewController, UISearchBarDelegate,
    UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate,
    UINavigationControllerDelegate, UIScrollViewDelegate {
    
    // MARK: typealias
    
    typealias ImageSaveCompletion = Completion<ImageError?>
    typealias ImageDeleteCompletion = Completion<ImageError?>
    typealias ImageFetchCompletion = Completion<UIImage>
    typealias UserFetChCompletion = Completion<Result<[User], APIError>>
    
    // MARK: IBOutlet
    
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var searchBar: UISearchBar!
    @IBOutlet private var filterButton: UIButton!
    
    // MARK: ページ表示情報
    
    private var users: [User] = []
    private var pageStatus = PageStatus.initail
    
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
        
        static let initail = PageStatus(pageNo: 1, hasNext: false,
                                        serachKeyword: nil, filterCategory: nil)
    }
    
    private func resetPage() {
        pageStatus.pageNo = 1
        users = []
    }
    
    // MARK: 画面状態管理
    
    private var state: DisplayState<[User]> = .empty {
        didSet {
            
            hideAll()
            
            switch state {
            case .loading:
                showLoading(self.tableView)
            case .showingData(let users):
                hideLoading()
                pageStatus.hasNext = true
                self.users.append(contentsOf: users)
                tableView.reloadData()
                tableView.isHidden = false
            case .empty:
                hideLoading()
                pageStatus.hasNext = false
                if self.users.isEmpty {
                    emptyView.isHidden = false
                }
            case .error(let error):
                hideLoading()
                pageStatus.hasNext = false
                errorMessageLabel.text = error.localizedDescription
                errorMessageLabel.sizeToFit()
                errorView.isHidden = false
            }
        }
    }
    
    private func hideAll() {
        tableView.isHidden = true
        emptyView.isHidden = true
        errorView.isHidden = true
        hideLoading()
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
    
    // MARK: ローディング表示
    
    private let indicatorViewTag = 9999
    
    private func showLoading(_ view: UIView) {
        let indicator = makeIndicatorView()
        self.view.addSubview(indicator)
        NSLayoutConstraint.activate([
            indicator.topAnchor.constraint(equalTo: view.topAnchor),
            indicator.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            indicator.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            indicator.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            ])
    }
    
    private func hideLoading() {
        guard let indicator = view.viewWithTag(indicatorViewTag) else {
            return
        }
        indicator.removeFromSuperview()
    }
    
    private func makeIndicatorView() -> UIView {
        if let view = self.view.viewWithTag(indicatorViewTag) {
            return view
        }
        
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.tag = indicatorViewTag
        let indicator = UIActivityIndicatorView(style: .gray)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(indicator)
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            ])
        indicator.startAnimating()
        return view
    }
    
    // MARK: データなし表示
    
    private lazy var emptyView: UIView = {
        let view = UIView(frame: self.view.bounds)
        let label = UILabel()
        label.text = "データがありません。"
        view.addSubview(label)
        label.sizeToFit()
        label.center = view.center
        self.view.addSubview(view)
        return view
    }()
    
    // MARK: エラー表示
    
    private var errorMessageLabel: UILabel!
    private lazy var errorView: UIStackView = {
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        
        do {
            let label = UILabel()
            label.numberOfLines = 0
            label.textAlignment = .center
            stackView.addArrangedSubview(label)
            errorMessageLabel = label
        }
        
        do {
            let button = UIButton()
            button.setTitle("リトライ", for: .normal)
            button.backgroundColor = .lightGray
            button.addTarget(self, action: #selector(retry), for: .touchUpInside)
            stackView.addArrangedSubview(button)
        }
        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8, constant: 0)
            ])
        return stackView
    }()
    
    // MARK: リトライ機能
    
    @objc func retry() {
        load(completion: self.changeState)
    }
    
    // MARK: リフレッシュ機能
    
    private let refreshControl = UIRefreshControl()
    
    @objc func refresh() {
        resetPage()
        load(completion: changeState)
        refreshControl.endRefreshing()
    }
    
    // MARK: ライフサイクルイベント
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTableView()
        setSearchBarDelegate()
        navigationItem.title = "ユーザー一覧"
        load(completion: self.changeState)
    }
    
    // MARK: View初期化
    
    private func setSearchBarDelegate() {
        searchBar.delegate = self
    }
    
    private func setTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        refreshControl.addTarget(self, action: #selector(self.refresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
        tableView.tableFooterView = UIView()
    }
    
    // MARK: ユーザー情報取得機能
    
    func load(completion: @escaping UserFetChCompletion) {
        state = .loading
        dummyFetchListAPI(completion: completion)
    }
    
    func loadNextPage(completion: @escaping UserFetChCompletion) {
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
            if let keyword = pageStatus.searchKeyword {
                users = users.filter { $0.name.contains(keyword) }
            }
            if let type = pageStatus.filterUserType {
                users = users.filter { $0.type == type }
            }
            asyncAfter {
                completion(.success(users))
            }
        } catch {
            asyncAfter {
                completion(.failure(.parseError(error)))
            }
        }
    }
    
    // MARK: ユーザープロフィール画像取得機能
    
    private lazy var imageFetchQueue: DispatchQueue = {
        let queue = DispatchQueue(label: "shiz.massiveViewControler.ImageFetch", attributes: .concurrent)
        return queue
    }()
    
    private func fetchImage(
        with userId: String, completion: @escaping ImageFetchCompletion) {
        
        if let image = cachedImages[userId] {
            DispatchQueue.main.async {
                completion(image.image)
            }
            return
        } else {
            cachedImages[userId] = nil
        }
        
        imageFetchQueue.async { [weak self] in
            self?.getProfileImage(with: userId) { [weak self] image in
                self?.handleFetchedImage(image, userId: userId, completion: completion)
            }
        }
    }
    
    private func handleFetchedImage(_ image: UIImage?, userId: String,
                                    completion: @escaping ImageFetchCompletion) {
        
        DispatchQueue.main.async { [weak self] in
            guard let image = image else {
                completion(UIImage(named: "default")!)
                return
            }
            self?.cache(id: userId, image: image)
            completion(image)
        }
    }
    
    // MARK: リモート画像取得機能(ダミーとしてドキュメントフォルダへ保存)
    
    private func getDocumentsURL() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    private func filePathInDocumentsDirectory(fileName: String) -> String {
        let fileNameWithExt = "\(fileName).png"
        return getDocumentsURL().appendingPathComponent(fileNameWithExt).path
    }
    
    private func getProfileImage(with fileName: String,
                                 completion: @escaping Completion<UIImage?>) {
        asyncAfter(1.0) { [weak self] in
            guard let strongself = self else {
                return
            }
            let path = strongself.filePathInDocumentsDirectory(fileName: fileName)
            completion(UIImage(contentsOfFile: path))
        }
    }
    
    private func saveImage(_ image: UIImage, name: String,
                           completion: @escaping ImageSaveCompletion) {
        let path = filePathInDocumentsDirectory(fileName: name)
        let url = URL(fileURLWithPath: path)
        
        do {
            guard let data = image.pngData() else {
                throw ImageError.invalidData
            }
            try data.write(to: url)
            
            asyncAfter {
                completion(nil)
            }
        } catch {
            asyncAfter {
                completion(.failure(error))
            }
        }
    }
    
    private func deleteImage(name: String, completion: @escaping ImageDeleteCompletion) {
        let path = filePathInDocumentsDirectory(fileName: name)
        
        let manager = FileManager.default
        do {
            if manager.fileExists(atPath: path) {
                try manager.removeItem(atPath: path)
            }
            asyncAfter {
                completion(nil)
            }
        } catch {
            asyncAfter {
                completion(.failure(error))
            }
        }
    }
    
    // MARK: 画像キャッシュ機能
    
    private struct CachedImage {
        let image: UIImage
        let cachedDate: Date
    }
    
    private var cachedImages: [String: CachedImage] = [:]
    
    private func cache(id: String, image: UIImage) {
        cachedImages[id] = nil
        cachedImages[id] = CachedImage(image: image, cachedDate: Date())
    }
    
    // MARK: フィルター機能
    
    @IBAction func filter(_ sender: Any) {
        showUserTypeFilterModal()
    }
    
    func showUserTypeFilterModal() {
        let controller = UIAlertController(title: "絞り込み",
                                           message: "選択してください", preferredStyle: .actionSheet)
        
        let normal = UIAlertAction(title: "通常会員", style: .default) { [weak self] _ in
            
            guard let strongSelf = self else { return }
            
            strongSelf.resetPage()
            strongSelf.pageStatus.filterUserType = .normal
            strongSelf.load(completion: strongSelf.changeState)
            controller.dismiss(animated: true)
        }
        controller.addAction(normal)
        
        let preminum = UIAlertAction(title: "プレミアム会員", style: .default) { [weak self] _ in
            
            guard let strongSelf = self else { return }
            
            strongSelf.resetPage()
            strongSelf.pageStatus.filterUserType = .preminum
            strongSelf.load(completion: strongSelf.changeState)
            controller.dismiss(animated: true)
        }
        controller.addAction(preminum)
        
        let none = UIAlertAction(title: "絞り込みしない", style: .default) { [weak self] _ in
            
            guard let strongSelf = self else { return }
            
            strongSelf.resetPage()
            strongSelf.pageStatus.filterUserType = nil
            strongSelf.load(completion: strongSelf.changeState)
            controller.dismiss(animated: true)
        }
        controller.addAction(none)
        
        let cancel = UIAlertAction(title: "キャンセル", style: .cancel) { _ in
            controller.dismiss(animated: true)
        }
        controller.addAction(cancel)
        self.present(controller, animated: true)
    }
    
    // MARK: 名前検索機能
    
    // MARK: UISearchBarDelegate textDidChange
    
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
        resetPage()
        pageStatus.searchKeyword = searchKeyword
        load(completion: self.changeState)
    }
    
    // MARK:  新規ユーザー登録機能
    
    @IBAction func registerNewUser(_ sender: Any) {
        showRegistrationModal()
    }
    
    func showRegistrationModal() {
        let controller = UIAlertController(
            title: "新規登録",
            message: "入力して登録ボタンを押してください",
            preferredStyle: .alert)
        
        let register = UIAlertAction(title: "登録", style: .default) { [weak self] _ in
            
            guard let name = controller.textFields?[0].text else {
                self?.showErrorAlert("名前を入力してください")
                return
            }
            self?.users.insert(User(id: UUID().uuidString, name: name, type: .normal), at: 0)
            self?.insertNewUser()
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
    
    private func insertNewUser() {
        let indexPath = IndexPath(row: 0, section: 0)
        tableView.insertRows(at: [indexPath], with: .none)
    }
    
    private func showErrorAlert(_ message: String) {
        let controller = UIAlertController(title: "エラー", message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default) { _ in
            controller.dismiss(animated: true)
        }
        controller.addAction(ok)
        present(controller, animated: true)
    }
    
    // MARK: ページング機能
    
    // MARK: UIScrollViewDelegate scrollViewDidScroll
    
    private var isNextPageLoading = false
    
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
    
    // MARK: 一覧表示機能
    
    // MARK: UITableViewDataSource
    
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
        return setUserCell(at: indexPath)
    }
    
    // MARK: UITableViewDelegate willDisplay
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        guard let cell = cell as? UserCell else {
            return
        }
        let user = users[indexPath.row]
        setImage(to: cell, id: user.id)
    }
    
    // MARK: UITableViewDelegate heightForRowAt
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    // MARK: セル設定
    
    @discardableResult
    private func setUserCell(at indexPath: IndexPath) -> UserCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: UserCell.identifier) as! UserCell
        let user = users[indexPath.row]
        
        cell.configure(user: user)
        setTagToProfileImage(cell.profileImage, with: indexPath.row)
        setImageTapRecognizer(to: cell)
        return cell
    }
    
    private func setTagToProfileImage(_ image: UIImageView, with rowNumber: Int) {
        image.tag = rowNumber
    }
    
    private func setImageTapRecognizer(to cell: UserCell) {
        cell.profileImage.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(selectImage(_:)))
        cell.profileImage.addGestureRecognizer(tap)
    }
    
    private func setImage(to cell: UserCell, id: String) {
        
        fetchImage(with: id) { [weak self] image in
            
            guard let strongSelf = self else { return }
            
            strongSelf.setImageIfCellVisible(to: cell, image: image)
        }
    }
    
    private func setImageIfCellVisible(to cell: UserCell, image: UIImage) {
        let visibleCells = tableView.visibleCells
        if visibleCells.contains(cell) {
            cell.setImage(image)
        }
    }
    
    @objc func selectImage(_ tapGesture: UITapGestureRecognizer) {
        guard let image = tapGesture.view as? UIImageView,
            let cell = self.tableView.cellForRow(at: IndexPath(row: image.tag, section: 0)) as? UserCell
            else {
                return
        }
        pickedCell = cell
        presentImageSelectActionSheet()
    }
    
    // MARK: 画面遷移
    
    // MARK: UITableViewDelegate didSelect
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let user = users[indexPath.row]
        print("go to detail of \(user.name)")
    }
    
    // MARK: ユーザー削除
    
    // MARK: UITableViewDelegate willDisplay
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let user = users.remove(at: indexPath.row)
            cachedImages[user.id] = nil
            deleteImage(name: user.id) { error in
                
                guard error == nil else { return }
                
                DispatchQueue.main.async { [weak self] in
                    self?.tableView.deleteRows(at: [indexPath], with: .fade)
                }
            }
        }
    }
    
    // MARK: 画像選択機能
    
    private func presentImageSelectActionSheet() {
        
        let controller = UIAlertController(title: "画像選択", message: "下記から画像を選択してください", preferredStyle: .actionSheet)
        let camera = UIAlertAction(title: "カメラ", style: .default) { [weak self] _ in
            self?.startCameraAction()
            controller.dismiss(animated: true)
        }
        controller.addAction(camera)
        let library = UIAlertAction(title: "ライブラリ", style: .default) { [weak self] _ in
            self?.startPhotoLibraryAction()
            controller.dismiss(animated: true)
        }
        controller.addAction(library)
        
        let cancel = UIAlertAction(title: "キャンセル", style: .cancel) { _ in
            controller.dismiss(animated: true)
        }
        controller.addAction(cancel)
        
        present(controller, animated: true)
    }
    
    
    private func startCameraAction() {
        checkCameraPermission()
    }
    
    private func startPhotoLibraryAction() {
        checkPhotoLibraryPermission()
    }
    
    // MARK: カメラ権限チェック
    
    private func checkCameraPermission() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { success in
                if success {
                    self.presentImagePicker(type: .camera)
                }
            }
        case .restricted:
            showErrorAlert("カメラの利用が制限されています。")
        case .denied:
            showErrorAlert("カメラの利用が禁止されています。")
        case .authorized:
            presentImagePicker(type: .camera)
        @unknown default:
            fatalError()
        }
    }
    
    // MARK: フォトライブラリ権限チェック
    
    private func checkPhotoLibraryPermission() {
        switch PHPhotoLibrary.authorizationStatus() {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { status in
                if case .authorized = status {
                    self.presentImagePicker(type: .photoLibrary)
                }
            }
        case .restricted:
            showErrorAlert("フォトライブラリの利用が制限されています。")
        case .denied:
            showErrorAlert("フォトライブラリの利用が禁止されています。")
        case .authorized:
            presentImagePicker(type: .photoLibrary)
        @unknown default:
            fatalError()
        }
    }
    
    // MARK: 画像選択ImagePicker表示
    
    private func presentImagePicker(type: UIImagePickerController.SourceType) {
        let picker = UIImagePickerController()
        picker.sourceType = type
        picker.delegate = self
        present(picker, animated: true)
    }
    
    // MARK: ImagePickerDelegate
    
    private var pickedCell: UserCell? = nil
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        defer { dismiss(animated:true) }
        
        guard let cell = pickedCell else {
            return
        }
        
        let index = cell.profileImage.tag
        let user = users[index]
        let chosenImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        
        showLoading(self.tableView)
        
        saveImage(chosenImage, name: user.id) { [weak self] error in
            
            guard let strongSelf = self else { return }
            
            defer { strongSelf.hideLoading() }
            
            if let error = error {
                strongSelf.state = .error(error)
                return
            }
            strongSelf.cache(id: user.id, image: chosenImage)
            strongSelf.setImageIfCellVisible(to: cell, image: chosenImage)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
}

// MARK: Helper

private func asyncAfter(_ deadline: TimeInterval = 1.0, action: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + deadline, execute: action)
}



