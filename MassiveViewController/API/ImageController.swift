//
//  ImageController.swift
//  MassiveViewController
//
//  Created by shiz on 2019/03/31.
//  Copyright © 2019 shiz. All rights reserved.
//

import UIKit

struct ImageController {
    
    // MARK: typealias
    
    typealias ImageSaveCompletion = Completion<ImageError?>
    typealias ImageDeleteCompletion = Completion<ImageError?>
    typealias ImageFetchCompletion = Completion<UIImage>

    static let shared = ImageController()
    private init() {}

    private var imageFetchQueue = DispatchQueue(
        label: "shiz.massiveViewControler.ImageFetch", attributes: .concurrent)

    func fetchImage(
        with userId: String, completion: @escaping ImageFetchCompletion) {
        
        imageFetchQueue.async {
            self.getProfileImage(with: userId) { image in
                self.handleFetchedImage(image, userId: userId, completion: completion)
            }
        }
    }
    
    private func handleFetchedImage(_ image: UIImage?, userId: String,
                                    completion: @escaping ImageFetchCompletion) {
        DispatchQueue.main.async {
            guard let image = image else {
                completion(UIImage(named: "default")!)
                return
            }
            completion(image)
        }
    }

    func getDocumentsURL() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    func filePathInDocumentsDirectory(fileName: String) -> String {
        let fileNameWithExt = "\(fileName).png"
        return getDocumentsURL().appendingPathComponent(fileNameWithExt).path
    }
    
    func getProfileImage(with fileName: String,
                                 completion: @escaping Completion<UIImage?>) {
        asyncAfter(1.0) {
            let path = self.filePathInDocumentsDirectory(fileName: fileName)
            completion(UIImage(contentsOfFile: path))
        }
    }
    
    func saveImage(_ image: UIImage, name: String,
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
                completion(.fail(error))
            }
        }
    }
    
    func deleteImage(name: String,
                            completion: @escaping ImageDeleteCompletion) {
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
                completion(.fail(error))
            }
        }
    }
}
