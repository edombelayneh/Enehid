//
//  AppUser.swift
//  Enehid
//
//  Created by Edom Belayneh on 10/14/25.
//

// approved for firebase
import Foundation
import FirebaseAuth
import FirebaseFirestore

struct User: Codable, Identifiable {
    var id: String
    var username: String
    var email: String
//    var profilePictureURL: String?
    var friends: [String : String] = [:]
}
