//
//  StorageManager.swift
//  test-app2
//
//  Created by Yonatan Mamo on 23.06.23.
//
import Foundation
import FirebaseStorage

class StorageManager {
    
    static let shared = StorageManager()
    private let storage = Storage.storage()
    
    private init() {
        // You can use an emulator if you want
        storage.useEmulator(withHost: "192.168.178.87", port: 9199)
    }
    
    
    func uploadProfileImage(for id: String, url: String?, completion: @escaping (URL?) -> Void) {
        // Create a reference to the image you want to upload with the user id
        let imageRef = storage.reference().child("images/\(id)")
        
        // Create a URL for the user's spotify profile picture
        guard let url = url, let validUrl = URL(string: "\(url)") else {
            completion(nil)
            return
        }
        
        // Create a URL request for the image
        let urlRequest = URLRequest(url: validUrl)
        
        // Fetch the image data from the url
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            // Check for errors
            if let error = error {
                print("Error fetching image data: \(error)")
                completion(nil)
                return
            }
            
            
            // Check for valid data
            guard let data = data else {
                print("No data returned")
                completion(nil)
                return
            }
            
            guard let httpURLResponse = response as? HTTPURLResponse,
                  httpURLResponse.statusCode == 200 else {
                print("bad status code")
              return
            }
            
            
            
            // Upload the image data to the storage reference
            imageRef.putData(data, metadata: nil) { metadata, error in
                // Check for errors
                if let error = error {
                    print("Error uploading image data: \(error)")
                    completion(nil)
                    return
                }
               
                
                // Get the download URL of the uploaded image
                imageRef.downloadURL { url, error in
                    // Check for errors
                    if let error = error {
                        print("Error getting download URL: \(error)")
                        completion(nil)
                        return
                    }
                    
                    // Call the completion handler with the url
                    completion(url)
                }
            }
        }.resume()
    }
}
