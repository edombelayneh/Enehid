//
//  ReviewsCell.swift
//  Enehid
//
//  Created by Edom Belayneh on 9/4/25.
//

import UIKit

class ReviewsCell: UICollectionViewCell {
    @IBOutlet weak var reviewsImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        reviewsImageView.contentMode = .scaleAspectFill
        reviewsImageView.clipsToBounds = true
    }
}
