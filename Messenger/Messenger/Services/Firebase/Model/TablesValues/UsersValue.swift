//
//  UsersValue.swift
//  Messenger
//
//  Created by Admin on 24.11.2020.
//

struct UsersValue: Codable {
    // MARK: Properties
    
    var firstName: String { info.firstName }
    var lastName: String? { info.lastName }
    var userName: String? { info.userName }
    var email: String { info.email }
    var profilePhotoURL: String? { info.profilePhotoURL }
    
    private let info: Info
    
    // MARK: Initialization
    
    init(firstName: String, lastName: String?, userName: String?, email: String, profilePhotoURL: String?) {
        info = Info(firstName: firstName,
                    lastName: lastName,
                    userName: userName,
                    email: email,
                    profilePhotoURL: profilePhotoURL)
    }
}

fileprivate struct Info {
    // MARK: Properties
    
    let firstName: String
    let lastName: String?
    let userName: String?
    let email: String
    let profilePhotoURL: String?
    
    private let queryableName: String
    private let queryableUsername: String?
    
    // MARK: Initialization
    
    init(firstName: String, lastName: String?, userName: String?, email: String, profilePhotoURL: String?) {
        self.firstName = firstName
        self.lastName = lastName
        self.userName = userName
        self.email = email
        self.profilePhotoURL = profilePhotoURL
        
        queryableName = "\(firstName) \(lastName ?? "")".lowercased()
        queryableUsername = userName?.lowercased()
    }
}

// MARK: - Codable

extension Info: Codable {
    enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName = "last_name"
        case userName = "user_name"
        case email
        case profilePhotoURL = "profile_photo_url"
        
        case queryableName = "queryable_name"
        case queryableUsername = "queryable_user_name"
    }
}
