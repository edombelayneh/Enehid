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
    var profilePictureURL: String?
   
    var avatarSkin: String?      
    var avatarEyes: String?
    var avatarMouth: String?
    var avatarAccessory: String?
    
    var friends: [String : String] = [:]
    var recommendedPostIDs: [String] = []
    var starredPostIDs: [String] = []
    var memoryPostIDs: [String] = []
}
