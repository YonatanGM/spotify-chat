//
//  StorageManager.swift
//  test-app2
//
//  Created by Yonatan Mamo on 01.05.22.
//

import Foundation
import FirebaseStorage

class StorageManager {
    
    static let shared = StorageManager()
    
    private let storage : StorageReference = {
        var storageEmu = Storage.storage()
        storageEmu.useEmulator(withHost:"localhost", port:9199)
        return storageEmu.reference()
    }()
    
    
    public typealias UploadPictureCompletion = (Result<String, Error>) -> Void
    /// Uploads picture to firebase storage and returns completion with url string to download
    public func uploadProfilePicture(with data: Data, fileName: String, completion: @escaping UploadPictureCompletion) {
        
        storage.child("images/\(fileName)").putData(data, metadata: nil, completion: { [weak self] metadata, error in
            guard error == nil else {
                // failed to upload
                print("failed to upload pic to firebase storage")
                completion(.failure(StorageError.failedToUpload))
                return
            }
            
            self?.storage.child("images/\(fileName)").downloadURL(completion: { url, error in
                guard let url = url else {
                    print("Failed to get download url")
                    completion(.failure(StorageError.failedToGetDownloadUrl))
                    return
                }
                
                let urlString = url.absoluteString
                print("download url returned: \(urlString)")
                completion(.success(urlString))

            })
            
            
        })
        
        
    }
    
    public enum StorageError: Error {
        case failedToUpload
        case failedToGetDownloadUrl
    }
    
}

