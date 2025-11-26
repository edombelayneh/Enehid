//
//  StoryCell.swift
//  Enehid
//
//  Created by Edom Belayneh on 10/10/25.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class StoryCell: UICollectionViewCell {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var username: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = .clear
        
        // Make the profile image a perfect circle
        profileImage.layer.cornerRadius = profileImage.frame.size.width / 2
        profileImage.clipsToBounds = true
        
        // Round the card / bubble look
        contentView.layer.cornerRadius = 30
        contentView.layer.masksToBounds = false
        
        // Set background color so the cell looks like a bubble
        contentView.backgroundColor = .white // or .systemBackground, or your theme
        
        // Add drop shadow around the bubble (not clipped)
        layer.shadowColor = UIColor.systemPurple.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: 0, height: 3)
        layer.shadowRadius = 6
        layer.masksToBounds = false
    }
    
    
    func configure(with story: Story?) {
        guard let story = story else { return }
        username.text = story.username
        
        if let avatarURL = story.profilePictureURL {
            AvatarManager.loadAvatar(from: avatarURL, into: profileImage, cropToFace: true)
        } else {
            // Optional: fallback to loading from user document
            fetchProfileURL(for: story.ownerId) { url in
                if let url = url {
                    AvatarManager.loadAvatar(from: url, into: self.profileImage, cropToFace: true)
                }
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: 20).cgPath
    }
    
    
    private func fetchProfileURL(for uid: String, completion: @escaping (String?) -> Void) {
        Firestore.firestore().collection("users").document(uid).getDocument { snapshot, error in
            if let data = snapshot?.data(), let url = data["profilePictureURL"] as? String {
                completion(url)
            } else {
                completion(nil)
            }
        }
    }
    
}
