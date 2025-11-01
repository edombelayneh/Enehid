//
//  FeedCollectionCell.swift
//  Enehid
//
//  Created by Edom Belayneh on 11/1/25.
//

import UIKit

class FeedCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var postImageView: UIImageView!
    func configure(with url: String) {
            // If using SDWebImage or similar
            if let imageURL = URL(string: url) {
                postImageView.sd_setImage(with: imageURL, placeholderImage: UIImage(named: "placeholder"))
            }
        }
}
