//
//  LocationListViewModel.swift
//  DenFriends
//
//  Created by Austin O'Neil on 7/2/21.
//

import Foundation
import CloudKit

final class LocationListViewModel: ObservableObject {
    
    @Published var checkedInProfiles: [CKRecord.ID: [DFProfile]] = [:]
    
    func getCheckedInProfilesDictionary() {
        CloudKitManager.shared.getCheckedInProfilesDictionary { result in
            DispatchQueue.main.async {
                switch result {
                
                case .success(let checkedInProfiles):
                    self.checkedInProfiles = checkedInProfiles
                    print(checkedInProfiles)
                case .failure(_):
                    print("Error getting back dictionary")
                }
            }
          
        }
    }
}

