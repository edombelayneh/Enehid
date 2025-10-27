//
//  PlansCell.swift
//  Enehid
//
//  Created by Edom Belayneh on 9/26/25.
//

import UIKit

class PlansCell: UITableViewCell {

    
    @IBOutlet weak var ownerControlsView: UIView?
    @IBOutlet weak var inviteeStatusView: UIView?
    @IBOutlet weak var waitingLabel: UILabel?
    @IBOutlet weak var declineButton: UIButton?
    @IBOutlet weak var acceptButton: UIButton?
    
    
//    @IBOutlet weak var profileUIImageVIew: UIImageView!
    @IBOutlet weak var createdBy: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var activityNameLabel: UILabel!
    
    var onAccept: (() -> Void)?
    var onDecline: (() -> Void)?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        // Reset everything so reuse can’t leak state
        ownerControlsView?.isHidden = true
        inviteeStatusView?.isHidden = false
        acceptButton?.isHidden = true
        declineButton?.isHidden = true
    }
    
    @IBAction func didTapAcceptButton(_ sender: UIButton) {
        print("✅ accept tapped")
        onAccept?()
    }
 
    @IBAction func didTapDeclineButton(_ sender: UIButton) {
        print("❌ decline tapped")
        onDecline?()
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
