//
//  CollectionViewCell.swift
//  Enehid
//
//  Created by Edom Belayneh on 11/23/25.
//

import UIKit
import SDWebImage

class MemoryImageCell: UICollectionViewCell {
    
    @IBOutlet weak var memoryImageView: UIImageView!
    
    func configure(with urlString: String) {
        if let url = URL(string: urlString) {
            memoryImageView.contentMode = .scaleAspectFill
            memoryImageView.clipsToBounds = true
            memoryImageView.sd_setImage(with: url, placeholderImage: UIImage(named: "placeholder"))
        }
    }


}
