//
//  CommentCell.swift
//  Enehid
//
//  Created by Edom Belayneh on 11/26/25.
//

import UIKit

class CommentCell: UITableViewCell {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Round avatar
        //        avatarImageView.layer.cornerRadius = avatarImageView.frame.width / 2
        //        avatarImageView.clipsToBounds = true
        //        avatarImageView.layer.borderWidth = 2
        //        avatarImageView.layer.borderColor = UIColor.textButton.cgColor // or your brand color
        
        // Style cardView
        layer.cornerRadius = 20
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.1
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
        backgroundColor = UIColor.white // or your design background
    }
    
    //    override func layoutSubviews() {
    //        super.layoutSubviews()
    //
    //        // shadow on cell (if you're not styling this in view controller)
    //        layer.shadowColor = UIColor.black.cgColor
    //        layer.shadowOpacity = 0.1
    //        layer.shadowOffset = CGSize(width: 0, height: 2)
    //        layer.shadowRadius = 4
    //        layer.cornerRadius = 20
    //        layer.masksToBounds = false
    //    }
    
    
    
    func configure(with comment: Comment) {
        usernameLabel.text = comment.username
        commentLabel.text = comment.text
        AvatarManager.loadAvatar(from: comment.profilePictureURL, into: avatarImageView)
    }
    
}
