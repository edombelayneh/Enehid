//
//  FeedCell.swift
//  Enehid
//
//  Created by Edom Belayneh on 10/9/25.
//

import UIKit

class FeedCell: UITableViewCell, UICollectionViewDelegate {
    
    @IBOutlet weak var postCollectionView: UICollectionView!
    @IBOutlet weak var reecommendButton: UIButton!
    @IBOutlet weak var bookmarkButton: UIButton!
    @IBOutlet weak var mapsButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    
    @IBOutlet weak var detailsLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    
    var onRecommendTapped: (() -> Void)?
    var onBookmarkTapped: (() -> Void)?
    
    var memoryURLs: [String] = []
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        postCollectionView.delegate = self
        postCollectionView.dataSource = self
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
        onRecommendTapped?()
    }
    
    @IBAction func onTapBookmarkButton(_ sender: UIButton) {
        onBookmarkTapped?()
    }
    
    
}

extension FeedCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.memoryURLs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FeedCollectionCell", for: indexPath) as! FeedCollectionCell
        cell.configure(with: memoryURLs[indexPath.item])
        return cell
    }
    
    // Layout for horizontal scrolling
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }
}
