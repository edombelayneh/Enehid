//
//  StoryCell.swift
//  Enehid
//
//  Created by Edom Belayneh on 10/10/25.
//

import UIKit

class StoryCell: UICollectionViewCell {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var username: UILabel!
    
    func configure(with story: Story?) {
//        profileImage.image =
        username.text = story?.username
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        profileImage.layer.cornerRadius = profileImage.frame.size.width / 2
        profileImage.clipsToBounds = true
    }

}
