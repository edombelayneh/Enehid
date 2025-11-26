//
//  MemoryCell.swift
//  Enehid
//
//  Created by Edom Belayneh on 9/4/25.
//

import UIKit

class MemoryCell: UICollectionViewCell {
    
    @IBOutlet weak var memoryImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        memoryImageView.contentMode = .scaleAspectFill
        memoryImageView.clipsToBounds = true
    }


}
