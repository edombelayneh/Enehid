//
//  FriendsCell.swift
//  Enehid
//
//  Created by Edom Belayneh on 9/26/25.
//

import UIKit

class FriendsCell: UITableViewCell {

    @IBOutlet weak var profilePicture: UIImageView!
    
    @IBOutlet weak var messagePreviewLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    
    override func awakeFromNib() {
        addShadowToAvatar(profilePicture)
    }
    
    private func addShadowToAvatar(_ imageView: UIImageView) {
        imageView.layer.shadowColor = UIColor.textButton.cgColor
        imageView.layer.shadowOpacity = 0.5
        imageView.layer.shadowOffset = CGSize(width: 0, height: 3)
        imageView.layer.shadowRadius = 6
        imageView.layer.masksToBounds = false
    }

}
