//
//  CoreDataGroup+CoreDataProperties.swift
//  Messenger
//
//  Created by Admin on 15.12.2020.
//
//

import Foundation
import CoreData

extension CoreDataGroup {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CoreDataGroup> {
        return NSFetchRequest<CoreDataGroup>(entityName: "CoreDataGroup")
    }

    @NSManaged public var creatorIdentifier: String
    @NSManaged public var name: String
    
    @NSManaged public var profileImageData: Data?
    @NSManaged public var moderatorsIdentifiers: NSSet?
    
    @NSManaged public var chat: CoreDataChat?
}

// MARK: Generated accessors for moderatorsIdentifiers

extension CoreDataGroup {
    @objc(addModeratorsIdentifiersObject:)
    @NSManaged public func addToModeratorsIdentifiers(_ value: CoreDataIdentifier)

    @objc(removeModeratorsIdentifiersObject:)
    @NSManaged public func removeFromModeratorsIdentifiers(_ value: CoreDataIdentifier)

    @objc(addModeratorsIdentifiers:)
    @NSManaged public func addToModeratorsIdentifiers(_ values: NSSet)

    @objc(removeModeratorsIdentifiers:)
    @NSManaged public func removeFromModeratorsIdentifiers(_ values: NSSet)

}

extension CoreDataGroup : Identifiable {}
