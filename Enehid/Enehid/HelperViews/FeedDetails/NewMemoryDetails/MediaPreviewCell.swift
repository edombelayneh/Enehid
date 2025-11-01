//
//  MediaPreviewCell.swift
//  Enehid
//
//  Created by Edom Belayneh on 11/1/25.
//

import UIKit

class MediaPreviewCell: UICollectionViewCell {
    
    @IBOutlet weak var mediaImageView: UIImageView!
    
    func configure(with image: UIImage) {
        mediaImageView.image = image
        mediaImageView.contentMode = .scaleAspectFill
        mediaImageView.clipsToBounds = true
    }
}
