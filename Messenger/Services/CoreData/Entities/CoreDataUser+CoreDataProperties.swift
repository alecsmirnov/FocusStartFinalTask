//
//  CoreDataUser+CoreDataProperties.swift
//  Messenger
//
//  Created by Admin on 15.12.2020.
//
//

import Foundation
import CoreData

extension CoreDataUser {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CoreDataUser> {
        return NSFetchRequest<CoreDataUser>(entityName: "CoreDataUser")
    }

    @NSManaged public var identifier: String
    @NSManaged public var email: String
    
    @NSManaged public var firstName: String
    @NSManaged public var lastName: String?
    
    @NSManaged public var profileImageURL: String?
    
    @NSManaged public var chat: CoreDataChat?
}

extension CoreDataUser : Identifiable {}
