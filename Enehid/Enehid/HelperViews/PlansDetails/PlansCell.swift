//
//  PlansCell.swift
//  Enehid
//
//  Created by Edom Belayneh on 9/26/25.

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
        backgroundColor = .clear
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 20
        contentView.layer.masksToBounds = true

        let shadowView = UIView()
        shadowView.backgroundColor = .clear
        shadowView.layer.shadowColor = UIColor.black.cgColor
        shadowView.layer.shadowOpacity = 0.05
        shadowView.layer.shadowOffset = CGSize(width: 0, height: 2)
        shadowView.layer.shadowRadius = 6
        shadowView.layer.cornerRadius = 29
        shadowView.translatesAutoresizingMaskIntoConstraints = false

        insertSubview(shadowView, belowSubview: contentView)
        NSLayoutConstraint.activate([
            shadowView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            shadowView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            shadowView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            shadowView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
        ])
        
        activityLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        locationLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        dateLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        createdByLabel.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        createdByLabel.textColor = .purple
        waitingLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        waitingLabel.textColor = .gray

        acceptButton.setTitle("✓", for: .normal)
        acceptButton.setTitleColor(.systemGreen, for: .normal)
        acceptButton.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        acceptButton.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.1)
        acceptButton.layer.cornerRadius = 16
        acceptButton.addTarget(self, action: #selector(didTapAccept), for: .touchUpInside)

        declineButton.setTitle("✗", for: .normal)
        declineButton.setTitleColor(.systemRed, for: .normal)
        declineButton.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        declineButton.backgroundColor = UIColor.systemRed.withAlphaComponent(0.1)
        declineButton.layer.cornerRadius = 16
        declineButton.addTarget(self, action: #selector(didTapDecline), for: .touchUpInside)
    
        acceptButton.translatesAutoresizingMaskIntoConstraints = false
        declineButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            acceptButton.widthAnchor.constraint(equalToConstant: 32),
            acceptButton.heightAnchor.constraint(equalToConstant: 32),
            declineButton.widthAnchor.constraint(equalToConstant: 32),
            declineButton.heightAnchor.constraint(equalToConstant: 32),
        ])

        buttonStack.axis = .vertical
//        buttonStack.alignment = .center
        buttonStack.alignment = .trailing
        buttonStack.spacing = 10
        buttonStack.addArrangedSubview(acceptButton)
        buttonStack.addArrangedSubview(declineButton)

        let textStack = UIStackView(arrangedSubviews: [activityLabel, locationLabel, dateLabel, createdByLabel, waitingLabel])
        textStack.axis = .vertical
        textStack.spacing = 6

//        mainStack.axis = .horizontal
//        mainStack.spacing = 24
//        mainStack.alignment = .center
//        mainStack.translatesAutoresizingMaskIntoConstraints = false
//        mainStack.addArrangedSubview(textStack)
//        mainStack.addArrangedSubview(buttonStack)
        
        // Wrap buttonStack in a right-aligned container
        let buttonContainer = UIView()
        buttonContainer.translatesAutoresizingMaskIntoConstraints = false
        buttonContainer.addSubview(buttonStack)

        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            buttonStack.topAnchor.constraint(equalTo: buttonContainer.topAnchor),
            buttonStack.trailingAnchor.constraint(equalTo: buttonContainer.trailingAnchor),
            buttonStack.bottomAnchor.constraint(equalTo: buttonContainer.bottomAnchor)
        ])

        mainStack.axis = .horizontal
        mainStack.spacing = 12
        mainStack.alignment = .center
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        mainStack.addArrangedSubview(textStack)
        mainStack.addArrangedSubview(buttonContainer)


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
                waitingLabel.textColor = .red
                acceptButton.isHidden = false
            } else {
                waitingLabel.text = "Waiting for you"
                waitingLabel.textColor = .blue
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

