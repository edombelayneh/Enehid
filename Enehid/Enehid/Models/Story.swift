//
//  Friends.swift
//  Enehid
//
//  Created by Edom Belayneh on 9/26/25.
//

import Foundation
import UIKit

struct Story: Equatable, Hashable {
    let id: String
    let ownerId: String
    let username: String
    let mediaURL: String?
    let createdAt: Date
}

//let mockStories: [Story] = [
//    Story(id: "st_1", user: mockFriends[0], image: UIImage(systemName: "person.circle"), story: UIImage(systemName: "photo")),
//    Story(id: "st_2", user: mockFriends[1],image: UIImage(systemName: "person.circle"), story: UIImage(systemName: "photo")),
//    Story(id: "st_3", user: mockFriends[2], image: UIImage(systemName: "person.circle"), story: UIImage(systemName: "photo")),
////    Story(id: "st_4", user: mockFriends[3], image: UIImage(systemName: "person.circle"))
//]
