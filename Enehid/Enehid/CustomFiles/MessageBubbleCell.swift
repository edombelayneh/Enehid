//
//  MessageBubbleCell.swift
//  Enehid
//
//  Created by Edom Belayneh on 10/30/25.
//

import UIKit
import FirebaseFirestore

class MessageBubbleCell: UITableViewCell {
    
    private let bubbleBackgroundView = UIView()
    private let messageLabel = UILabel()
    private let timestampLabel = UILabel()
    private let profileImageView = UIImageView()

    private var bubbleLeadingConstraint: NSLayoutConstraint!
    private var bubbleTrailingConstraint: NSLayoutConstraint!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        selectionStyle = .none
        contentView.backgroundColor = UIColor(Theme.creamBackground)
        backgroundColor = .clear

        // MARK: Profile Image
        profileImageView.layer.cornerRadius = 15
        profileImageView.clipsToBounds = true
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(profileImageView)

        NSLayoutConstraint.activate([
            profileImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            profileImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            profileImageView.widthAnchor.constraint(equalToConstant: 30),
            profileImageView.heightAnchor.constraint(equalToConstant: 30)
        ])

        // MARK: Bubble Background
        bubbleBackgroundView.layer.cornerRadius = 18
        bubbleBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(bubbleBackgroundView)

        // MARK: Message Label
        messageLabel.numberOfLines = 0
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        bubbleBackgroundView.addSubview(messageLabel)

        // MARK: Timestamp
        timestampLabel.font = UIFont.systemFont(ofSize: 10)
        timestampLabel.textColor = .gray
        timestampLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(timestampLabel)

        // MARK: Bubble Constraints
        bubbleLeadingConstraint = bubbleBackgroundView.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 12)
        bubbleTrailingConstraint = bubbleBackgroundView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)

        NSLayoutConstraint.activate([
            bubbleBackgroundView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            bubbleBackgroundView.widthAnchor.constraint(lessThanOrEqualToConstant: 250),

            messageLabel.topAnchor.constraint(equalTo: bubbleBackgroundView.topAnchor, constant: 12),
            messageLabel.bottomAnchor.constraint(equalTo: bubbleBackgroundView.bottomAnchor, constant: -12),
            messageLabel.leadingAnchor.constraint(equalTo: bubbleBackgroundView.leadingAnchor, constant: 16),
            messageLabel.trailingAnchor.constraint(equalTo: bubbleBackgroundView.trailingAnchor, constant: -16),
        ])
    }
    
    func configure(with message: Message, currentUserId: String, senderAvatarURL: String?) {
        messageLabel.text = message.text
        let isIncoming = message.senderId != currentUserId

        bubbleBackgroundView.backgroundColor = isIncoming ? UIColor(white: 0.9, alpha: 1) : .systemBlue
        messageLabel.textColor = isIncoming ? .black : .white

        timestampLabel.text = formatTimestamp(message.timestamp)
        timestampLabel.textAlignment = isIncoming ? .left : .right

        // Bubble alignment
        bubbleLeadingConstraint.isActive = isIncoming
        bubbleTrailingConstraint.isActive = !isIncoming

        // Profile avatar
        profileImageView.isHidden = !isIncoming
        if isIncoming {
            if let url = senderAvatarURL {
                AvatarManager.loadAvatar(from: url, into: profileImageView, cropToFace: true)
            } else {
                profileImageView.image = UIImage(named: "avatar_placeholder")
            }
        }

        // Timestamp constraint (remove previous if any)
        timestampLabel.removeFromSuperview()
        contentView.addSubview(timestampLabel)

        timestampLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.deactivate(timestampLabel.constraints)

        NSLayoutConstraint.activate([
            timestampLabel.topAnchor.constraint(equalTo: bubbleBackgroundView.bottomAnchor, constant: 2),
            isIncoming ?
                timestampLabel.leadingAnchor.constraint(equalTo: bubbleBackgroundView.leadingAnchor)
                :
                timestampLabel.trailingAnchor.constraint(equalTo: bubbleBackgroundView.trailingAnchor),
            timestampLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4)
        ])
    }


    private func formatTimestamp(_ timestamp: Timestamp) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: timestamp.dateValue())
    }
}
