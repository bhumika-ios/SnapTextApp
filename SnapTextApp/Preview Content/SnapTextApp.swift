//
//  SnapTextApp.swift
//  SnapTextApp
//
//  Created by Bhumika Patel on 21/11/24.
//

import SwiftUI
import Vision
import UIKit

struct SnapTextApp: View {
    @State private var image: UIImage? = nil
    @State private var extractedText: String = "No text extracted yet."
    @State private var isImagePickerPresented = false

    var body: some View {
        VStack {
            // Image Display Section
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 200) // Set the specific size
                    .clipShape(RoundedRectangle(cornerRadius: 20)) // Rounded rectangle frame
                    .shadow(radius: 5) // Optional: Add a shadow for aesthetics
                    .onTapGesture {
                        isImagePickerPresented = true
                    }
            } else {
                Text("Tap to upload an image")
                    .foregroundColor(.gray)
                    .font(.headline)
                    .frame(width: 300, height: 200) // Match placeholder size with image frame
                    .background(Color.gray.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .onTapGesture {
                        isImagePickerPresented = true
                    }
            }
            // Text Board Below
            VStack(alignment: .leading, spacing: 8) {
                Text("Extracted Text:")
                    .font(.headline)
                ScrollView {
                    VStack{
                        HStack{
                            Spacer()
                            Button(action: {
                                UIPasteboard.general.string = extractedText
                            }) {
                                Image(systemName: "square.on.square")
                                Text("Copy Text")
                                   
                                //                    .foregroundColor(.white)
                                //                    .padding()
                                //                    .frame(maxWidth: .infinity)
                                //                    .background(Color.blue)
                                //                    .cornerRadius(8)
                            }
                        }
                        .offset(y:-10)
                        .font(.caption)
                        .foregroundColor(.black)
                        Text(extractedText)
                            
                    }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                    
                }
            }
            .padding()

            // Copy to Clipboard Button
//            Button(action: {
//                UIPasteboard.general.string = extractedText
//            }) {
//                Image(systemName: "square.on.square")
//                Text("Copy Text")
//                    .font(.caption)
////                    .foregroundColor(.white)
////                    .padding()
////                    .frame(maxWidth: .infinity)
////                    .background(Color.blue)
////                    .cornerRadius(8)
//            }
            .padding()

//            Spacer()
        }
        .padding()
        .sheet(isPresented: $isImagePickerPresented) {
            ImagePicker(image: $image, onImagePicked: performTextRecognition)
        }
    }

    // Function to perform text recognition
    private func performTextRecognition(from image: UIImage) {
        guard let cgImage = image.cgImage else {
            extractedText = "Could not process the image."
            return
        }

        let request = VNRecognizeTextRequest { request, error in
            if let error = error {
                extractedText = "Error: \(error.localizedDescription)"
            } else if let observations = request.results as? [VNRecognizedTextObservation] {
                let recognizedStrings = observations.compactMap { $0.topCandidates(1).first?.string }
                extractedText = recognizedStrings.joined(separator: "\n")
            } else {
                extractedText = "No text found in the image."
            }
        }

        // Perform the request
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                DispatchQueue.main.async {
                    extractedText = "Failed to perform text recognition: \(error.localizedDescription)"
                }
            }
        }
    }
}

// Helper View for Image Picker
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    var onImagePicked: (UIImage) -> Void

    func makeCoordinator() -> Coordinator {
        return Coordinator(self, onImagePicked: onImagePicked)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        var onImagePicked: (UIImage) -> Void

        init(_ parent: ImagePicker, onImagePicked: @escaping (UIImage) -> Void) {
            self.parent = parent
            self.onImagePicked = onImagePicked
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let selectedImage = info[.originalImage] as? UIImage {
                parent.image = selectedImage
                onImagePicked(selectedImage)
            }
            picker.dismiss(animated: true)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}

struct SnapTextApp_Previews: PreviewProvider {
    static var previews: some View {
        SnapTextApp()
    }
}
