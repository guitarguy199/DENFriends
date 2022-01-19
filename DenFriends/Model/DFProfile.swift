//
//  DFProfile.swift
//  DenFriends
//
//  Created by Austin O'Neil on 7/2/21.
//

import UIKit
import CloudKit

struct DFProfile: Identifiable {
    
    static let kFirstName           = "firstName"
    static let kLastName            = "lastName"
    static let kAvatar              = "avatar"
    static let kCompanyName         = "companyName"
    static let kBio                 = "bio"
    static let kIsCheckedIn         = "isCheckedIn"
    static let kIsCheckedInNilCheck = "isCheckedInNilCheck"

    
    let id: CKRecord.ID
    let firstName: String
    let lastName: String
    let avatar: CKAsset!
    let companyName: String
    let bio: String
    let isCheckedIn: CKRecord.Reference?
    
    init(record: CKRecord) {
        id              = record.recordID
        firstName       = record[DFProfile.kFirstName] as? String ?? "N/A"
        lastName        = record[DFProfile.kLastName] as? String ?? "N/A"
        avatar          = record[DFProfile.kAvatar] as? CKAsset
        companyName     = record[DFProfile.kCompanyName] as? String ?? "N/A"
        bio             = record[DFProfile.kBio] as? String ?? "N/A"
        isCheckedIn     = record[DFProfile.kIsCheckedIn] as? CKRecord.Reference
    }
    
    var avatarImage: UIImage {
        guard let avatar = avatar else { return PlaceholderImage.avatar }
        return avatar.convertToUIImage(in: .square)
    }
    
    
}

