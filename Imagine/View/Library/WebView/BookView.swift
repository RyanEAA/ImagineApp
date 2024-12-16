//
//  Book.swift
//  Imagine
//
//  Created by Ryan Aparicio on 12/2/24.
//

import SwiftUI
import AVFoundation
import AVKit
import NaturalLanguage

struct BookView: View {
    var book: Book
    
    // Get current logged-in user
    @EnvironmentObject var authManager: AuthenticationManager
    
    // For fetching generated image
    @StateObject private var imageFetcher = ImageFetcher()
    
    @State var highlightedText: String = ""
    
    // Creates speech synthesizer for users
    let speechSynthesizer = AVSpeechSynthesizer()
    
    // To toggle sheet
    @State private var showingImageSheet = false

    var body: some View {
        VStack(spacing: 20) {
            // Book Title
            Text(book.title)
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .foregroundColor(Color.primary)
            
            // Button Section
            buttonSection
                .padding(.horizontal)
            
            // WebView Section
            VStack {
                WebView(url: book.url, highlightedText: $highlightedText)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(UIColor.systemGray6))
            .cornerRadius(12)
            .shadow(color: .gray.opacity(0.3), radius: 5, x: 0, y: 3)
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingImageSheet) {
            if imageFetcher.isLoading {
                VStack {
                    ProgressView("Generating Image...")
                        .padding()
                    Text("Please wait while your art is being generated.")
                        .multilineTextAlignment(.center)
                        .padding()
                }
            } else if let generatedImage = imageFetcher.image {
                AIImageView(image: generatedImage)
            } else {
                Text("No image available.")
            }
        }
    }
    
    private var buttonSection: some View {
        HStack(spacing: 20) {
            // Speech Button
            Button(action: {
                startSpeechSynthesis()
            }) {
                Label("Speech", systemImage: "mic.fill")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(12)
                    .shadow(color: .blue.opacity(0.3), radius: 5, x: 0, y: 3)
            }
            
            // Generate Art Button
            Button(action: {
                generateArt()
            }) {
                Label("GenArt", systemImage: "paintbrush.fill")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.white)
                    .background(Color.purple)
                    .cornerRadius(12)
                    .shadow(color: .purple.opacity(0.3), radius: 5, x: 0, y: 3)
            }
        }
    }
    
    // MARK: - Helper Functions
    
    private func startSpeechSynthesis() {
        guard !highlightedText.isEmpty else {
            print("No text highlighted for speech.")
            return
        }
        
        print("Speaking highlighted text")
        let utterance = AVSpeechUtterance(string: highlightedText)
        utterance.rate = 0.5
        
        // Configure audio session
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Audio session error: \(error.localizedDescription)")
        }
        
        // Select preferred voice
        let selectedVoice = authManager.currentUser?.voice ?? "en-US"
        if let voice = AVSpeechSynthesisVoice(language: selectedVoice) {
            utterance.voice = voice
        } else {
            print("Preferred voice not available. Using default.")
        }
        
        speechSynthesizer.speak(utterance)
    }
    
    private func generateArt() {
        print("Generating art...")
        imageFetcher.fetchImage(prompt: highlightedText)
        showingImageSheet.toggle()
    }
}

#Preview {
    BookView(book: Book.mockBook)
        .environmentObject(AuthenticationManager())
}
