//
//  Memory.swift
//  Enehid
//
//  Created by Edom Belayneh on 9/4/25.
//

// approved for firebase
import Foundation
import UIKit

struct Memory {
    var id: String
    var ownerId: String
    var username: String
    var caption: String
    var recommends: Int
    var memoryURLs: [String]
    var bookmarks: Int
    var taggedUIds: [String]
    var commentsCount: Int
    var createdAt: Date
}
