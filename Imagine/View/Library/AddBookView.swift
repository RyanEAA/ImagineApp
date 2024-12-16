//
//  AddBookView.swift
//  Imagine
//
//  Created by Ryan on 12/2/24.
//

import SwiftUI
import SwiftData

struct AddBookView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State var newURLString: String = ""
    @State var newTitle: String = ""
    @State var newLocation: String = ""

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
                        await mysave()
                    }
                    dismiss()
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
    }

    func mysave() async {
        guard let coordinates = await LocationHelper.getCoordinates(from: newLocation) else {
            print("Failed to get coordinates")
            return
        }

        let coordinatesString = "\(coordinates.latitude),\(coordinates.longitude)"
        let newBook = Book(
            id: UUID(),
            username: authManager.currentUser?.username ?? "",
            title: $newTitle.wrappedValue,
            url: $newURLString.wrappedValue,
            location: coordinatesString
        )
        modelContext.insert(newBook)
        try? modelContext.save()
    }
}

#Preview {
    AddBookView()
        .environmentObject(AuthenticationManager())
}
