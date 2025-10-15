//
//  Starred.swift
//  Enehid
//
//  Created by Edom Belayneh on 10/1/25.
//

// approved for firebase
// Starred is going to be everything you put a star on
// “Stars” are highlighted memories or featured posts (either chosen by user or system).
import Foundation
import UIKit

struct Starred {
    let id: String
    var memoryId: String
    var userId: String
    var createdAt: Date
}

//let sampleStarred: [Starred] = [
//    Starred(id: "mem_01", imageName: "image_name", caption: "A beautiful memory.", likes: 124, commentsCount: 15, isVideo: false),
//    Starred(id: "mem_02", imageName: "image_name_1", caption: "Coffee and code.", likes: 35, commentsCount: 2, isVideo: false),
//    Starred(id: "mem_03", imageName: "image_name", caption: "My new puppy!", likes: 502, commentsCount: 42, isVideo: false),
//    Starred(id: "mem_04", imageName: "image_name_1", caption: "Fun day at the park.", likes: 88, commentsCount: 9, isVideo: true),
//    Starred(id: "mem_05", imageName: "image_name", caption: "Another amazing day!", likes: 150, commentsCount: 10, isVideo: false)
//]
