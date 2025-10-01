//
//  Reviews.swift
//  Enehid
//
//  Created by Edom Belayneh on 10/1/25.
//

import Foundation
import UIKit

struct Reviews {
    let id: String
    let imageName: String
    let caption: String
    let likes: Int
    let commentsCount: Int
    let isVideo: Bool
}

let sampleReviews: [Reviews] = [
    Reviews(id: "mem_01", imageName: "image_name", caption: "A beautiful memory.", likes: 124, commentsCount: 15, isVideo: false),
    Reviews(id: "mem_02", imageName: "image_name_1", caption: "Coffee and code.", likes: 35, commentsCount: 2, isVideo: false),
    Reviews(id: "mem_03", imageName: "image_name", caption: "My new puppy!", likes: 502, commentsCount: 42, isVideo: false),
    Reviews(id: "mem_04", imageName: "image_name_1", caption: "Fun day at the park.", likes: 88, commentsCount: 9, isVideo: true),
    Reviews(id: "mem_05", imageName: "image_name", caption: "Another amazing day!", likes: 150, commentsCount: 10, isVideo: false)
]
