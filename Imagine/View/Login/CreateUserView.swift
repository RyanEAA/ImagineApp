//
//  CreateUserView.swift
//  Imagine
//
//  Created by Ryan on 11/26/24.
//

import SwiftUI
import SwiftData

struct CreateUserView: View {
    @State private var username: String = ""
    @State private var password: String = ""
    
    @State private var showingError = false
    @State private var errorMessage = ""
    
    @Environment(AuthenticationManager.self) private var authManager
    
    @Environment(\.modelContext) private var modelContext
    
    @Query private var users: [User]
    
    var body: some View {
        VStack {
            Spacer()
            
            // App Title
            Text("Imagine")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.black) // White text to contrast with the pink background
            
            Text("Create User")
                .font(.title2)
                .foregroundColor(.black.opacity(0.6))
            
            VStack(spacing: 16) { // Adjusted spacing for a balanced look
                TextField("Username", text: $username)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(color: .gray.opacity(0.3), radius: 5, x: 0, y: 3)
                    .disableAutocorrection(true)
                
                SecureField("Password", text: $password)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(color: .gray.opacity(0.3), radius: 5, x: 0, y: 3)
                    .disableAutocorrection(true)
            }
            .padding(.horizontal, 32)
            
            // Create Account Button            
            Button(action: {
                CreateAccount()
            }) {
                Text("Login")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(username.isEmpty || password.isEmpty ? Color.gray : Color.pink)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal, 32)
            .disabled(username.isEmpty || password.isEmpty)
            
            Spacer()
        }
        .background(Color.blue.opacity(0.1)) // Light pink background
        .edgesIgnoringSafeArea(.all)
        .alert(isPresented: $showingError) {
            Alert(title: Text("Account Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    // Function to create a new account
    private func CreateAccount() {
        // Ensure username and password are not empty
        guard !username.isEmpty, !password.isEmpty else {
            errorMessage = "Please enter both username and password"
            showingError = true
            return
        }
        
        // Check if username is already taken
        if users.first(where: { $0.username == username }) != nil {
            errorMessage = "Username already taken"
            showingError = true
            return
        }
        
        // Create and save the new user
        let newUser = User(id: UUID(), username: username, password: password)
        
        do {
            modelContext.insert(newUser)
            try modelContext.save()
            print("Account created successfully for \(username)")
            
            authManager.login(user: newUser)
        } catch {
            errorMessage = "Failed to create account: \(error.localizedDescription)"
            showingError = true
        }
    }
}

#Preview {
    CreateUserView()
        .environmentObject(AuthenticationManager())
}
