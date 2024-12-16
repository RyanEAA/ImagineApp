//
//  Book.swift
//  Imagine
//
//  Created by Turing on 11/25/24.
//

import Foundation
import SwiftData

@Model
class Book: Identifiable, Hashable, Equatable {
    let id: UUID
    var username: String
    var title: String
    var url: String
    let creationDate: Date
    var hasFinishedReading: Bool
    var location: String?
    
    init(id: UUID, username: String, title: String, url: String, creationDate: Date = Date(), hasFinishedReading: Bool = false, location: String?) {
        self.id = id
        self.username = username
        self.title = title
        self.url = url
        self.creationDate = creationDate
        self.hasFinishedReading = hasFinishedReading
        self.location = location
    }
    
    static func ==(lhs: Book, rhs: Book) -> Bool{
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher){
        hasher.combine(id)
    }
    
    static var mockBook = Book(id: UUID(), username: "Ryan", title: "test", url:"https://www.gutenberg.org/cache/epub/74840/pg74840-images.html", location: "30.2672,-97.7431")
    static var mockBook1 = Book(id: UUID(), username: "Ryan", title: "test", url: "https://www.gutenberg.org/cache/epub/74829/pg74829-images.html", location: "30.2672,-97.7431")
    static var mockBook2 = Book(id: UUID(), username: "Ryan", title: "test", url: "https://www.gutenberg.org/cache/epub/74829/pg74829-images.html", location: "30.2672,-97.7431")
    
    static var examples: [Book] {
        [mockBook,
        mockBook1,
        mockBook2]
    }
}
