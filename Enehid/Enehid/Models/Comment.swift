//
//  Comment.swift
//  Enehid
//
//  Created by Edom Belayneh on 11/26/25.
//

// approved for firestore
import Foundation
import FirebaseFirestore

struct Comment {
    var username: String
    var text: String
    var timestamp: Timestamp
    var userId: String
    var profilePictureURL: String?
}

