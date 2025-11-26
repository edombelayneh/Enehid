//
//  StoryViewController.swift
//  Enehid
//
//  Created by Edom Belayneh on 11/25/25.
//

import UIKit
import PhotosUI
import Firebase
import FirebaseStorage
import FirebaseAuth
import FirebaseFirestore


class StoryPreviewViewController: UIViewController {
    
    @IBOutlet weak var storyImageView: UIImageView!
    var selectedImage: UIImage?
    override func viewDidLoad() {
        super.viewDidLoad()
        super.viewDidLoad()
        storyImageView.image = selectedImage
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func onTapAddToStory(_ sender: UIButton) {
        guard let image = selectedImage,
              let imageData = image.jpegData(compressionQuality: 0.8),
              let userId = Auth.auth().currentUser?.uid else {
            print("Missing image or user.")
            return
        }
        let currUserId = Auth.auth().currentUser?.uid ?? ""
        let db = Firestore.firestore()
        
        // fetch user data
        db.collection("users").document(currUserId).getDocument { (snapshot, error) in
            guard let data = snapshot?.data() else { return }
            let username = data["username"] as? String ?? ""
            let profilePictureURL = data["profilePictureURL"] as? String ?? ""
            
            
            let storyId = UUID().uuidString
            let timestamp = Timestamp(date: Date())
            let storageRef = Storage.storage().reference().child("stories/\(storyId).jpg")
            
            // Upload to Firebase Storage
            storageRef.putData(imageData, metadata: nil) { metadata, error in
                if let error = error {
                    print("Error uploading image: \(error.localizedDescription)")
                    return
                }
                
                // Get the download URL
                storageRef.downloadURL { url, error in
                    if let error = error {
                        print("Error getting download URL: \(error.localizedDescription)")
                        return
                    }
                    
                    guard let downloadURL = url else { return }
                    
                    // Create the story data
                    let storyData: [String: Any] = [
                        "storyImageURL": downloadURL.absoluteString,
                        "ownerId": userId,
                        "username": username,
                        "profilePictureURL": profilePictureURL,
                        "createdAt": timestamp,
                        "storyId": storyId
                    ]
                    
                    
                    // 1. Save to global stories collection
                    db.collection("story").document(storyId).setData(storyData)
                    
                    // 2. Save to user's subcollection
                    db.collection("users").document(userId)
                        .collection("story").document(storyId).setData(storyData) { error in
                            if let error = error {
                                print("Error saving story: \(error.localizedDescription)")
                                return
                            }
                            
                            print("✅ Story uploaded and saved successfully.")
                            
                            // Optional: Alert or pop back
                            let alert = UIAlertController(title: "Added!", message: "Your story has been posted.", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                                self.navigationController?.popToRootViewController(animated: true)
                            })
                            self.present(alert, animated: true)
                        }
                }
            }
        }
    }
}

