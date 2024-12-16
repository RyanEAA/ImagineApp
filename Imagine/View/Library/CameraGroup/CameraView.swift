//
//  CameraView.swift
//  Imagine
//
//  Created by Ryan Aparicio on 12/8/24.
//

import SwiftUI
import PhotosUI
import CoreLocation

struct CameraView: View {
    // Logged-in user
    @EnvironmentObject var authManager: AuthenticationManager

    // Model context for saving images
    @Environment(\.modelContext) private var modelContext

    // Dismiss the view
    @Environment(\.dismiss) private var dismiss

    // State variables
    @State private var image: UIImage?
    @State private var isConfirmationDialoguePresented: Bool = false
    @State private var isImagePickerPresented: Bool = false
    @State private var sourceType: SourceType = .camera
    @State var newTitle: String = ""
    @State var newLocation: String = ""

    enum SourceType {
        case camera
        case photoLibrary
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Title
                Text("Create New Picture Item")
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundColor(.black)

                // Input Fields
                VStack(alignment: .leading, spacing: 16) {
                    TextField("Title", text: $newTitle)
                        .textFieldStyle(.roundedBorder)
                    
                    TextField("Location", text: $newLocation)
                        .textFieldStyle(.roundedBorder)
                }
                .padding(.horizontal)

                // Image Display
                ZStack {
                    if let image = image {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 350, maxHeight: 300)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                            .padding(.horizontal)
                    } else {
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 120)
                            .foregroundColor(.gray)
                            .opacity(0.5)
                    }
                }
                .onTapGesture {
                    isConfirmationDialoguePresented = true
                }
                .padding(.top, 10)

                // Save Button
                Button(action: {
                    Task {
                        await mysave()
                    }
                    dismiss()
                }) {
                    Text("Save")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.pink)
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationTitle("Camera")
            .navigationBarTitleDisplayMode(.inline)
            .confirmationDialog("Choose an Option", isPresented: $isConfirmationDialoguePresented) {
                Button("Camera") {
                    sourceType = .camera
                    isImagePickerPresented = true
                }
                Button("Photo Library") {
                    sourceType = .photoLibrary
                    isImagePickerPresented = true
                }
            }
            .sheet(isPresented: $isImagePickerPresented) {
                if sourceType == .camera {
                    ImagePicker(isPresented: $isImagePickerPresented, image: $image, sourceType: .camera)
                } else {
                    PhotoPicker(selectedImage: $image)
                }
            }
        }
    }

    func mysave() async {
        guard let image = image else {
            print("No image to save")
            return
        }

        // Convert UIImage to Data
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("Failed to convert UIImage to Data")
            return
        }

        // Fetch coordinates
        guard let coordinates = await LocationHelper.getCoordinates(from: newLocation) else {
            print("Failed to get coordinates")
            return
        }

        let coordinatesString = "\(coordinates.latitude),\(coordinates.longitude)"
        
        // Create and save new picture
        let newPicture = SavedPicture(
            id: UUID(),
            username: authManager.currentUser?.username ?? "",
            title: newTitle,
            image: imageData,
            location: coordinatesString
        )
        modelContext.insert(newPicture)

        do {
            try modelContext.save()
            print("Image and coordinates saved successfully")
        } catch {
            print("Failed to save image: \(error.localizedDescription)")
        }
    }
}

#Preview {
    CameraView()
        .environmentObject(AuthenticationManager())
}
