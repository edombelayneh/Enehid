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
    @IBOutlet weak var withdrawButton: UIButton!
    @IBOutlet weak var profilePicImageView: UIImageView!
    
    var onAddTapped: (() -> Void)?
    var onDenyTapped: (() -> Void)?
    var onWithdrawTapped: (() -> Void)?
    
    override func awakeFromNib() {
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
    
    @IBAction func onTapAddButton(_ sender: UIButton) {
        onAddTapped?()
    }
    
    @IBAction func onTapDenyButton(_ sender: UIButton) {
        onDenyTapped?()
    }
    
    
    @IBAction func onTapWithdrawButton(_ sender: UIButton) {
        onWithdrawTapped?()
    }
}
