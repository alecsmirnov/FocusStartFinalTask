//
//  ObserverData.swift
//  Messenger
//
//  Created by Admin on 16.12.2020.
//

import FirebaseDatabase

struct ObserverData {
    let reference: DatabaseReference
    let handle: UInt
    
    func remove() {
        reference.removeObserver(withHandle: handle)
    }
}
