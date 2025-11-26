//
//  StoryDetailsViewController.swift
//  Enehid
//
//  Created by Edom Belayneh on 10/10/25.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class StoryDetailsViewController: UIViewController {

    @IBOutlet weak var likeButton: UIButton!
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var profilePicImage: UIImageView!
    @IBOutlet weak var storyImage: UIImageView!
    
    var story: Story?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        profilePicImage.layer.cornerRadius = profilePicImage.frame.size.width / 2
        profilePicImage.clipsToBounds = true

        // ✅ Set username
        usernameLabel.text = story?.username ?? "Unknown"

        // ✅ Load profile picture
        if let avatarURL = story?.profilePictureURL {
            AvatarManager.loadAvatar(from: avatarURL, into: profilePicImage, cropToFace: true)
        } else if let ownerId = story?.ownerId {
            fetchAvatar(for: ownerId) { url in
                if let url = url {
                    AvatarManager.loadAvatar(from: url, into: self.profilePicImage, cropToFace: true)
                }
            }
        }

        // ✅ Load story image
        if let mediaURL = story?.mediaURL, let url = URL(string: mediaURL) {
            URLSession.shared.dataTask(with: url) { data, _, error in
                if let error = error {
                    print("❌ Error loading story image: \(error.localizedDescription)")
                    return
                }

                guard let data = data, let image = UIImage(data: data) else {
                    print("❌ Could not convert data to image.")
                    return
                }

                DispatchQueue.main.async {
                    self.storyImage.image = image
                }
            }.resume()
        }
    }


    private func fetchAvatar(for uid: String, completion: @escaping (String?) -> Void) {
        Firestore.firestore().collection("users").document(uid).getDocument { snapshot, error in
            if let data = snapshot?.data(), let url = data["profilePictureURL"] as? String {
                completion(url)
            } else {
                completion(nil)
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
//    */
//    func configure(with story: Story?){
//        
//    }

}
