//
//  TypeToSpeechView.swift
//  Imagine
//
//  Created by Ryan Aparicio on 11/22/24.
//

import SwiftUI
import AVFoundation
import AVKit
import NaturalLanguage

struct TypeToSpeechView: View {
    @State private var name: String = ""
    let speechSynthesizer = AVSpeechSynthesizer()
    
    var body: some View {
            VStack {
                TextField("Name", text: $name)
                    .padding()
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.5), lineWidth: 2))
                Button("Greet") {
                    let utterance = AVSpeechUtterance(string: "Hello, \(name)!")
                    utterance.rate = 0.5
    
                    // Configure audio session
                    do {
                        try AVAudioSession.sharedInstance().setCategory(.playback)
                        try AVAudioSession.sharedInstance().setActive(true)
                    } catch {
                        print("Audio session error: \(error.localizedDescription)")
                    }
    
                    if let voice = AVSpeechSynthesisVoice(language: "en-AU") {
                        utterance.voice = voice
                    } else {
                        print("en-AU voice not available.")
                    }
    
                    speechSynthesizer.speak(utterance)
                }
            }
                .padding()
    }
}

#Preview {
    TypeToSpeechView()
}
