//
//  ImageFetcher.swift
//  Imagine
//
//  Created by Ryan Aparicio on 12/3/24.
//

import Foundation
import SwiftUI

class ImageFetcher: ObservableObject {
    @Published var image: UIImage? = nil
    @Published var isLoading = false
    
    func fetchImage(prompt: String){
        isLoading = true
        image = nil
        
        // encode prompt for a valid url
        let encodedPrompt = prompt.replacingOccurrences(of: " ", with: "-")
        let urlString = "https://image.pollinations.ai/prompt/\(encodedPrompt))"
        
        // guard incase url doesn't work
        guard let url = URL(string: urlString) else {
            print("invalid URL")
            return
        }
        
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 120
        configuration.timeoutIntervalForResource = 120
        
        let session = URLSession(configuration: configuration)
        
        // create url session data task
        let task = session.dataTask(with: url) { [weak self] data, response, error in
            // catches error
            if let error = error{
                print("error fetching image: \(error)")
                self?.isLoading = false
                return
            }
            
            // convert the response data into a UIImage
            if let data = data, let fetchedImage = UIImage(data: data){
                DispatchQueue.main.async {
                    print("prompt: \(prompt)")
                    print("Image fetched successfully")
                    self?.image = fetchedImage
                    self?.isLoading = false

                }
            }
            
        }
        task.resume() // start the task

    }

}
