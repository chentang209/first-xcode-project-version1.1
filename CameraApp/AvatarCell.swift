//
//  AvatarCell.swift
//  CameraApp
//
//  Created by Hang Yang on 2/25/19.
//  Copyright © 2019 hang yang. All rights reserved.
//

import UIKit

class AvatarCell: UITableViewCell {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var questionTitleLabel: UILabel!
    
    func setAvatar(avatar: Avatar) {
        avatarImageView.image = avatar.image
        questionTitleLabel.text = avatar.title
    }
    
}
