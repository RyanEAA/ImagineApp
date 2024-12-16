//
//  AIImageView.swift
//  Imagine
//
//  Created by Ryan Aparicio on 12/3/24.
//

import SwiftUI

struct AIImageView: View {
    let image: UIImage
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 300, maxHeight: 300)
            }
            .navigationTitle("Generated Image")
            .navigationBarItems(trailing: Button("Done") { dismiss() })
        }
    }
}

//#Preview {
//    AIImageView(image: )
//}
