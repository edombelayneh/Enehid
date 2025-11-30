//
//  RequestsCell.swift
//  Enehid
//
//  Created by Edom Belayneh on 10/18/25.
//

import UIKit

class RequestsCell: UITableViewCell {

    @IBOutlet weak var denyFriendButton: UIButton!
    @IBOutlet weak var addFriendButton: UIButton!
    @IBOutlet weak var bioLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var profilePicImageView: UIImageView!
    
    var onAddTapped: (() -> Void)?
    var onDenyTapped: (() -> Void)?
    
    override func awakeFromNib() {
        addShadowToAvatar(profilePicImageView)
    }
    
    private func addShadowToAvatar(_ imageView: UIImageView) {
        imageView.layer.shadowColor = UIColor.textButton.cgColor
        imageView.layer.shadowOpacity = 0.5
        imageView.layer.shadowOffset = CGSize(width: 0, height: 3)
        imageView.layer.shadowRadius = 6
        imageView.layer.masksToBounds = false
    }
    
    @IBAction func onTapAddButton(_ sender: UIButton) {
        onAddTapped?()
    }
    
    @IBAction func onTapDenyButton(_ sender: UIButton) {
        onDenyTapped?()
    }
}
