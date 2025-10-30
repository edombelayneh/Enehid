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

