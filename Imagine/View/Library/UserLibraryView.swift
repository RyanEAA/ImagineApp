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
    @Environment(\.modelContext) private var modelContext
    
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
                        
                        List {
                            ForEach(filteredBooks) { book in
                                BookRow(book: book)
                                    .swipeActions(edge: .trailing) {
                                        // Swipe Left to Delete
                                        Button(role: .destructive) {
                                            deleteBook(book)
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    } // end of swipe left to delete

                            }
                            .onDelete(perform: deleteBook)

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
                        
                        List{
                            ForEach(filteredPictures) { picture in
                                PictureRow(picture: picture)
                                    .swipeActions(edge: .trailing){
                                        // swipe left to delete
                                        Button(role: .destructive) {
                                            deletePicture(picture)
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    } // end of swipe left
                            }
                            .onDelete(perform: deletePicture)

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
    
    // Delete Functions
    // delete picture from swiftdata
    func deletePicture(_ picture: SavedPicture) {
        modelContext.delete(picture) // Delete from the context
        try? modelContext.save() // Save the changes
    }
    
    // delete book from row function
    func deletePicture(at offsets: IndexSet) {
        for index in offsets {
            let picture = filteredPictures[index]
            deletePicture(picture)
        }
    }
    
    
    // delete book from swiftdata
    func deleteBook(_ book: Book) {
        modelContext.delete(book) // Delete from the context
        try? modelContext.save() // Save the changes
    }
    
    // delete book from row function
    func deleteBook(at offsets: IndexSet) {
        for index in offsets {
            let book = filteredBooks[index]
            deleteBook(book)
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
