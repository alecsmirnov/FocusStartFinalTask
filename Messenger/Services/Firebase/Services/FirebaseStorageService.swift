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
    
    private enum Folders {
        static let profileImages = "profile_images"
    }
    
    private static let storageReference = Storage.storage().reference()
}

// MARK: - Methods

extension FirebaseStorageService {
    static func uploadProfileImageData(
        _ data: Data,
        userIdentifier: String,
        completion: @escaping StorageUploadCompletion
    ) {
        storageReference
            .child(Folders.profileImages)
            .child("\(userIdentifier).png")
            .putData(data, metadata: nil) { _, error in
            guard error == nil else {
                completion(.failedToUpload)
                
                return
            }
            
            completion(nil)
        }
    }
    
    static func downloadProfileImageDataURL(userIdentifier: String, completion: @escaping StorageDownloadCompletion) {
        storageReference.child(Folders.profileImages).child("\(userIdentifier).png").downloadURL { url, error in
            guard let urlString = url?.absoluteString, error == nil else {
                completion(nil, .failedToDownload)
                
                return
            }
            
            completion(urlString, nil)
        }
    }
    
    static func downloadProfileImageData(identifier: String, completion: @escaping DataDownloadCompletion) {
        downloadProfileImageDataURL(userIdentifier: identifier) { urlString, error in
            guard
                let urlString = urlString,
                let url = URL(string: urlString), error == nil
            else {
                completion(nil)
                
                return
            }
            
            let dataTask = URLSession.shared.dataTask(with: url) { data, response, error in
                guard let data = data, response != nil, error == nil else {
                    completion(nil)
                    
                    return
                }
                
                completion(data)
            }
            
            dataTask.resume()
        }
    }
    
    static func downloadProfileImageData(urlString: String, completion: @escaping DataDownloadCompletion) {
        guard let url = URL(string: urlString) else { return }
        
        let dataTask = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, response != nil, error == nil else {
                completion(nil)
                
                return
            }
            
            completion(data)
        }
        
        dataTask.resume()
    }
}
