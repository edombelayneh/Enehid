//
//  Friends.swift
//  Enehid
//
//  Created by Edom Belayneh on 9/26/25.
//
// approved for firebase
import Foundation
import FirebaseFirestore

struct Message {
    let id: String
    let text: String
    let senderId: String
    let username: String
    let timestamp: Timestamp
}


struct GroupChatPreview {
    let planId: String
    let lastMessageText: String
    let timestamp: Timestamp
    let groupName: String
    let role: String // "invited" or "accepted"
}

