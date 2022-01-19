//
//  ProfileViewModel.swift
//  DenFriends
//
//  Created by Austin O'Neil on 7/2/21.
//

import CloudKit

enum ProfileContext { case create, update }

extension ProfileView {
    
    final class ProfileViewModel: ObservableObject {
        
        @Published var firstName   = ""
        @Published var lastName    = ""
        @Published var companyName = ""
        @Published var bio         = ""
        @Published var avatar      = PlaceholderImage.avatar
        @Published var isShowingPhotoPicker = false
        @Published var isLoading = false
        @Published var isCheckedIn = false
        @Published var alertItem: AlertItem?
        
        private var existingProfileRecord: CKRecord? {
            didSet { profileContext = .update }
        }
        var profileContext: ProfileContext = .create
        var buttonTitle: String {
            profileContext == .create ? "Create Profile" : "Update Profile"
        }
        
        func isValidProfile() -> Bool {
            
            guard !firstName.isEmpty,
                  !lastName.isEmpty,
                  !companyName.isEmpty,
                  !bio.isEmpty,
                  avatar != PlaceholderImage.avatar,
                  bio.count <= 100 else { return false }
            
            return true
        }
        
        func getCheckedInStatus() {
            guard let profileRecordID = CloudKitManager.shared.profileRecordID else { return }
            
            CloudKitManager.shared.fetchRecord(with: profileRecordID) { [self] result in
                
                DispatchQueue.main.async {
                    switch result {
                        
                    case .success(let record):
                        if let _ = record[DFProfile.kIsCheckedIn] as? CKRecord.Reference {
                            isCheckedIn = true
                        } else {
                            isCheckedIn = false
                            print("isCheckedIn = false")
                        }
                    case .failure(_):
                        break
                    }
                }
                
                
            }
        }
        
        func checkOut() {
            guard let profileID = CloudKitManager.shared.profileRecordID else {
                alertItem = AlertContext.unableToGetProfile
                return
            }
            
            showLoadingView()
            CloudKitManager.shared.fetchRecord(with: profileID) { result in

                switch result {
                    
                case .success(let record):
                    record[DFProfile.kIsCheckedIn] = nil
                    record[DFProfile.kIsCheckedInNilCheck] = nil
                    CloudKitManager.shared.save(record: record) { [self] result in
                        DispatchQueue.main.async {
                            self.hideLoadingView()
                            switch result {
                                
                            case .success(_):
                                HapticManager.playSuccess()
                                isCheckedIn = false
                                
                            case .failure(_):
                                alertItem = AlertContext.unableToCheckInOrOut
                            }
                        }
                    }
                case .failure(_):
                    self.hideLoadingView()
                    DispatchQueue.main.async {
                        self.alertItem = AlertContext.unableToCheckInOrOut
                    }
                }
            }
        }
        
        
        func determineButtonAction() {
            profileContext == .create ? createProfile() : updateProfile()
        }
        
        
        private func createProfile() {
            guard isValidProfile() else {
                alertItem = AlertContext.invalidProfile
                return
            }
            
            let profileRecord = createProfileRecord()
            
            guard let userRecord = CloudKitManager.shared.userRecord else {
                alertItem = AlertContext.noUserRecord
                return
            }
            
            userRecord["userProfile"] = CKRecord.Reference(recordID: profileRecord.recordID, action: .none)
            showLoadingView()
            CloudKitManager.shared.batchSave(records: [userRecord, profileRecord]) { result in
                DispatchQueue.main.async { [self] in
                    hideLoadingView()
                    switch result {
                        
                    case .success(let records):
                        for record in records where record.recordType == RecordType.profile {
                            existingProfileRecord = record
                            CloudKitManager.shared.profileRecordID = record.recordID
                        }
                        alertItem = AlertContext.createProfileSuccess
                        break
                    case .failure(_):
                        alertItem  = AlertContext.createProfileFailure
                        break
                    }
                }
                
                
            }
            
        }
        
        
        
        func getProfile() {
            
            guard let userRecord = CloudKitManager.shared.userRecord else {
                alertItem = AlertContext.noUserRecord
                return
            }
            
            guard let profileReference = userRecord["userProfile"] as? CKRecord.Reference else {
                return
            }
            
            let profileRecordID = profileReference.recordID
            showLoadingView()
            CloudKitManager.shared.fetchRecord(with: profileRecordID) { result in
                DispatchQueue.main.async { [self] in
                    hideLoadingView()
                    switch result {
                        
                    case .success(let record):
                        existingProfileRecord = record
                        let profile = DFProfile(record: record)
                        firstName   = profile.firstName
                        lastName    = profile.lastName
                        companyName = profile.companyName
                        bio         = profile.bio
                        avatar      = profile.avatarImage
                        
                    case .failure(_):
                        alertItem = AlertContext.unableToGetProfile
                        break
                    }
                }
            }
        }
        
       private func updateProfile() {
            guard isValidProfile() else {
                alertItem = AlertContext.invalidProfile
                return
            }
            
            guard let profileRecord = existingProfileRecord else {
                alertItem = AlertContext.unableToGetProfile
                return
            }
            
            profileRecord[DFProfile.kFirstName]   = firstName
            profileRecord[DFProfile.kLastName]    = lastName
            profileRecord[DFProfile.kCompanyName] = companyName
            profileRecord[DFProfile.kBio]         = bio
            profileRecord[DFProfile.kAvatar]      = avatar.convertToCKAsset()
            
            showLoadingView()
            CloudKitManager.shared.save(record: profileRecord) { result in
                DispatchQueue.main.async { [self] in
                    hideLoadingView()
                    switch result {
                        
                    case .success(_):
                        alertItem = AlertContext.updateProfileSuccess
                    case .failure(_):
                        alertItem = AlertContext.updateProfileFailure
                    }
                }
                
            }
            
            
        }
        
        private func createProfileRecord() -> CKRecord {
            let profileRecord = CKRecord(recordType: RecordType.profile)
            profileRecord[DFProfile.kFirstName]   = firstName
            profileRecord[DFProfile.kLastName]    = lastName
            profileRecord[DFProfile.kCompanyName] = companyName
            profileRecord[DFProfile.kBio]         = bio
            profileRecord[DFProfile.kAvatar]      = avatar.convertToCKAsset()
            
            return profileRecord
        }
        
        private func showLoadingView() { isLoading = true }
        private func hideLoadingView() { isLoading = false }
    }
    
    
}

