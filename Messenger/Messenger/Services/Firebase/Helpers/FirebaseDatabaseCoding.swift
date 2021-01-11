//
//  FirebaseDatabaseCoding.swift
//  Messenger
//
//  Created by Admin on 16.12.2020.
//

import Foundation

enum FirebaseDatabaseCoding {
    static func toDictionary<T>(_ data: T) -> [String: Any]? where T: Encodable {
        var dictionary: [String: Any]?
        
        do {
            let jsonEncoder = JSONEncoder()
            let jsonData = try jsonEncoder.encode(data)
            let dictionaryData = try JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers)
            
            dictionary = dictionaryData as? [String: Any]
        } catch let error {
            LoggingService.log(category: .database, layer: .none, type: .error, with: error.localizedDescription)
        }
        
        return dictionary
    }
    
    static func fromDictionary<T>(_ dictionary: [String: Any], type: T.Type) -> T? where T: Decodable {
        var jsonType: T?
        
        do {
            let jsonDecoder = JSONDecoder()
            let jsonData = try JSONSerialization.data(withJSONObject: dictionary)
            
            jsonType = try jsonDecoder.decode(T.self, from: jsonData)
        } catch let error {
            LoggingService.log(category: .database, layer: .none, type: .error, with: error.localizedDescription)
        }
        
        return jsonType
    }
}
