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
    @State private var imageData: Data? // Holds the image as Data
    @State private var isConfirmationDialoguePresented: Bool = false
    @State private var isImagePickerPresented: Bool = false
    @State private var sourceType: SourceType = .camera
    @State var newTitle: String = ""
    @State var newLocation: String = ""
    
    
    // pop ups
    @State private var showLocationAlert: Bool = false
    @State private var coordinatesString: String = ""

    @State private var showImageAlert: Bool = false
    
    @State private var isProcessing: Bool = false
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""

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
                        await attemptSave()
                    }
                    
                }) {
                    Text("Save")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.pink)
                .padding(.horizontal)
                .disabled(newTitle.isEmpty || newLocation.isEmpty || image == nil)

                
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
            } // end of sheet ispresented
            .alert(isPresented: $showLocationAlert) {
                Alert(
                    title: Text("Location Not Found"),
                      message: Text("Could not determine the location. Continue without a location?"),
                      primaryButton: .default(Text("Continue"),
                                             action: {
                    coordinatesString = ""
                    savePicture()

                }),
                      secondaryButton: .cancel()
                )
            }
            .alert("No Image Selected", isPresented: $showImageAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Please select an image before saving.")
            }
        }
    }
    
    // Helper function to process image
    private func processImage(_ uiImage: UIImage) -> Data? {
        return uiImage.jpegData(compressionQuality: 0.8)
    }

    // Helper function to validate save conditions
    private func canSave() -> Bool {
        return !newTitle.isEmpty &&
               !newLocation.isEmpty &&
               imageData != nil &&
               (coordinatesString.isEmpty || !coordinatesString.isEmpty)
    }

    // Process the image and attempt to save
        func attemptSave() async {
            // First, ensure we have valid image data
            guard let currentImage = image,
                  let processedImageData = currentImage.jpegData(compressionQuality: 0.8) else {
                showImageAlert = true
                return
            }
            
            // Store the processed image data
            imageData = processedImageData
            
            // Try to retrieve coordinates
            if let coordinates = await LocationHelper.getCoordinates(from: newLocation) {
                coordinatesString = "\(coordinates.latitude),\(coordinates.longitude)"
                savePicture()
            } else {
                // Show the alert if location not found
                showLocationAlert = true
            }
        }
        
        // Saves picture to SwiftData
        func savePicture() {
            guard let imageData = imageData else { return }
            
            // Create new picture
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
                dismiss()
            } catch {
                print("Failed to save picture: \(error)")
            }
        }
    
    
}

#Preview {
    CameraView()
        .environmentObject(AuthenticationManager())
}
