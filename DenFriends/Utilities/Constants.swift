//
//  Constants.swift
//  DenFriends
//
//  Created by Austin O'Neil on 7/2/21.
//

import UIKit

enum RecordType {
    static let location = "DFLocation"
    static let profile = "DFProfile"
}

enum PlaceholderImage {
    static let avatar = UIImage(named: "default-avatar")!
    static let square = UIImage(named: "default-square-asset")!
    static let banner = UIImage(named: "default-banner-asset")!
}

enum ImageDimension {
    case square, banner
    
    static func getPlaceholder(for dimension: ImageDimension) -> UIImage {
        switch dimension {
        
        case .square:
            return PlaceholderImage.square
        case .banner:
            return PlaceholderImage.banner
        }
    }
}

