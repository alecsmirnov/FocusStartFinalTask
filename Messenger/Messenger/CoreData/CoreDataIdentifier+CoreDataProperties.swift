//
//  CoreDataIdentifier+CoreDataProperties.swift
//  Messenger
//
//  Created by Admin on 14.12.2020.
//
//

import Foundation
import CoreData

extension CoreDataIdentifier {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CoreDataIdentifier> {
        return NSFetchRequest<CoreDataIdentifier>(entityName: "CoreDataIdentifier")
    }

    @NSManaged public var identifier: String
    
    @NSManaged public var group: CoreDataGroup?
}

extension CoreDataIdentifier : Identifiable {

}
