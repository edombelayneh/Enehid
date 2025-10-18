//
//  FeedCell.swift
//  Enehid
//
//  Created by Edom Belayneh on 10/9/25.
//

import UIKit

class FeedCell: UITableViewCell {
    
    @IBOutlet weak var sharedPostImage: UIImageView!
    
    @IBOutlet weak var reecommendButton: UIButton!
    @IBOutlet weak var bookmarkButton: UIButton!
    @IBOutlet weak var mapsButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    
    @IBOutlet weak var detailsLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configure(with feedMemories: Memory?) {
        usernameLabel.text = feedMemories?.username ?? "Unknown"
        detailsLabel.text = feedMemories?.caption ?? ""
//        sharedPostImage.image = feedMemories?.image
        
//        if let date = comment?.commentDate {
//            dateLabel.text = DateFormatter.postFormatter.string(from: date)
//        }
    }
    
    
    @IBAction func onTapRecommendButton(_ sender: UIButton) {
    }
    
    @IBAction func onTapBookmarkButton(_ sender: UIButton) {
    }
    
}
