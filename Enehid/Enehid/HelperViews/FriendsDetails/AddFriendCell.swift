//
//  AddFriendCell.swift
//  Enehid
//
//  Created by Edom Belayneh on 10/18/25.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class AddFriendCell: UITableViewCell {

    @IBOutlet weak var addFriendButton: UIButton!
    @IBOutlet weak var bioLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var profilePicImageView: UIImageView!
    
    var onAddTapped: (() -> Void)?

//    func configure(with searchResults: User?) {
//        usernameLabel.text = searchResults?.username ?? "Unknown"
////        bioLabel.text = searchResults? ?? ""
////        sharedPostImage.image = feedMemories?.image
//        
////        if let date = comment?.commentDate {
////            dateLabel.text = DateFormatter.postFormatter.string(from: date)
////        }
//    }
    
    @IBAction func onTapAddFriend(_ sender: UIButton) {
        onAddTapped?()
    }
    
}
