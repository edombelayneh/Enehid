//
//  SectionHeaderView.swift
//  Enehid
//
//  Created by Edom Belayneh on 11/9/25.
//

import UIKit

class SectionHeaderView: UICollectionReusableView {
        
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.font = UIFont.boldSystemFont(ofSize: 10)
        titleLabel.textColor = UIColor.darkGray
    }

}
