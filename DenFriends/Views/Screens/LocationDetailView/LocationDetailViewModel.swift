//
//  LocationDetailViewModel.swift
//  DenFriends
//
//  Created by Austin O'Neil on 7/2/21.
//

import SwiftUI
import MapKit
import CloudKit

enum CheckInStatus { case checkedIn, checkedOut }

final class LocationDetailViewModel: ObservableObject {
    
    @Published var checkedInProfiles: [DFProfile] = []
    @Published var isShowingProfileModal = false
    @Published var isCheckedIn = false
    @Published var isLoading = false
    @Published var alertItem: AlertItem?
    
    let columns = [GridItem(.flexible()),
                   GridItem(.flexible()),
                   GridItem(.flexible())]
    
    var location: DFLocation
    
    init(location: DFLocation) {
        self.location = location
    }
    
    func getDirectionsToLocation() {
        let placemark = MKPlacemark(coordinate: location.location.coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = location.name
        
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking])
        
    }
    
    func callLocation() {
        guard let url = URL(string: "tel://\(location.phoneNumber)") else {
            alertItem=AlertContext.invalidPhoneNumber
            return
        }
       
        //check for phone capatability, else return an alert
        // if UIApplication.shared.canOpenURL(url) {
        //}
        UIApplication.shared.open(url)
    }
    
    func getCheckedInStatus() {
        guard let profileRecordID = CloudKitManager.shared.profileRecordID else { return }
        
        CloudKitManager.shared.fetchRecord(with: profileRecordID) { [self] result in
            
            DispatchQueue.main.async {
                switch result {
                
                case .success(let record):
                    if let reference = record[DFProfile.kIsCheckedIn] as? CKRecord.Reference {
                        isCheckedIn = reference.recordID == location.id
                    } else {
                        isCheckedIn = false
                        print("isCheckedIn = false")
                    }
                case .failure(_):
                    alertItem = AlertContext.unableToGetCheckInStatus
                }
            }
            
       
        }
    }
    
    func updateCheckInStatus(to checkInStatus: CheckInStatus) {
        // Retrieve the DDGProfile
        
        guard let profileRecordID = CloudKitManager.shared.profileRecordID else {
            alertItem = AlertContext.unableToGetProfile
            return
        }
        
        CloudKitManager.shared.fetchRecord(with: profileRecordID) { [self] result in
            switch result {
            
            case .success(let record):
            // Create reference to location
                switch checkInStatus {
                case .checkedIn:
                    record[DFProfile.kIsCheckedIn] = CKRecord.Reference(recordID: location.id, action: .none)
                    record[DFProfile.kIsCheckedInNilCheck] = 1
                case .checkedOut:
                    record[DFProfile.kIsCheckedIn] = nil
                    record[DFProfile.kIsCheckedInNilCheck] = nil
                }
            // Save the updated profile to CloudKit
                CloudKitManager.shared.save(record: record) { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(_):
                            let profile = DFProfile(record: record)
                            
                            switch checkInStatus {
                            
                            case .checkedIn:
                                checkedInProfiles.append(profile)
                            case .checkedOut:
                                checkedInProfiles.removeAll(where:{$0.id == profile.id})
                            }
                            
                            isCheckedIn =  checkInStatus == .checkedIn
                            
                            print("Checked in/out successfully")
                        case .failure(_):
                            alertItem = AlertContext.unableToCheckInOrOut
                        }
                    }
                }
                
            case .failure(_):
                alertItem = AlertContext.unableToCheckInOrOut
            }
        }
    }
    
    func getCheckedInProfiles() {
        showLoadingView()
        CloudKitManager.shared.getCheckedInProfiles(for: location.id) { [self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let profiles):
                    checkedInProfiles = profiles
                case .failure(_):
                    alertItem = AlertContext.unableToGetCheckedInProfiles
                }
                hideLoadingView()
            }
        }
    }
    
    private func showLoadingView() { isLoading = true }
    private func hideLoadingView() { isLoading = false }
    
}

