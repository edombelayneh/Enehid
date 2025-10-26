//
//  BookmarkedCell.swift
//  Enehid
//
//  Created by Edom Belayneh on 10/26/25.
//

import UIKit

class BookmarkCell: UITableViewCell {

    
    @IBOutlet weak var memoryImageView: UIImageView!

    
    @IBOutlet weak var recommendButton: UIButton!
    @IBOutlet weak var openInMapsButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var detailsLabel: UILabel!
    @IBOutlet weak var bookmarkedButton: UIButton!
    var onRecommendTapped: (() -> Void)?
    var onBookmarkTapped: (() -> Void)?
    func configure(with bookmarked: Memory?) {
        usernameLabel.text = bookmarked?.username ?? "Unknown"
        detailsLabel.text = bookmarked?.caption ?? ""
//        sharedPostImage.image = feedMemories?.image
        
//        if let date = comment?.commentDate {
//            dateLabel.text = DateFormatter.postFormatter.string(from: date)
//        }
    }

    
    @IBAction func onTapRecommend(_ sender: UIButton) {
        onRecommendTapped?()
    }
    @IBAction func onTapOpenInMaps(_ sender: UIButton) {
    }
    @IBAction func onTapComment(_ sender: UIButton) {
    }
    @IBAction func onTapBookmark(_ sender: UIButton) {
        onBookmarkTapped?()
    }
}
