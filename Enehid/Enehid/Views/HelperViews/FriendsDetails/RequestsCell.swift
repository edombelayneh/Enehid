//
//  RequestsCell.swift
//  Enehid
//
//  Created by Edom Belayneh on 10/18/25.
//

import UIKit

class RequestsCell: UITableViewCell {

    @IBOutlet weak var denyFriendButton: UIButton!
    @IBOutlet weak var addFriendButton: UIButton!
    @IBOutlet weak var bioLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var profilePicImageView: UIImageView!
    
    var onAddTapped: (() -> Void)?
    var onDenyTapped: (() -> Void)?
    
    
    @IBAction func onTapAddButton(_ sender: UIButton) {
        onAddTapped?()
    }
    
    @IBAction func onTapDenyButton(_ sender: UIButton) {
        onDenyTapped?()
    }
}
