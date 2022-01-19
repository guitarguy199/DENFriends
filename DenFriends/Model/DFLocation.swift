//
//  DFLocation.swift
//  DenFriends
//
//  Created by Austin O'Neil on 7/2/21.
//

import CloudKit
import UIKit

struct DFLocation: Identifiable {
    
    
    
    static let kName        = "name"
    static let kDescription = "description"
    static let kSquareAsset = "squareAsset"
    static let kBannerAsset = "bannerAsset"
    static let kAddress     = "address"
    static let kLocation    = "location"
    static let kWebsiteURL  = "websiteURL"
    static let kPhoneNumber = "phoneNumber"
    
    let id: CKRecord.ID
    let name: String
    let description: String
    let squareAsset: CKAsset!
    let bannerAsset: CKAsset!
    let address: String
    let location: CLLocation
    let websiteURL: String
    let phoneNumber: String
    
    init(record: CKRecord) {
        id          = record.recordID
        name        = record[DFLocation.kName] as? String ?? "N/A"
        description = record[DFLocation.kDescription] as? String ?? "N/A"
        squareAsset = record[DFLocation.kSquareAsset] as? CKAsset
        bannerAsset = record[DFLocation.kBannerAsset] as? CKAsset
        address     = record[DFLocation.kAddress] as? String ?? "N/A"
        location    = record[DFLocation.kLocation] as? CLLocation ?? CLLocation(latitude: 0, longitude: 0)
        websiteURL  = record[DFLocation.kWebsiteURL] as? String ?? "https://www.yelp.com"
        phoneNumber = record[DFLocation.kPhoneNumber] as? String ?? "N/A"
        
    }
    
    var squareImage: UIImage {
        guard let asset = squareAsset else { return PlaceholderImage.square }
        return asset.convertToUIImage(in: .square)
    }
    
    
    
    var bannerImage: UIImage {
        
        guard let asset = bannerAsset else { return PlaceholderImage.banner }
        return asset.convertToUIImage(in: .banner)
    }
    
    
}
