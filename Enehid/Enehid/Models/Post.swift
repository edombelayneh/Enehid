//
//  Friends.swift
//  Enehid
//
//  Created by Edom Belayneh on 9/26/25.
//

import Foundation
import UIKit

struct Post: Equatable, Hashable {
    let id: String?
    let username: String?
    let caption: String?
    let image: UIImage?
//    let comments: [Comment]?
//    let date: Date?
}

let mockPosts: [Post] = [
    Post(id: "fr_1", username: "john_doe", caption: "Here is the caption for now...just testing", image:  UIImage(systemName: "person.circle")),
    Post(id: "fr_2", username: "jane_doe", caption: "Here is the caption for now...just testing", image:  UIImage(systemName: "person.circle")),
    Post(id: "fr_3", username: "jannet", caption: "Here is the caption for now...just testing", image:  UIImage(systemName: "person.circle")),
    Post(id: "fr_4", username: "lila", caption: "Here is the caption for now...just testing", image:  UIImage(systemName: "person.circle")),
]
