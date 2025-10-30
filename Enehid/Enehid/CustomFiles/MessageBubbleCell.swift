//
//  MessageBubbleCell.swift
//  Enehid
//
//  Created by Edom Belayneh on 10/30/25.
//
import UIKit

class MessageBubbleCell: UITableViewCell {
    
    let bubbleBackgroundView = UIView()
    let messageLabel = UILabel()
    let timestampLabel = UILabel()
    let profileImageView = UIImageView()
    
    var isIncoming: Bool = false {
        didSet {
            bubbleBackgroundView.backgroundColor = isIncoming ? UIColor(white: 0.9, alpha: 1) : .systemBlue
            messageLabel.textColor = isIncoming ? .black : .white
            timestampLabel.textColor = .gray

            bubbleLeadingConstraint.isActive = isIncoming
            bubbleTrailingConstraint.isActive = !isIncoming

            profileImageView.isHidden = !isIncoming
        }
    }
    
    var bubbleLeadingConstraint: NSLayoutConstraint!
    var bubbleTrailingConstraint: NSLayoutConstraint!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        
        // Profile Image
        profileImageView.image = UIImage(named: "placeholder") // Set default or load from URL later
        profileImageView.layer.cornerRadius = 15
        profileImageView.clipsToBounds = true
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(profileImageView)

        NSLayoutConstraint.activate([
            profileImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            profileImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            profileImageView.widthAnchor.constraint(equalToConstant: 30),
            profileImageView.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        // Bubble Background
        bubbleBackgroundView.layer.cornerRadius = 16
        bubbleBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(bubbleBackgroundView)
        
        // Message Label
        messageLabel.numberOfLines = 0
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        bubbleBackgroundView.addSubview(messageLabel)

        // Timestamp
        timestampLabel.font = UIFont.systemFont(ofSize: 10)
        timestampLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(timestampLabel)

        // Constraints
        bubbleLeadingConstraint = bubbleBackgroundView.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 12)
        bubbleTrailingConstraint = bubbleBackgroundView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)

        NSLayoutConstraint.activate([
            messageLabel.topAnchor.constraint(equalTo: bubbleBackgroundView.topAnchor, constant: 12),
            messageLabel.bottomAnchor.constraint(equalTo: bubbleBackgroundView.bottomAnchor, constant: -12),
            messageLabel.leadingAnchor.constraint(equalTo: bubbleBackgroundView.leadingAnchor, constant: 16),
            messageLabel.trailingAnchor.constraint(equalTo: bubbleBackgroundView.trailingAnchor, constant: -16),
            
            bubbleBackgroundView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            bubbleBackgroundView.bottomAnchor.constraint(equalTo: timestampLabel.topAnchor, constant: -4),
            bubbleBackgroundView.widthAnchor.constraint(lessThanOrEqualToConstant: 250),
            
            timestampLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            timestampLabel.leadingAnchor.constraint(equalTo: bubbleBackgroundView.leadingAnchor),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with message: Message, currentUserId: String) {
        messageLabel.text = message.text
        isIncoming = message.senderId != currentUserId

        // Format timestamp
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        let date = message.timestamp.dateValue()
        timestampLabel.text = formatter.string(from: date)

        // You can load profile image from URL later if you store it
        // profileImageView.image = ...
    }
}
