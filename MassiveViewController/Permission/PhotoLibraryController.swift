//
//  PhotoLibraryController.swift
//  MassiveViewController
//
//  Created by shiz on 2019/03/31.
//  Copyright © 2019 shiz. All rights reserved.
//

import Foundation
import Photos

struct PhotoLibraryController {

    static func checkPhotoLibraryPermission(resultHandler: @escaping (PHAuthorizationStatus) -> Void) {
        switch PHPhotoLibrary.authorizationStatus() {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { status in
                if case .authorized = status {
                    resultHandler(.authorized)
                }
            }
        case .restricted:
            resultHandler(.restricted)
        case .denied:
            resultHandler(.denied)
        case .authorized:
            resultHandler(.authorized)
        @unknown default:
            fatalError()
        }
    }
    
}
