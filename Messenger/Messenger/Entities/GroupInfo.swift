//
//  GroupInfo.swift
//  Messenger
//
//  Created by Admin on 15.12.2020.
//

import Foundation

struct GroupInfo {
    let creatorIdentifier: String
    
    var name: String
    var profileImageData: Data?
    var moderatorsIdentifiers: [String]?
    //var members: [GroupMemberInfo]?
}



/*
 struct GroupMemberInfo {
     let identifier: String
     
     var name: String
     var profileImageData: Data?
 }
 */
