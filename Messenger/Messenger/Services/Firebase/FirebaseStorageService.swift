//
//  FirebaseStorageService.swift
//  Messenger
//
//  Created by Admin on 07.12.2020.
//

import FirebaseStorage

enum FirebaseStorageService {
    // MARK: Completions
    
    typealias StorageUploadCompletion = (StorageError?) -> Void
    typealias StorageDownloadCompletion = (String?, StorageError?) -> Void
    
    typealias DataDownloadCompletion = (Data?) -> Void
    
    // MARK: Properties
    
    enum StorageError: Error {
        case failedToUpload
        case failedToDownload
    }
    
    private enum Paths {
        static let images = "profileImages"
    }
    
    static private let storageReference = Storage.storage().reference()
}

// MARK: - Methods

extension FirebaseStorageService {
    static func uploadProfileImageData(_ data: Data,
                                       userIdentifier: String,
                                       completion: @escaping StorageUploadCompletion) {
        storageReference.child(Paths.images).child("\(userIdentifier).png").putData(data, metadata: nil) { _, error in
            guard error == nil else {
                completion(.failedToUpload)
                
                return
            }
            
            completion(nil)
        }
    }
    
    static func downloadProfileImageDataURL(userIdentifier: String, completion: @escaping StorageDownloadCompletion) {
        storageReference.child(Paths.images).child("\(userIdentifier).png").downloadURL { url, error in
            guard let urlString = url?.absoluteString, error == nil else {
                completion(nil, .failedToDownload)
                
                return
            }
            
            completion(urlString, nil)
        }
    }
    
    static func downloadProfileImageData(identifier: String, completion: @escaping DataDownloadCompletion) {
        downloadProfileImageDataURL(userIdentifier: identifier) { urlString, error in
            guard let urlString = urlString,
                  let url = URL(string: urlString), error == nil else {
                completion(nil)
                
                return
            }
            
            URLSession.shared.dataTask(with: url) { data, response, error in
                guard let data = data, response != nil, error == nil else {
                    completion(nil)
                    
                    return
                }
                
                completion(data)
            }
        }
    }
}
