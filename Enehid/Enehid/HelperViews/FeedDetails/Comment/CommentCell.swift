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
        
        // Style cardView
        layer.cornerRadius = 20
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.1
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
        backgroundColor = UIColor.white // or your design background
        addShadowToAvatar(avatarImageView)
    }
    
    private func addShadowToAvatar(_ imageView: UIImageView) {
        imageView.layer.shadowColor = UIColor.textButton.cgColor
        imageView.layer.shadowOpacity = 0.5
        imageView.layer.shadowOffset = CGSize(width: 0, height: 3)
        imageView.layer.shadowRadius = 6
        imageView.layer.masksToBounds = false
    }
    
    
    
    func configure(with comment: Comment) {
        usernameLabel.text = comment.username
        commentLabel.text = comment.text
        AvatarManager.loadAvatar(from: comment.profilePictureURL, into: avatarImageView)
    }
    
}
