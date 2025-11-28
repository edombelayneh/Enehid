//
//  InviteFriendsCell.swift
//  Enehid
//
//  Created by Edom Belayneh on 11/14/25.
//

import UIKit

class InviteFriendsCell: UICollectionViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Optional: round imageView (face crop already handled)
        imageView.layer.cornerRadius = imageView.frame.width / 2
        imageView.clipsToBounds = true
        
        // Style the entire cell
        contentView.layer.cornerRadius = 12
        contentView.layer.shadowColor = UIColor.textButton.cgColor
        contentView.layer.shadowOpacity = 0.5
        contentView.layer.shadowOffset = CGSize(width: 0, height: 2)
        contentView.layer.shadowRadius = 4
        contentView.layer.masksToBounds = false  // Important for shadow!
        
        // Optional: background color
        contentView.backgroundColor = .clear
    }
}
