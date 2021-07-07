//
//  LocationMapViewModel.swift
//  DenFriends
//
//  Created by Austin O'Neil on 7/2/21.
//

import MapKit
import CloudKit

final class LocationMapViewModel: ObservableObject {
    
    @Published var checkedInProfiles: [CKRecord.ID: Int] = [:]
    @Published var isShowingDetailView = false
    @Published var alertItem: AlertItem?
    @Published var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 39.753170, longitude: -105.000076), span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02))
    
    func getLocations(for locationManager: LocationManager) {
        CloudKitManager.shared.getLocations { [self] result in
            DispatchQueue.main.async {
                switch result {
                
                case .success( let locations):
                    locationManager.locations = locations
                case .failure(_):
                    alertItem = AlertContext.unableToGetLocations
             }
          }
       }
     }
    
    
    func getCheckedInCounts() {
        CloudKitManager.shared.getCheckedInProfilesCount { result in
            DispatchQueue.main.async {
                switch result {
                
                case .success(let checkedInProfiles):
                    self.checkedInProfiles = checkedInProfiles
                case .failure(_):
                    // show alert
                print("Failure")
                }
            }
        
        }
    }
  }
