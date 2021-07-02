//
//  UIImage+Ext.swift
//  DenFriends
//
//  Created by Austin O'Neil on 7/2/21.
//

import CloudKit
import UIKit

extension UIImage {
    
    func convertToCKAsset() -> CKAsset? {
        
        //get apps base doc directory url
        guard let urlPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Document directory URL came back nil")
            return nil
        }
        
        // append some unique id for our profile image
        let fileUrl = urlPath.appendingPathComponent("selectedAvatarImage")
        // write the image data to the location the address points to
        guard let imageData = jpegData(compressionQuality: 0.25) else { return nil }
        // create our CKAsset with that fileURL
        do {
            try imageData.write(to: fileUrl)
            return CKAsset(fileURL: fileUrl)
        } catch {
            return nil
        }
    }
}
