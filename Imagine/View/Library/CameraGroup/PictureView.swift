//
//  PictureView.swift
//  Imagine
//
//  Created by Ryan Aparicio on 12/8/24.
//

import SwiftUI
import AVFoundation
import UIKit
import Vision
import AVKit
import NaturalLanguage

struct PictureView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    var picture: SavedPicture

    // State variables
    @State private var isButtonHidden: Bool = false
    @State private var recognizedText: String = ""

    // Text-to-speech synthesizer
    let speechSynthesizer = AVSpeechSynthesizer()

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Display Image
                if let uiImage = UIImage(data: picture.image) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: 300)
                        .cornerRadius(12)
                        .shadow(color: .gray.opacity(0.3), radius: 5, x: 0, y: 3)
                } else {
                    Text("Image not available")
                        .font(.headline)
                        .foregroundColor(.red)
                }

                // Picture Details
                VStack(alignment: .leading, spacing: 8) {
                    Text(picture.title)
                        .font(.title2)
                        .fontWeight(.semibold)

                    Text("Uploaded by: \(picture.username)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)

                // Analyze Button
                if !isButtonHidden {
                    Button(action: {
                        if let uiImage = UIImage(data: picture.image) {
                            recognizeText(from: uiImage) { text in
                                DispatchQueue.main.async {
                                    recognizedText = text ?? "No text found"
                                    isButtonHidden = true // Hide the button after processing
                                }
                            }
                        }
                    }) {
                        Text("Analyze Text")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.pink)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .shadow(color: .gray.opacity(0.3), radius: 5, x: 0, y: 3)
                    }
                    .padding(.horizontal)
                }

                // Display Recognized Text
                if !recognizedText.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Recognized Text:")
                            .font(.headline)
                            .padding(.top)

                        ScrollView {
                            Text(recognizedText)
                                .padding()
                                .multilineTextAlignment(.leading)
                                .font(.body)
                                .foregroundColor(.black)
                                .background(Color(UIColor.systemGray6))
                                .cornerRadius(12)
                                .shadow(color: .gray.opacity(0.3), radius: 5, x: 0, y: 3)
                        }
                        .frame(maxHeight: 200) // Limit the height of the text area
                    }
                    .padding(.horizontal)

                    // "Read Text" Button
                    Button(action: {
                        readRecognizedText()
                    }) {
                        Text("Read Text")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .shadow(color: .gray.opacity(0.3), radius: 5, x: 0, y: 3)
                    }
                    .padding(.horizontal)
                }
            }
            .padding()
        }
        .navigationTitle("Picture Details")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Helper Functions

    private func recognizeText(from image: UIImage, completion: @escaping (String?) -> Void) {
        guard let cgImage = image.cgImage else {
            completion(nil)
            return
        }

        let request = VNRecognizeTextRequest { (request, error) in
            guard let observations = request.results as? [VNRecognizedTextObservation], error == nil else {
                completion(nil)
                return
            }

            let recognizedText = observations.compactMap { observation in
                observation.topCandidates(1).first?.string
            }.joined(separator: "\n")

            completion(recognizedText)
        }

        request.recognitionLevel = .accurate

        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                completion(nil)
            }
        }
    }

    private func readRecognizedText() {
        print("Speaking recognized text")

        let utterance = AVSpeechUtterance(string: recognizedText)
        utterance.rate = 0.5

        // Configure audio session
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Audio session error: \(error.localizedDescription)")
        }

        // Use preferred voice
        if let selectedVoice = authManager.currentUser?.voice,
           let voice = AVSpeechSynthesisVoice(language: selectedVoice) {
            utterance.voice = voice
        } else {
            print("Preferred voice not available. Using default.")
        }

        speechSynthesizer.speak(utterance)
    }
}

struct PictureView_Previews: PreviewProvider {
    static var previews: some View {
        // Mock Data for Preview
        let sampleImage = UIImage(systemName: "photo")!
        let imageData = sampleImage.jpegData(compressionQuality: 0.8)!
        let mockPicture = SavedPicture(id: UUID(), username: "Ryan", title: "Test Image", image: imageData, location: "30.2672,-97.7431")

        PictureView(picture: mockPicture)
            .environmentObject(AuthenticationManager())
    }
}
