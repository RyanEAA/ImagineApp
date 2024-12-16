//
//  LoginView.swift
//  Imagine
//
//  Created by Ryan on 11/25/24.
//

import SwiftUI
import SwiftData

struct LoginView: View {
    @State private var username: String = ""
    @State private var password: String = ""
    
    @State private var showingError = false
    @State private var errorMessage = ""
    
    @Environment(AuthenticationManager.self) private var authManager
    
    @Environment(\.modelContext) private var modelContext
    
    @Query private var users: [User]
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                
                // App Logo
                Text("Imagine")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.black) // Text color to stand out on pink background
                
                VStack(spacing: 16) { // Adjusted spacing for aesthetics
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
                
                // Login Button
                Button(action: {
                    Login()
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
                
                // Create New Account Link
                NavigationLink(destination: CreateUserView()) {
                    Text("Create New Account")
                        .foregroundColor(.black)
                        .underline()
                }
                .padding(.top, 8)
                
                // Button to list users (for debugging purposes)
//                Button("List Users") {
//                    for user in users {
//                        print("\(user.username): \(user.password)")
//                    }
//                }
//                .padding(.top, 16)
//                .foregroundColor(.white)
                
                Spacer()
            }
            .background(Color.green.opacity(0.1)) // Light pink background
            .edgesIgnoringSafeArea(.all)
            .navigationTitle("Login")
            .alert(isPresented: $showingError) {
                Alert(title: Text("Login Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    private func Login() {
        guard !username.isEmpty, !password.isEmpty else {
            errorMessage = "Please enter both username and password"
            showingError = true
            return
        }
        
        // Check if user exists
        if let user = users.first(where: { $0.username == username && $0.password == password }) {
            // Successful login - In a real app, you'd use more secure authentication
            print("Login successful for \(user.username)")
            
            // Navigate to main app or set logged in state
            authManager.login(user: user)
        } else {
            errorMessage = "Invalid username or password"
            showingError = true
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthenticationManager())
}
