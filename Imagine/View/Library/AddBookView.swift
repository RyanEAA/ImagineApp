//
//  AddBookView.swift
//  Imagine
//
//  Created by Ryan on 12/2/24.
//

import SwiftUI
import SwiftData

struct AddBookView: View {
    // get the logged in user
    @EnvironmentObject var authManager: AuthenticationManager
    // gets the data from the SwiftData
    @Environment(\.modelContext) private var modelContext
    // used to dimiss the view
    @Environment(\.dismiss) private var dismiss

    
    // keeps track of user entered variables
    @State var newURLString: String = ""
    @State var newTitle: String = ""
    @State var newLocation: String = ""
    
    // state variables for the alert
    @State private var showAlert: Bool = false
    @State private var coordinatesString: String = ""

    var body: some View {
        VStack(spacing: 20) {
            // Header
            Text("Create New Reading Item")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.pink)

            // TextFields for user input
            VStack(spacing: 15) {
                TextField("Enter Title", text: $newTitle)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)

                TextField("Enter URL", text: $newURLString)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)

                TextField("Enter Location", text: $newLocation)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
            }

            // Save Button
            HStack {
                Spacer()
                Button(action: {
                    Task {
                        await attemptSave()
                    }
                }) {
                    Text("Save")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.pink)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                Spacer()
            }
            Spacer()
        }
        .edgesIgnoringSafeArea(.all)
        .padding()
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Location Not Found"),
                  message: Text("Could not determine the location. Save without a location?"),
                  primaryButton: .default(Text("Continue"),
                                         action: {
                coordinatesString = ""
                saveBook()
            }),
                  secondaryButton: .cancel()
            )
        }
    }

    func attemptSave() async {
        // tries to retrieve coordinates
        if let coordinates = await LocationHelper.getCoordinates(from: newLocation) {
            coordinatesString = "\(coordinates.latitude),\(coordinates.longitude)"
            saveBook()
        } else {
            // Show the alert if location not found
            showAlert = true
        }
    }
    
    func saveBook() {
        let newBook = Book(
            id: UUID(),
            username: authManager.currentUser?.username ?? "",
            title: newTitle,
            url: newURLString,
            location: coordinatesString
        )
        modelContext.insert(newBook)
        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Failed to save book: \(error)")
        }
    }
}

#Preview {
    AddBookView()
        .environmentObject(AuthenticationManager())
}
