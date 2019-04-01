//
//  UserProfileImageViewController.swift
//  MassiveViewController
//
//  Created by shiz on 2019/03/31.
//  Copyright © 2019 shiz. All rights reserved.
//

import UIKit

protocol UserProfileImageViewControllerDelegate: AnyObject {
    func didFailSaveImage(_ error: Error)
    func didFetchImage(_ image: UIImage)
    func didSelectImage(_ image: UIImage)
    func didSaveImage(_ image: UIImage)
}

final class UserProfileImageViewController: UIViewController, LoadingHandler, AlertHandler {

    weak var delegate: UserProfileImageViewControllerDelegate?
    var imageController = ImageController.shared

    func fetchImage(with userId: String) {
        imageController.fetchImage(with: userId) { [weak self] image in
            self?.delegate?.didFetchImage(image)
        }
    }
    
    func saveImage(_ image: UIImage, userId: String) {
        
        showLoading(parent!.view)
        
        imageController.saveImage(image, name: userId) { [weak self] error in
            
            guard let strongSelf = self else { return }
            
            defer { strongSelf.hideLoading() }
            
            if let error = error {
                strongSelf.delegate?.didFailSaveImage(error)
                return
            }
            strongSelf.delegate?.didSaveImage(image)
        }
    }
    
    func presentImageSelectActionSheet() {

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
        CameraPermissionController.checkCameraPermission { [weak self] status in
            
            guard let storngSelf = self else { return }
            
            switch status {
            case .restricted:
                storngSelf.showAlert("カメラの利用が制限されています。")
            case .denied:
                storngSelf.showAlert("カメラの利用が禁止されています。")
            case .authorized:
                storngSelf.presentImagePicker(type: .camera)
            default:
                fatalError("invalid status")
            }
        }
    }
    
    private func startPhotoLibraryAction() {
        PhotoLibraryController.checkPhotoLibraryPermission { [weak self] status in
            
            guard let storngSelf = self else { return }
            
            switch status {
            case .restricted:
                storngSelf.showAlert("フォトライブラリの利用が制限されています。")
            case .denied:
                storngSelf.showAlert("フォトライブラリの利用が禁止されています。")
            case .authorized:
                storngSelf.presentImagePicker(type: .photoLibrary)
            default:
                fatalError("invalid status")
            }
        }
    }
    
    // MARK: 画像選択ImagePicker表示
    
    private func presentImagePicker(type: UIImagePickerController.SourceType) {
        
        let picker = UIImagePickerController()
        picker.sourceType = type
        picker.delegate = self
        present(picker, animated: true)
    }
}

// MARK: UIImagePickerControllerDelegate

extension UserProfileImageViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        defer { dismiss(animated:true) }
        
        let chosenImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        
        delegate?.didSelectImage(chosenImage)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        dismiss(animated: true)
    }
}
