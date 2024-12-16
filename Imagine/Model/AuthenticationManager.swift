//
//  AuthenticationManager.swift
//  Imagine
//
//  Created by Ryan Aparicio on 11/26/24.
//

import Foundation

// an authentication manager
@Observable
class AuthenticationManager: ObservableObject {
    // @published allows us to create observable objects
    var isLoggedIn = false
    var currentUser: User?
    
    func login(user: User){
        // sets isLoggedIn state to True
        isLoggedIn = true
        
        // sets the currentUser to user
        currentUser = user
    } // end of login function
    
    func logout() {
        // sets isLoggedIn to False
        isLoggedIn = false
        
        // sets the currentUser to nil
        currentUser = nil
    }
}



