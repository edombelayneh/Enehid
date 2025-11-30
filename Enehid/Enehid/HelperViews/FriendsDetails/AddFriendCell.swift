//
//  AddFriendCell.swift
//  Enehid
//
//  Created by Edom Belayneh on 10/18/25.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class AddFriendCell: UITableViewCell {

    @IBOutlet weak var addFriendButton: UIButton!
    @IBOutlet weak var bioLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var profilePicImageView: UIImageView!
    
    var onAddTapped: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addShadowToAvatar(profilePicImageView)
        setupCardStyle()
    }
    
    private func addShadowToAvatar(_ imageView: UIImageView) {
        imageView.layer.shadowColor = UIColor.textButton.cgColor
        imageView.layer.shadowOpacity = 0.5
        imageView.layer.shadowOffset = CGSize(width: 0, height: 3)
        imageView.layer.shadowRadius = 6
        imageView.layer.masksToBounds = false
    }
    
    private func setupCardStyle() {
        // Rounded corners
        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = true

        // Shadow on cell (not clipped by contentView)
        layer.shadowColor = UIColor.textButton.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 16
        layer.masksToBounds = false
        layer.cornerRadius = 16
    }
    
    
    @IBAction func onTapAddFriend(_ sender: UIButton) {
        onAddTapped?()
    }
    
}
