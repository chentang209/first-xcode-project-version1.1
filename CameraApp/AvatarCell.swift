//
//  AvatarCell.swift
//  CameraApp
//
//  Created by Hang Yang on 2/25/19.
//  Copyright © 2019 hang yang. All rights reserved.
//

protocol avatarDelegate {
    func avatarDelegate(title: String)
}

import UIKit

class AvatarCell: UITableViewCell {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var questionTitleLabel: UILabel!
    var delegate: avatarDelegate?
    
    func setAvatar1(profile: Avatar) {
        
        avatarImageView.image = profile.image
        questionTitleLabel.text = profile.title
        
        self.backgroundView = UIImageView(image: UIImage(named: "wood2")!)
        
    }
    
    func setAvatar2(rx: Avatar) {
        
        avatarImageView.image = rx.image
        questionTitleLabel.text = rx.title
        
        avatarImageView.clipsToBounds = true
        avatarImageView.layer.cornerRadius = avatarImageView.layer.frame.size.width/2
        self.backgroundView = UIImageView(image: UIImage(named: "wood2")!)
        
    }
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapEdit(sender:)))
        addGestureRecognizer(tapGesture)
        
    }
    
    @objc func tapEdit(sender: UITapGestureRecognizer) {
        delegate?.avatarDelegate(title: questionTitleLabel.text!)
    }
    
}
