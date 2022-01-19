//
//  CloudKitManager.swift
//  DenFriends
//
//  Created by Austin O'Neil on 7/2/21.
//

import CloudKit

final class CloudKitManager {
    
    //initialize CKManager as a singleton
    static let shared = CloudKitManager()
    //makes CKManager only initialize the first time it's used
    private init() {}
    
    var userRecord: CKRecord?
    var profileRecordID: CKRecord.ID?
    
    func getUserRecord() {
        CKContainer.default().fetchUserRecordID { recordID, error in
            guard let recordID = recordID, error == nil else {
                print(error!.localizedDescription)
                return
            }
            CKContainer.default().publicCloudDatabase.fetch(withRecordID: recordID) { userRecord, error in
                guard let userRecord = userRecord, error == nil else {
                    print(error!.localizedDescription)
                    return
                }
                
                self.userRecord = userRecord
                
                if let profileReference = userRecord["userProfile"] as? CKRecord.Reference {
                    self.profileRecordID = profileReference.recordID
                }
                
            }
        }
    }
    
    
    func getLocations(completed: @escaping (Result<[DFLocation], Error>) -> Void) {
        
        let sortDescriptor = NSSortDescriptor(key: DFLocation.kName, ascending: true)
        
        let query = CKQuery(recordType: RecordType.location, predicate: NSPredicate(value: true))
        
        query.sortDescriptors = [sortDescriptor]
        
        CKContainer.default().publicCloudDatabase.perform(query, inZoneWith: nil) { records, error in
            guard let records = records, error == nil else {
                completed(.failure(error!))
                return
            }
            
            let locations = records.map(DFLocation.init)
            completed(.success(locations))
        }
    }
    
    func getCheckedInProfiles(for locationID: CKRecord.ID, completed: @escaping (Result<[DFProfile], Error>) -> Void) {
        let reference = CKRecord.Reference(recordID: locationID, action: .none)
        let predicate = NSPredicate(format: "isCheckedIn == %@", reference)
        let query     = CKQuery(recordType: RecordType.profile, predicate: predicate)
        
        CKContainer.default().publicCloudDatabase.perform(query, inZoneWith: nil) { records, error in
            guard let records = records, error == nil else {
                completed(.failure(error!))
                return
            }
            let profiles = records.map(DFProfile.init)
            completed(.success(profiles))
        }
    }
    
    func getCheckedInProfilesDictionary(completed: @escaping (Result<[CKRecord.ID: [DFProfile]], Error>) -> Void) {
        let predicate = NSPredicate(format: "isCheckedInNilCheck == 1")
        let query = CKQuery(recordType: RecordType.profile, predicate: predicate)
        let operation = CKQueryOperation(query: query)
        //        run this line if you want to optimize network call. Only calls keys we need, but doesn't future-proof
        //        operation.desiredKeys = [DDGProfile.kIsCheckedIn, DDGProfile.kAvatar]
        
        var checkedInProfiles: [CKRecord.ID: [DFProfile]] = [:]
        
        operation.recordFetchedBlock = { record in
            //Build dictionary
            let profile = DFProfile(record: record)
            
            guard let locationReference = record[DFProfile.kIsCheckedIn] as? CKRecord.Reference else { return }
            
            checkedInProfiles[locationReference.recordID, default: []].append(profile)
        }
        operation.queryCompletionBlock = { cursor, error in
            guard error == nil else {
                completed(.failure(error!))
                return
            }
            
            if let cursor = cursor {
                self.continueWithCheckedInProfilesDict(cursor: cursor, dictionary: checkedInProfiles) { result in
                    switch result {
                        
                    case .success(let profiles):
                        completed(.success(profiles))
                    case .failure(let error):
                        completed(.failure(error))
                    }
                }
            } else {
                    completed(.success(checkedInProfiles))
                }
        }
        CKContainer.default().publicCloudDatabase.add(operation)
    }
    
    
    func continueWithCheckedInProfilesDict(cursor: CKQueryOperation.Cursor,
                                           dictionary: [CKRecord.ID: [DFProfile]],
                                           completed: @escaping (Result<[CKRecord.ID: [DFProfile]], Error>) -> Void) {
        
        var checkedInProfiles = dictionary
        let operation = CKQueryOperation(cursor: cursor)
        
        operation.recordFetchedBlock = { record in
            let profile = DFProfile(record: record)
            guard let locationReference = record[DFProfile.kIsCheckedIn] as? CKRecord.Reference else { return }
            checkedInProfiles[locationReference.recordID, default: []].append(profile)
        }
        
        operation.queryCompletionBlock = { cursor, error in
            
            
            guard error == nil else {
                completed(.failure(error!))
                return
            }
            
            if let cursor = cursor {
                self.continueWithCheckedInProfilesDict(cursor: cursor, dictionary: checkedInProfiles) { result in
                    switch result {
                        
                    case .success(let profiles):
                        completed(.success(profiles))
                    case .failure(let error):
                        completed(.failure(error))
                    }
                }
            } else {
                    completed(.success(checkedInProfiles))
                }
            }
            
        CKContainer.default().publicCloudDatabase.add(operation)
        
    }
    
    
    func getCheckedInProfilesCount(completed: @escaping (Result<[CKRecord.ID: Int], Error>) -> Void) {
        let predicate = NSPredicate(format: "isCheckedInNilCheck == 1")
        let query     = CKQuery(recordType: RecordType.profile, predicate: predicate)
        let operation = CKQueryOperation(query: query)
        //        run this line if you want to optimize network call. Only calls keys we need, but doesn't future-proof
        operation.desiredKeys = [DFProfile.kIsCheckedIn]
        
        var checkedInProfiles: [CKRecord.ID: Int] = [:]
        
        operation.recordFetchedBlock = { record in
            
            guard let locationReference = record[DFProfile.kIsCheckedIn] as? CKRecord.Reference else { return }
            
            if let count = checkedInProfiles[locationReference.recordID] {
                checkedInProfiles[locationReference.recordID] = count + 1
            } else {
                checkedInProfiles[locationReference.recordID] = 1
            }
        }
        operation.queryCompletionBlock = { cursor, error in
            guard error == nil else {
                completed(.failure(error!))
                return
            }
            
            completed(.success(checkedInProfiles))
        }
        CKContainer.default().publicCloudDatabase.add(operation)
    }
    
    
    
    func batchSave(records: [CKRecord], completed: @escaping (Result<[CKRecord], Error>) -> Void) {
        let operation = CKModifyRecordsOperation(recordsToSave: records)
        operation.modifyRecordsCompletionBlock = { savedRecords, _, error  in
            guard let savedRecords = savedRecords, error == nil else {
                print(error!.localizedDescription)
                completed(.failure(error!))
                return
            }
            completed(.success(savedRecords))
        }
        CKContainer.default().publicCloudDatabase.add(operation)
    }
    
    func save(record: CKRecord, completed: @escaping (Result<CKRecord, Error>) -> Void) {
        CKContainer.default().publicCloudDatabase.save(record) { record, error in
            guard let record = record, error == nil else {
                completed(.failure(error!))
                return
            }
            
            completed(.success(record))
        }
    }
    
    func fetchRecord( with id: CKRecord.ID, completed: @escaping (Result<CKRecord, Error>) -> Void) {
        CKContainer.default().publicCloudDatabase.fetch(withRecordID: id) { record, error in
            guard let record = record, error == nil else {
                completed(.failure(error!))
                return
            }
            
            completed(.success(record))
        }
    }
    
}
