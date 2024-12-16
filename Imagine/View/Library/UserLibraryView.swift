//
//  UserLibraryView.swift
//  Imagine
//
//  Created by Ryan Aparicio on 11/25/24.
//

import SwiftUI
import SwiftData

struct UserLibraryView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    
    // Holds book and picture queries
    @Query private var books: [Book]
    @Query private var pictures: [SavedPicture]
    
    @State private var bookSelection: Book? = nil
    @State private var pictureSelection: SavedPicture? = nil
    @State private var isAddBookViewShown: Bool = false
    
    init() {
        // Use a default predicate that will be dynamically updated
        _books = Query(filter: #Predicate<Book> { _ in true })
        _pictures = Query(filter: #Predicate<SavedPicture> { _ in true })
    }
    
    var body: some View {
        let currentUser = authManager.currentUser
        
        NavigationStack {
            VStack(spacing: 20) {
                // Header Section
                headerSection
                
                // Greeting
                Text("Hello, \(currentUser?.username ?? "User")!")
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(.pink)
                
                // Library Section
                VStack(alignment: .leading, spacing: 20) {
                    // Websites Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Websites")
                            .font(.headline)
                            .padding(.leading)
                        
                        List(filteredBooks, selection: $bookSelection) { book in
                            NavigationLink(destination: BookView(book: book)) {
                                BookRow(book: book)
                            }
                        }
                        .frame(maxHeight: 200)
                    }
                    .background(Color.pink.opacity(0.1))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    
                    // Pictures Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Pictures")
                            .font(.headline)
                            .padding(.leading)
                        
                        List(filteredPictures, selection: $pictureSelection) { picture in
                            NavigationLink(destination: PictureView(picture: picture)) {
                                PictureRow(picture: picture)
                            }
                        }
                        .frame(maxHeight: 200)
                    }
                    .background(Color.pink.opacity(0.1))
                    .cornerRadius(10)
                    .padding(.horizontal)
                }
                .padding(.top)
                
                // Camera Button
                HStack(alignment: .bottom){
                    Spacer()
                    NavigationLink(destination: CameraView()) {
                        Image(systemName: "camera.circle.fill")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .foregroundColor(.pink)
                            .shadow(radius: 4)
                    }
                    Spacer()
                }
                .padding(.top)
                
                Spacer()
            }
            .sheet(isPresented: $isAddBookViewShown) {
                AddBookView()
            }
        }
    }
    
    // Filtered Books
    private var filteredBooks: [Book] {
        guard let username = authManager.currentUser?.username else { return [] }
        return books.filter { $0.username == username }
    }
    
    // Filtered Pictures
    private var filteredPictures: [SavedPicture] {
        guard let username = authManager.currentUser?.username else { return [] }
        return pictures.filter { $0.username == username }
    }
    
    // Header Section
    private var headerSection: some View {
        HStack {
            // User Settings Button
            NavigationLink(destination: UserSettings().environment(authManager)) {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 32, height: 32)
                    .foregroundColor(.pink)
                    .padding()
            }
            
            Spacer()
            
            // App Title
            Text("Imagine")
                .font(.title)
                .fontWeight(.semibold)
                .foregroundColor(.pink)
            
            Spacer()
            
            // Add Book Button
            Button(action: { isAddBookViewShown.toggle() }) {
                Image(systemName: "square.and.pencil.circle.fill")
                    .resizable()
                    .frame(width: 32, height: 32)
                    .foregroundColor(.pink)
                    .padding()
            }
        }
        .padding(.horizontal)
    }
}

// MARK: - PictureRow
struct PictureRow: View {
    let picture: SavedPicture
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(picture.title)
                .font(.body)
                .fontWeight(.medium)
            Text(picture.creationDate.formatted(.dateTime))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - BookRow
struct BookRow: View {
    let book: Book
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(book.title)
                .font(.body)
                .fontWeight(.medium)
            Text(book.creationDate.formatted(.dateTime))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Preview
#Preview {
    UserLibraryView()
        .environmentObject(AuthenticationManager())
}
