//
//  AppTabViewModel.swift
//  DenFriends
//
//  Created by Austin O'Neil on 7/5/21.
//

import MapKit
import SwiftUI


extension AppTabView {
    
    final class AppTabViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
        @Published var isShowingOnboardView = false
        @AppStorage("hasSeenOnboardView") var hasSeenOnboardView = false {
            didSet { isShowingOnboardView = hasSeenOnboardView }
        }
        

        let kHasSeenOnboardView = "hasSeenOnboardView"
        
        
        func checkIfHasSeenOnboard() {
            if !hasSeenOnboardView {
                hasSeenOnboardView = true
            }
        }
    }
}
