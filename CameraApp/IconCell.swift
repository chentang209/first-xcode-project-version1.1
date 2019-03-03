//
//  IconCell.swift
//  CameraApp
//
//  Created by Hang Yang on 2/26/19.
//  Copyright © 2019 hang yang. All rights reserved.
//

import UIKit

protocol myTableDelegate {
    func myTableDelegate(name: String)
}

class IconCell: UITableViewCell {
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    var delegate: myTableDelegate?
    var cond: Bool = false
    
    func setAvatar(username: String, icon: UIImage, search: Bool) {
        
        iconImageView.image = icon
        usernameLabel.text = username
        cond = search
        
        iconImageView.clipsToBounds = true;
        iconImageView.layer.cornerRadius = iconImageView.layer.frame.size.width/2;
    
    }
    
    override func awakeFromNib() {
        
            super.awakeFromNib()
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapEdit(sender:)))
            addGestureRecognizer(tapGesture)
       
    }
    
    @objc func tapEdit(sender: UITapGestureRecognizer) {
        delegate?.myTableDelegate(name: usernameLabel.text!)
    }
    
}
