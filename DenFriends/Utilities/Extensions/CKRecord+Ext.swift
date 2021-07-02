//
//  CKRecord+Ext.swift
//  DenFriends
//
//  Created by Austin O'Neil on 7/2/21.
//

import CloudKit

extension CKRecord {
    
    func convertToDFLocation() -> DFLocation { DFLocation(record: self) }
    func convertToDFProfile() -> DFProfile { DFProfile(record: self) }
}

