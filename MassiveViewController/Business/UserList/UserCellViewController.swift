//
//  UserCellViewController.swift
//  MassiveViewController
//
//  Created by shiz on 2019/03/30.
//  Copyright © 2019 shiz. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

protocol UserCellViewControllerDelegate: AnyObject {
    func didErrorOccur(_ error: Error)
}

final class UserCellViewController: UIViewController, LoadingHandler, StoryboardInstantiatable {

    // MARK: IBOutlet
    
    @IBOutlet private weak var profileImage: UIImageView! {
        didSet {
            profileImage.image = nil
            profileImage.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(selectImage(_:)))
            profileImage.addGestureRecognizer(tap)
        }
    }
    
    @IBOutlet private weak var nameLabel: UILabel! {
        didSet {
            nameLabel.text = nil
        }
    }
    
    // MARK: Properties

    weak var delegate: UserCellViewControllerDelegate?
    var user: User!
    private var cachedImage: UIImage?
    
    lazy var userProfileImageViewController: UserProfileImageViewController = {
        let viewController = UserProfileImageViewController()
        viewController.delegate = self
        
        addChild(viewController: viewController)
        
        // 後ろのprofileImageをタップするため
        viewController.view.isUserInteractionEnabled = false

        return viewController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configure()
        
        if let image = cachedImage {
            setImage(image)
            return
        }
        
        userProfileImageViewController.fetchImage(with: user.id)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        nameLabel.text = nil
        profileImage.image = nil
    }
    
    private func configure() {
        nameLabel.text = user.name
    }
    
    private func setImage(_ image: UIImage) {
        profileImage.image = image
    }
    
    @objc func selectImage(_ tapGesture: UITapGestureRecognizer) {
        userProfileImageViewController.presentImageSelectActionSheet()
    }
}

extension UserCellViewController: UserProfileImageViewControllerDelegate {
    func didFetchImage(_ image: UIImage) {
        cachedImage = image
        setImage(image)
    }
    
    func didSelectImage(_ image: UIImage) {
        userProfileImageViewController.saveImage(image, userId: user.id)
    }
    
    func didFailSaveImage(_ error: Error) {
        delegate?.didErrorOccur(error)
    }
    
    func didSaveImage(_ image: UIImage) {
        cachedImage = image
    }
}
