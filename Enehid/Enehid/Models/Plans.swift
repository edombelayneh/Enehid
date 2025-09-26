//
//  Plans.swift
//  Enehid
//
//  Created by Edom Belayneh on 9/26/25.
//

import Foundation
import UIKit

struct Plans {
    let id: String
    let activityName: String
    let location: String
    let date: String
    let group: String
    let createdBy: String
    
    let participants: [Friends]
    
    let acceptedByIDs: Set<String>
    let iAccepted: Bool
    
    var totalCount: Int { participants.count }
    var acceptedCount: Int {
            participants.reduce(0) { $0 + (acceptedByIDs.contains($1.id) ? 1 : 0) }
        }
    var pendingCount: Int { totalCount - acceptedCount }
    var createdByIsMe: Bool { createdBy == currUser }
}

enum ParticipationStatus {
    case accepted
    case declined
    case pending
}

let currUser = "edom_ybb"


// handy lookup
func friend(byUsername u: String) -> Friends? {
    mockFriends.first { $0.username == u }
}

let mockPlans: [Plans] = [
    Plans(
        id: "plan_1",
        activityName: "Bible Study",
        location: "Fabiano Gardens",
        date: "09/29/2025",
        group: "The Girls",
        createdBy: "jannet",
        participants: [
            friend(byUsername: "jannet"),
            friend(byUsername: "jane_doe"),
            friend(byUsername: "edom_ybb")
        ].compactMap { $0 },
        acceptedByIDs: [],                  // nobody accepted yet
        iAccepted: false                        // you haven’t accepted
    ),
    Plans(
        id: "plan_2",
        activityName: "Coffee Date",
        location: "Lansing",
        date: "09/21/2025",
        group: "LOML",
        createdBy: "john_doe",
        participants: [
            friend(byUsername: "john_doe"),
            friend(byUsername: "edom_ybb")
        ].compactMap { $0 },
        acceptedByIDs: ["fr_1"],           // john_doe accepted
        iAccepted: true                         // you accepted
    ),
    Plans(
        id: "plan_3",
        activityName: "Tennis",
        location: "SAC",
        date: "10/20/2025",
        group: "Class",
        createdBy: "edom_ybb",         // you created this one
        participants: [
            friend(byUsername: "jane_doe"),
            friend(byUsername: "john_doe"),
            friend(byUsername: "jannet")
        ].compactMap { $0 },
        acceptedByIDs: ["fr_2", "fr_1", "fr_3"], // all invited friends accepted
        iAccepted: true
    )
]
