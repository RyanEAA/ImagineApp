//
//  SavedPicture.swift
//  Imagine
//
//  Created by Ryan Aparicio on 12/8/24.
//

import Foundation
import SwiftData


@Model
class SavedPicture: Identifiable, Hashable, Equatable {
    let id: UUID
    var username: String
    var title: String
    var image: Data
    var creationDate: Date
    var location: String? // Latitude,Longitude format



    
    init(id: UUID, username: String, title: String, image: Data, creationDate: Date = Date(), location: String?) {
        self.id = id
        self.username = username
        self.title = title
        self.image = image
        self.creationDate = creationDate
        self.location = location
    }
    
    static func == (lhs: SavedPicture, rhs: SavedPicture) -> Bool{
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher){
        hasher.combine(id)
    }
    
}


