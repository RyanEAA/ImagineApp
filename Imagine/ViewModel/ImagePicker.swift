//
//  ImagePicker.swift
//  Imagine
//
//  Created by Ryan Aparicio on 12/8/24.
//

import Foundation
import SwiftUI
import PhotosUI

struct ImagePicker: UIViewControllerRepresentable{
    @Binding var isPresented: Bool // binding to control the presentation of the image picker
    @Binding var image: UIImage? // binding to hold selected image
    
    var  sourceType: UIImagePickerController.SourceType // specifies the source type of where the image is going to come from
    
    // handles delegation of UIImagePickerController
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = sourceType
        return picker
    }
    
    // used to update view
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        
    }
    
    // handles delegate methods of UIImagePickerController
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate{
        var parent: ImagePicker
        
        init(parent: ImagePicker){
            self.parent = parent
        }
        // delegate function called when image is selected
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            // retrieve the selected image
            if let uiImage = info[.originalImage] as? UIImage{
                parent.image = uiImage
            }
            parent.isPresented = false
            // Dismiss the image picker
        }
        
        // delegate method when image picker is cancelled
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            // dismiss the image picker
            parent.isPresented = false
        }
        
    }
    
}

struct PhotoPicker: UIViewControllerRepresentable {
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
        
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate{
        // reference parent photopicker struct
        var parent: PhotoPicker
        
        init(parent: PhotoPicker){
            self.parent = parent
        }
        
        // delegate method for when image is selected
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]){
            if let result = results.first{
                result .itemProvider.loadObject(ofClass: UIImage.self) { object, error in
                    if let uiImage = object as? UIImage {
                        DispatchQueue.main.async {
                            self.parent.selectedImage = uiImage // assign selected image to parents selected image property
                        }
                    }
                }
            }
            picker.dismiss(animated: true, completion: nil) // dimiss photo picker
        }
    }
    
    @Binding var selectedImage: UIImage? // binding to hold selectedImage
    
    
    // creates coordinator instance which handles delegation of PHPickerViewController
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    // method creates a PHPickerViewController instance with specified configuration
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        
        // limiting selection to 1 image
        configuration.selectionLimit = 1
        // filter for images only
        configuration.filter = PHPickerFilter.any(of: [.images, .screenshots])
        let picker = PHPickerViewController(configuration: configuration)
        
        picker.delegate = context.coordinator
        
        return picker
    }
}
