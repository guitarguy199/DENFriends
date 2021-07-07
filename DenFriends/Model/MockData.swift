//
//  MockData.swift
//  DenFriends
//
//  Created by Austin O'Neil on 7/2/21.
//

import CloudKit

struct MockData {
    static var location: CKRecord {
        let record = CKRecord(recordType: RecordType.location)
        record[DFLocation.kName]        = "Austin's Sports Bar"
        record[DFLocation.kAddress]     = "123 Main St"
        record[DFLocation.kDescription] = "This is a test description."
        record[DFLocation.kWebsiteURL]  = "https://www.apple.com"
        record[DFLocation.kLocation]    = CLLocation(latitude: 37.331516, longitude: -121.891054)
        record[DFLocation.kPhoneNumber] = "303-335-5761"
        
        return record
    }
    
    static var profile: CKRecord {
        let record = CKRecord(recordType: RecordType.profile)
        record[DFProfile.kFirstName]    = "Austin"
        record[DFProfile.kLastName]     = "O'Neil"
        record[DFProfile.kCompanyName]  = "Tangent Systems"
        record[DFProfile.kBio]          = "iOS Dev and Management Consultant"
        
        return record
    }
}
