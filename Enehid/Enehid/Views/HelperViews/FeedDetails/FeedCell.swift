//
//  FeedCell.swift
//  Enehid
//
//  Created by Edom Belayneh on 10/9/25.
//

import UIKit

class FeedCell: UITableViewCell {
    
    @IBOutlet weak var sharedPostImage: UIImageView!
    
    @IBOutlet weak var bookmarkButton: UIButton!
    @IBOutlet weak var mapsButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    
    @IBOutlet weak var fixMEImageLabel: UILabel!
    
    @IBOutlet weak var detailsLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configure(with post: Post?) {
        usernameLabel.text = post?.username ?? "Unknown"
        detailsLabel.text = post?.caption ?? ""
        sharedPostImage.image = post?.image
        
//        if let date = comment?.commentDate {
//            dateLabel.text = DateFormatter.postFormatter.string(from: date)
//        }
    }

}
