////
////  PlansCell.swift
////  Enehid
////
////  Created by Edom Belayneh on 9/26/25.
////
//
//import UIKit
//
//class PlansCell: UITableViewCell {
//
//    
//    @IBOutlet weak var ownerControlsView: UIView?
//    @IBOutlet weak var inviteeStatusView: UIView?
//    @IBOutlet weak var waitingLabel: UILabel?
//    @IBOutlet weak var declineButton: UIButton?
//    @IBOutlet weak var acceptButton: UIButton?
//    
//    
////    @IBOutlet weak var profileUIImageVIew: UIImageView!
//    @IBOutlet weak var createdBy: UILabel!
//    @IBOutlet weak var dateLabel: UILabel!
//    @IBOutlet weak var locationLabel: UILabel!
//    @IBOutlet weak var activityNameLabel: UILabel!
//    
//    var onAccept: (() -> Void)?
//    var onDecline: (() -> Void)?
//    
//    override func prepareForReuse() {
//        super.prepareForReuse()
//        
//        ownerControlsView?.isHidden = true
//        inviteeStatusView?.isHidden = true
//        
//        acceptButton?.isHidden = true
//        declineButton?.isHidden = true
//        
//        waitingLabel?.text = nil
//        onAccept = nil
//        onDecline = nil
//    }
//
//
//    @IBAction func didTapAcceptButton(_ sender: UIButton) {
//        print("✅ accept tapped")
//        onAccept?()
//    }
// 
//    @IBAction func didTapDeclineButton(_ sender: UIButton) {
//        print("❌ decline tapped")
//        onDecline?()
//    }
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        // Initialization code
//    }
//
//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//        // Configure the view for the selected state
//    }
//
//}

import UIKit

class PlanCell: UITableViewCell {

    // MARK: - UI Elements
    let activityLabel = UILabel()
    let locationLabel = UILabel()
    let dateLabel = UILabel()
    let createdByLabel = UILabel()
    let waitingLabel = UILabel()

    let acceptButton = UIButton(type: .system)
    let declineButton = UIButton(type: .system)

    private let buttonStack = UIStackView()
    private let mainStack = UIStackView()

    var onAccept: (() -> Void)?
    var onDecline: (() -> Void)?

    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI Setup
    private func setupUI() {
        activityLabel.font = UIFont.boldSystemFont(ofSize: 16)
        locationLabel.font = UIFont.systemFont(ofSize: 14)
        dateLabel.font = UIFont.systemFont(ofSize: 14)
        createdByLabel.font = UIFont.systemFont(ofSize: 12)
        createdByLabel.textColor = .purple
        waitingLabel.font = UIFont.systemFont(ofSize: 13)
        waitingLabel.textColor = .gray

        acceptButton.setTitle("✓", for: .normal)
        acceptButton.setTitleColor(.systemGreen, for: .normal)
        acceptButton.addTarget(self, action: #selector(didTapAccept), for: .touchUpInside)

        declineButton.setTitle("✗", for: .normal)
        declineButton.setTitleColor(.systemRed, for: .normal)
        declineButton.addTarget(self, action: #selector(didTapDecline), for: .touchUpInside)

        buttonStack.axis = .horizontal
        buttonStack.spacing = 10
        buttonStack.addArrangedSubview(acceptButton)
        buttonStack.addArrangedSubview(declineButton)

        let textStack = UIStackView(arrangedSubviews: [activityLabel, locationLabel, dateLabel, createdByLabel, waitingLabel])
        textStack.axis = .vertical
        textStack.spacing = 4

        mainStack.axis = .horizontal
        mainStack.spacing = 16
        mainStack.alignment = .center
        mainStack.translatesAutoresizingMaskIntoConstraints = false

        mainStack.addArrangedSubview(textStack)
        mainStack.addArrangedSubview(buttonStack)

        contentView.addSubview(mainStack)
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            mainStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            mainStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
        ])
    }

    // MARK: - Configure Cell
    func configure(with plan: Plans, currentUserId: String) {
        activityLabel.text = plan.activityName
        locationLabel.text = plan.location
        dateLabel.text = formatDate(plan.date)
        createdByLabel.text = plan.createdBy == currentUserId
            ? "Scheduled by You"
            : "Scheduled by @\(plan.participants[plan.createdBy] ?? String(plan.createdBy.prefix(5)))"

        let isOwner = plan.createdBy == currentUserId
        let accepted = plan.acceptedByIDs.contains(currentUserId)
        let declined = plan.declinedByIDs.contains(currentUserId)

        // Reset hidden state
        acceptButton.isHidden = true
        declineButton.isHidden = true
        waitingLabel.isHidden = false

        if isOwner {
            waitingLabel.text = "\(plan.acceptedByIDs.count)/\(plan.participants.count) friends accepted"
        } else {
            if accepted {
                waitingLabel.text = "Waiting For Friends"
            } else if declined {
                waitingLabel.text = "You declined"
                acceptButton.isHidden = false
            } else {
                waitingLabel.text = "Waiting for you"
                acceptButton.isHidden = false
                declineButton.isHidden = false
            }
        }
    }

    // MARK: - Actions
    @objc private func didTapAccept() {
        onAccept?()
    }

    @objc private func didTapDecline() {
        onDecline?()
    }

    private func formatDate(_ rawDate: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd HH:mm"

        let outputFormatter = DateFormatter()
        outputFormatter.dateStyle = .medium
        outputFormatter.timeStyle = .none

        if let date = inputFormatter.date(from: rawDate) {
            return outputFormatter.string(from: date)
        } else {
            return rawDate
        }
    }
}

