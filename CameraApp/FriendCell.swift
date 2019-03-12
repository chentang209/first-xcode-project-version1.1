//
//  FriendCell.swift
//  CameraApp
//
//  Created by Hang Yang on 3/1/19.
//  Copyright © 2019 hang yang. All rights reserved.
//

import UIKit

protocol tableDelegate {
    func myTableDelegate(id: String, icon:UIImage)
}

class FriendCell: UITableViewCell {
    
    @IBOutlet weak var friendIcon: UIImageView!
    @IBOutlet weak var friendName: UILabel!
    
    var delegate: tableDelegate?
    
    func setAvatar(username: String, icon: UIImage) {
        friendIcon.image = icon
        friendName.text = username
        
        friendIcon.clipsToBounds = true;
        friendIcon.layer.cornerRadius = friendIcon.layer.frame.size.width/2;
    }
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapEdit(sender:)))
        addGestureRecognizer(tapGesture)
       
    }
    
    @objc func tapEdit(sender: UITapGestureRecognizer) {
        delegate?.myTableDelegate(id: friendName.text!,icon: friendIcon.image!)
    }
    
    
}
