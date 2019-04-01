//
//  UserCell.swift
//  MassiveViewController
//
//  Created by shiz on 2019/03/23.
//  Copyright © 2019 shiz. All rights reserved.
//

import UIKit

final class UserCell: UITableViewCell {

    static let identifier = "user"
    
    var hostedView: UIView? {
        didSet {
            guard let hostedView = hostedView else {
                return
            }
            hostedView.frame = contentView.bounds
            contentView.addSubview(hostedView)
        }
    }
    
    override func prepareForReuse() {
        
        super.prepareForReuse()
        
        if hostedView?.superview == contentView {
            hostedView?.removeFromSuperview()
        }
        hostedView = nil
    }
}
