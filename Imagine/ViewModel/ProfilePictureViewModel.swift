//
//  ProfilePictureViewModel.swift
//  Imagine
//
//  Created by Ryan Aparicio on 12/2/24.
//

import SwiftUI
import PhotosUI

class ProfilePictureViewModel: ObservableObject {
    @Published var profileImage: UIImage? {
        didSet {
            // Sync the profileImage with the User's profilePicture
            if let uiImage = profileImage {
                user.profilePicture = uiImage.jpegData(compressionQuality: 0.8)
            } else {
                user.profilePicture = nil
            }
        }
    }

    private var user: User

    init(user: User) {
        self.user = user
        // Load initial profile picture from User
        if let profilePictureData = user.profilePicture {
            self.profileImage = UIImage(data: profilePictureData)
        }
    }
}
