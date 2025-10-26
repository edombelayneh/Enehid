//
//  PostDetailViewController.swift
//  Enehid
//
//  Created by Edom Belayneh on 10/10/25.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class PostDetailViewController: UIViewController {

    
    
    @IBOutlet weak var createStarred: UIButton!
    @IBOutlet weak var addToBookmarkButton: UIButton!
    @IBOutlet weak var showOnMapsButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var addToPlansButton: UIButton!
    @IBOutlet weak var recommendButton: UIButton!
    
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var postImage: UIImageView!
    
    var feedMemories: Memory?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        captionLabel.text = feedMemories?.caption
        usernameLabel.text = feedMemories?.username
//        postImage.image = feedMemories?.image
    }
    
    
    @IBAction func onTapAddToPlans(_ sender: UIButton) {
    }
    @IBAction func onTapComment(_ sender: UIButton) {
    }
    @IBAction func onTapOpenInMap(_ sender: UIButton) {
    }
    @IBAction func onTapRecommend(_ sender: UIButton) {
    }
    
    @IBAction func onTapBookmarked(_ sender: UIButton) {
    }
    @IBAction func onTapCreateStarred(_ sender: UIButton) {
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func recommendPost(memoryId: String) {
        guard let currentUID = Auth.auth().currentUser?.uid else { return }
        
        let db = Firestore.firestore()
        
        let recommendRef = db.collection("users").document(currentUID).collection("recommends").document(memoryId)
        
        recommendRef.setData([
            "recommendId": memoryId,
            "recommendedAt": Timestamp()
        ]) { error in
            if let error = error {
                print("❌ Failed to recommend: \(error.localizedDescription)")
            } else {
                print("✅ Post \(memoryId) recommended by user \(currentUID)")
            }
        }
        
    }
    
    func unrecommendPost(memoryId: String){
        guard let currentUID = Auth.auth().currentUser?.uid else { return }
        
        let db = Firestore.firestore()
        
        db.collection("users").document(currentUID).collection("recommends").document(memoryId).delete { error in
            if let error = error {
                print("❌ Failed to un-recommend: \(error.localizedDescription)")
            } else {
                print("✅ Post \(memoryId) un-recommended")
            }
        }
    }

}
