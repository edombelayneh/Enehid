//
//  FeedCell.swift
//  Enehid
//
//  Created by Edom Belayneh on 10/9/25.
//

import UIKit
import Firebase

class FeedCell: UITableViewCell, UICollectionViewDelegate {
    
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var profilePictureImageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var postCollectionView: UICollectionView!
    @IBOutlet weak var reecommendButton: UIButton!
    //    @IBOutlet weak var bookmarkButton: UIButton!
    //    @IBOutlet weak var mapsButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    
    @IBOutlet weak var addToPlan: UIButton!
    @IBOutlet weak var detailsLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var bookmarkStatusIcon: UIButton!
    @IBOutlet weak var starStatusIcon: UIButton!

    
    var onRecommendTapped: (() -> Void)?
    var onBookmarkTapped: (() -> Void)?
    var onStarTapped: (() -> Void)?
    var onOpenMapsTapped: ((Memory) -> Void)?
    var onAddToPlanTapped: ((Memory) -> Void)?
    var onCommentTapped: (() -> Void)?

    
    var feedMemory: Memory?
    
    var memoryURLs: [String] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = .clear
        // Collection View setup
        postCollectionView.delegate = self
        postCollectionView.dataSource = self
        postCollectionView.isPagingEnabled = true
        postCollectionView.showsHorizontalScrollIndicator = false
        
        if let layout = postCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.minimumLineSpacing = 0
        }
        
        // ✅ Style the bubble appearance
        contentView.layer.cornerRadius = 30
        contentView.layer.masksToBounds = true // Rounded corners clip subviews
        
        // Add shadow to the CELL layer (not contentView)
        layer.shadowColor = UIColor.systemPurple.cgColor  // Or use UIColor(named: "SoftPurple")
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 10
        layer.masksToBounds = false
    }
    
    
    func configure(with feedMemories: Memory?) {
        self.feedMemory = feedMemories
        
        usernameLabel.text = feedMemories?.username ?? "Unknown"
        detailsLabel.text = feedMemories?.caption ?? ""
        
        if let urls = feedMemories?.memoryURLs {
            self.memoryURLs = urls
            print("memory urls: \(urls)")
            postCollectionView.reloadData()
        }
        
        if let timestamp = feedMemories?.createdAt as? Timestamp {
            let date = timestamp.dateValue()
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            dateLabel.text = formatter.string(from: date)
        }
    }
    
    
    
    @IBAction func onTapRecommendButton(_ sender: UIButton) {
        onRecommendTapped?()
    }
    
    @IBAction func onTapBookmarkButton(_ sender: UIButton) {
        onBookmarkTapped?()
    }
    
    @IBAction func onTapCommentButton(_ sender: UIButton) {
        onCommentTapped?()
    }
    
    @IBAction func onTapAddToPlan(_ sender: UIButton) {
        if let memory = feedMemory {
            onAddToPlanTapped?(memory)
        }
    }
    
    @IBAction func onTapMoreButton(_ sender: UIButton) {
        let menu = UIMenu(title: "", children: [
            UIAction(title: "Star", image: UIImage(systemName: "star")) { [weak self] _ in
                self?.onStarTapped?()
            },
            UIAction(title: "Open in Maps", image: UIImage(systemName: "map")) { [weak self] _ in
                guard let self = self, let memory = self.feedMemory else { return }
                self.onOpenMapsTapped?(memory)
            },
            UIAction(title: "Bookmark", image: UIImage(systemName: "bookmark")) { [weak self] _ in
                self?.onBookmarkTapped?()
            }
        ])
        
        moreButton.showsMenuAsPrimaryAction = true
        moreButton.menu = menu
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let layout = postCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.itemSize = postCollectionView.frame.size
        }
    }
    
    func updateStatusIcons(isBookmarked: Bool, isStarred: Bool) {
        bookmarkStatusIcon.isHidden = !isBookmarked
        starStatusIcon.isHidden = !isStarred
    }

}

extension FeedCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.memoryURLs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MemoryImageCell", for: indexPath) as! MemoryImageCell
        cell.configure(with: memoryURLs[indexPath.item])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let spacer = UIView()
        spacer.backgroundColor = .clear
        return spacer
    }
    
    // Layout for horizontal scrolling
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }
}


