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
        // Initialization code
    }
    
    func configure(with comment: Comment) {
        usernameLabel.text = comment.username
        commentLabel.text = comment.text
        AvatarManager.loadAvatar(from: comment.profilePictureURL, into: avatarImageView)
    }
    
}
