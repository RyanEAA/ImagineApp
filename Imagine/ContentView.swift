//
//  ContentView.swift
//  Imagine
//
//  Created by Ryan Aparicio on 11/20/24.
//

import SwiftUI
import CoreData
import AVFoundation

import AVKit
import SwiftData
struct ContentView: View {
    @Environment(\.modelContext) var modelContext
    @Query var users: [User]// loads data from container

    var body: some View {
        LoginView()
        //ImageGenerationView()
    }
}


#Preview {
    ContentView()
}
