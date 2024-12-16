//
//  ImageGenerationView.swift
//  Imagine
//
//  Created by Ryan Aparicio on 12/3/24.
//

import SwiftUI
import Foundation

// SwiftUI View for Image Generation
struct ImageGenerationView: View {
    // state object to observe changes
    @StateObject private var imageFetcher = ImageFetcher()
    @State private var prompt = "sunset over a mountain"
    
    
    var body: some View {
        VStack {
            // text field to enter a prompt
            TextField("Enter a prompt", text: $prompt)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            // button to fetch the image
            Button("Fetch Image"){
                print("pressed button")
                imageFetcher.fetchImage(prompt: prompt)
            }
            .padding()
                        
            // display fetched image
            if let image = imageFetcher.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 300, maxHeight: 300)
            } else {
                Text("No image Yet")
                    .foregroundColor(.gray)
                    .padding()
            }
            
        }
        .padding()
    }
}
// Preview Provider
struct ImageGenerationView_Previews: PreviewProvider {
    static var previews: some View {
        ImageGenerationView()
    }
}
