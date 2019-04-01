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
    
    var user: User!
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!

    override func prepareForReuse() {
        profileImage.image = nil
        nameLabel.text = nil
    }

    func configure(user: User) {
        self.user = user
        nameLabel.text = user.name
    }
    
    func setImage(_ image: UIImage) {
        profileImage.image = image
    }
}
