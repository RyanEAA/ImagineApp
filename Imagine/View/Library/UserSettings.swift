//
//  UserSettings.swift
//  Imagine
//
//  Created by Ryan Aparicio on 11/26/24.
//

import SwiftUI
import PhotosUI
import SwiftData

struct UserSettings: View {
    @EnvironmentObject var authManager: AuthenticationManager

    @State var selectedVoice: String = "default"
    @State var selectedFontSize: Int = 10
    @State var selectedFont: String = "default"

    @State private var showPopup: Bool = false

    // Initialize user settings
    private func initializeSettings() {
        selectedVoice = authManager.currentUser?.voice ?? "default"
        selectedFontSize = authManager.currentUser?.fontSize ?? 10
        selectedFont = authManager.currentUser?.font ?? "default"
    }

    var body: some View {
        let currentUser = authManager.currentUser

        VStack {
            // Profile Section
            VStack(spacing: 16) {
                // Profile Picture Placeholder
                Circle()
                    .fill(Color.pink.opacity(0.3))
                    .frame(width: 100, height: 100)
                    .overlay(Text("👤").font(.largeTitle))

                // User's Name
                Text(currentUser?.username ?? "Bruce Wayne")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.pink)
            }
            .padding()

            // Settings List
            List {
                Section(header: Text("Settings").font(.headline).foregroundColor(.pink)) {
                    // Voice Selection Menu
                    Menu {
                        Button("Mónica", action: { selectedVoice = "es-ES" })
                        Button("Gordon", action: { selectedVoice = "en-AU" })
                        Button("Tessa", action: { selectedVoice = "en-ZA" })
                        Button("Arthur", action: { selectedVoice = "en-GB" })
                        Button("Rishi", action: { selectedVoice = "en-IN" })
                    } label: {
                        Label("Voice: \(selectedVoice)", systemImage: "chevron.down")
                    }

                    // Font Size Slider
                    HStack {
                        Text("Font Size: \(selectedFontSize)")
                        Spacer()
                        Slider(value: Binding(get: {
                            Double(selectedFontSize)
                        }, set: { newValue in
                            selectedFontSize = Int(newValue)
                        }), in: 8...20, step: 1)
                            .accentColor(.pink)
                    }

                    // Font Picker
                    Menu {
                        Button("Default", action: { selectedFont = "default" })
                        Button("Serif", action: { selectedFont = "serif" })
                        Button("Sans Serif", action: { selectedFont = "sans-serif" })
                    } label: {
                        Label("Font: \(selectedFont)", systemImage: "textformat")
                    }
                }
                
                // Save Button Section
                Section {
                    Button(action: {
                        saveProfile()
                    }) {
                        HStack {
                            Spacer()
                            Text("Save Changes")
                                .font(.headline)
                            Spacer()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.pink)
                }

                // MapView Section (Placeholder)
                Section(header: Text("Location").font(.headline).foregroundColor(.pink)) {
                    MapView()
                        .frame(height: 200)
                        .cornerRadius(10)
                }



                // Logout Button Section
                Section {
                    Button("Logout") {
                        authManager.logout()
                    }
                    .foregroundColor(.red)
                }
            }
            .listStyle(InsetGroupedListStyle())
        }
        .background(Color.pink.opacity(0.1))
        .edgesIgnoringSafeArea(.all)
        .onAppear(perform: initializeSettings)
        .alert(isPresented: $showPopup) {
            Alert(
                title: Text("Profile Updated"),
                message: Text("Your profile has been successfully updated."),
                dismissButton: .default(Text("OK"))
            )
        }
    }

    private func saveProfile() {
        guard let currentUser = authManager.currentUser else { return }

        let hasUpdated = currentUser.voice != selectedVoice ||
                         currentUser.font != selectedFont ||
                         currentUser.fontSize != selectedFontSize

        if hasUpdated {
            currentUser.voice = selectedVoice
            currentUser.font = selectedFont
            currentUser.fontSize = selectedFontSize
            showPopup = true
            print("Successfully updated profile for \(currentUser.username)")
        } else {
            print("No changes detected for \(currentUser.username)")
        }
    }
}

#Preview {
    UserSettings()
        .environmentObject(AuthenticationManager())
}
