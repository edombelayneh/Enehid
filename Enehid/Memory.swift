//
//  Memory.swift
//  Enehid
//
//  Created by Edom Belayneh on 9/4/25.
//

import Foundation
import UIKit

struct Memory {
    let id: String
    let imageName: String
    let caption: String
    let likes: Int
    let commentsCount: Int
    let isVideo: Bool
}

let sampleMemory: [Memory] = [
    Memory(id: "mem_01", imageName: "image_post_01", caption: "A beautiful memory.", likes: 124, commentsCount: 15, isVideo: false),
    Memory(id: "mem_02", imageName: "image_post_02", caption: "Coffee and code.", likes: 35, commentsCount: 2, isVideo: false),
    Memory(id: "mem_03", imageName: "image_post_03", caption: "My new puppy!", likes: 502, commentsCount: 42, isVideo: false),
    Memory(id: "mem_04", imageName: "video_post_01", caption: "Fun day at the park.", likes: 88, commentsCount: 9, isVideo: true),
    Memory(id: "mem_05", imageName: "image_post_03", caption: "Another amazing day!", likes: 150, commentsCount: 10, isVideo: false),
    Memory(id: "mem_06", imageName: "image_post_02", caption: "Another amazing day!", likes: 150, commentsCount: 10, isVideo: false),
    Memory(id: "mem_07", imageName: "image_post_01", caption: "Another amazing day!", likes: 150, commentsCount: 10, isVideo: false),
    Memory(id: "mem_08", imageName: "image_post_03", caption: "Another amazing day!", likes: 150, commentsCount: 10, isVideo: false),
    Memory(id: "mem_09", imageName: "video_post_01", caption: "Another amazing day!", likes: 150, commentsCount: 10, isVideo: false),
    Memory(id: "mem_10", imageName: "image_post_02", caption: "Another amazing day!", likes: 150, commentsCount: 10, isVideo: false),
    Memory(id: "mem_11", imageName: "image_post_01", caption: "Another amazing day!", likes: 150, commentsCount: 10, isVideo: false),
    Memory(id: "mem_12", imageName: "image_post_03", caption: "Another amazing day!", likes: 150, commentsCount: 10, isVideo: false),
    Memory(id: "mem_13", imageName: "video_post_01", caption: "Another amazing day!", likes: 150, commentsCount: 10, isVideo: false),
    Memory(id: "mem_14", imageName: "image_post_02", caption: "Another amazing day!", likes: 150, commentsCount: 10, isVideo: false)
]
