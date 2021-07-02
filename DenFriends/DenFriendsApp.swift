//
//  DenFriendsApp.swift
//  DenFriends
//
//  Created by Austin O'Neil on 7/2/21.
//

import SwiftUI

@main
struct DenFriendsApp: App {
    
    let locationManager = LocationManager()
    
    var body: some Scene {
        WindowGroup {
            AppTabView()
                .environmentObject(locationManager)
        }
    }
}
