//
//  Plans.swift
//  Enehid
//
//  Created by Edom Belayneh on 9/26/25.
//

import Foundation
import UIKit
import FirebaseAuth


let currUserUID = Auth.auth().currentUser?.uid ?? ""
struct Plans {
    let id: String
    let activityName: String
    let location: String
    let date: String
    let group: String
    let createdBy: String
    
    let participants: [String: String]  // uid: username
    let acceptedByIDs: Set<String>
    let declinedByIDs: Set<String>
    let iAccepted: Bool
    
    var totalCount: Int { participants.count }
    var acceptedCount: Int {
        acceptedByIDs.intersection(participants.keys).count
    }
    var pendingCount: Int { totalCount - acceptedCount }
    var createdByIsMe: Bool { createdBy == currUserUID }
    
    func status(for uid: String) -> ParticipationStatus {
        if acceptedByIDs.contains(uid) {
            return .accepted
        } else if declinedByIDs.contains(uid) {
            return .declined
        } else {
            return .pending
        }
    }

    var participantsByStatus: [ParticipationStatus: [Participant]] {
        var result: [ParticipationStatus: [Participant]] = [
            .accepted: [],
            .pending: [],
            .declined: []
        ]

        for (uid, username) in participants {
            let status = self.status(for: uid)
            result[status, default: []].append(Participant(uid: uid, name: username))
        }
        return result
    }

}

struct Participant {
    let uid: String
    let name: String
}



enum ParticipationStatus {
    case accepted
    case declined
    case pending
}
