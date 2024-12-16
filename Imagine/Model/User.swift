//
//  User.swift
//  Imagine
//
//  Created by Turing on 11/25/24.
//

import Foundation
import SwiftData

@Model
class User {
    var id: UUID
    var username: String
    var password: String
    
    var profilePicture: Data?
    var voice: String?
    var fontSize: Int?
    var font: String?
    
    
    init(id: UUID, username: String, password: String, profilePicture: Data? = nil, voice:String? = "default", font: String? = "default", fontSize: Int? = 15 ) {
        self.id = id
        self.username = username
        self.password = password
        self.profilePicture = profilePicture
        self.voice = voice
        self.font = font
        self.fontSize = fontSize
    }
    
    // Static mock instance for previews
    static let mockUser = User(
        id: UUID(),
        username: "MockUser",
        password: "password123",
        profilePicture: Data(base64Encoded: "mockProfileData"),
        voice: "default",
        font: "default",
        fontSize: 18

    )
}

