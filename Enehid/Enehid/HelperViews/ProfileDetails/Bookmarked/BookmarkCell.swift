//
//  BookmarkedCell.swift
//  Enehid
//
//  Created by Edom Belayneh on 10/26/25.
//

import UIKit
import SDWebImage

class BookmarkCell: UITableViewCell {
    
    
    @IBOutlet weak var memoryImageView: UIImageView!
    @IBOutlet weak var recommendButton: UIButton!
    @IBOutlet weak var addToPlanButton: UIButton!
    @IBOutlet weak var openInMapsButton: UIButton!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var detailsLabel: UILabel!
    @IBOutlet weak var bookmarkedButton: UIButton!
    
    var memory: Memory?
    var onRecommendTapped: (() -> Void)?
    var onBookmarkTapped: (() -> Void)?
    var onOpenMapsTapped: ((Memory) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        memoryImageView.contentMode = .scaleAspectFill
        memoryImageView.clipsToBounds = true
    }
    
    func configure(with bookmarked: Memory?) {
        self.memory = bookmarked
        
        usernameLabel.text = bookmarked?.username ?? "Unknown"
        detailsLabel.text = bookmarked?.caption ?? ""
        
        // ✅ Load image with SDWebImage
        if let urlString = bookmarked?.memoryURLs.first,
           let url = URL(string: urlString) {
            memoryImageView.sd_setImage(with: url, placeholderImage: UIImage(named: "placeholder"))
        } else {
            memoryImageView.image = UIImage(named: "placeholder")
        }
    }
    
    
    @IBAction func onTapRecommend(_ sender: UIButton) {
        onRecommendTapped?()
    }
    @IBAction func onTapOpenInMaps(_ sender: UIButton) {
        if let memory = memory {
            onOpenMapsTapped?(memory)
        }
    }
    @IBAction func onTapAddToPlans(_ sender: UIButton) {
    }
    @IBAction func onTapBookmark(_ sender: UIButton) {
        onBookmarkTapped?()
    }
}
