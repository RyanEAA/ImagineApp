//
//  ImagineApp.swift
//  Imagine
//
//  Created by Ryan Aparicio on 11/20/24.
//

import SwiftData
import SwiftUI
import SwiftData


// this tells swift to launch the application
@main
struct ImagineApp: App {
    // initializes Authentication Manger object
    @StateObject private var authManager = AuthenticationManager()
    
    // declares container as ModelContainer object
    var container: ModelContainer
    
    // sets the container before showing the body
    init() {
        do {
            container = try ModelContainer(for: User.self, Book.self, SavedPicture.self)
        }
        catch{
            fatalError("failed to configure swiftdata container\(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {// tells swift ui that it can be displayed on multiple windows
            if authManager.isLoggedIn {
                UserLibraryView()
                    .modelContainer(container)
                    .environment(authManager)
            } else {
                ContentView()
                    .modelContainer(container)// tells swift to allow use of user data everywhere
                    .environment(authManager)
            }

        }
        
    }
}
