//
//  Friends.swift
//  Enehid
//
//  Created by Edom Belayneh on 9/26/25.
//

// approved for firebase
import Foundation
import UIKit

struct Story: Equatable, Hashable {
    let id: String
    let ownerId: String
    let username: String
    let profilePictureURL: String?
    let mediaURL: String?
    let createdAt: Date
//    let isExpired: Bool
}
