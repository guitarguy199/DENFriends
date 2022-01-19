//
//  HapticManager.swift
//  DenFriends
//
//  Created by Austin O'Neil on 1/18/22.
//

import UIKit

struct HapticManager {
    
    static func playSuccess() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}
