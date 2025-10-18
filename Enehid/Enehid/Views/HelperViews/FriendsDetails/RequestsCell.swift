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
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
