//
//  CameraPermissionController.swift
//  MassiveViewController
//
//  Created by shiz on 2019/03/31.
//  Copyright © 2019 shiz. All rights reserved.
//

import Foundation
import AVFoundation

struct CameraPermissionController {
    
    static func checkCameraPermission(resultHandler: @escaping (AVAuthorizationStatus) -> Void) {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { success in
                if success {
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

