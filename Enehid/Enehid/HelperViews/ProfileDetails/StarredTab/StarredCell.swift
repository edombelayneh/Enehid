//
//  StarredCell.swift
//  Enehid
//
//  Created by Edom Belayneh on 9/4/25.
//

import UIKit

class StarredCell: UICollectionViewCell {
    @IBOutlet weak var starredImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        starredImageView.contentMode = .scaleAspectFill
        starredImageView.clipsToBounds = true
    }
}
