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
        profileImage.layer.cornerRadius = profileImage.frame.size.width / 2
        profileImage.clipsToBounds = true
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
