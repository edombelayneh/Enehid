//
//  Friends.swift
//  Enehid
//
//  Created by Edom Belayneh on 9/26/25.
//

import Foundation
import UIKit

struct Friends: Equatable, Hashable {
    let id: String
    let username: String
//    let posts: [Post]
//    let profilePicture: UIImage?
    let memories: Int
    let stars: Int
    let recommends: Int
    
}

let mockFriends: [Friends] = [
    Friends(id: "fr_1", username: "john_doe", memories: 3, stars: 14, recommends: 2),
    Friends(id: "fr_2", username: "jane_doe", memories: 12, stars: 45, recommends: 12),
    Friends(id: "fr_3", username: "jannet", memories: 22, stars: 41, recommends: 23)
]
