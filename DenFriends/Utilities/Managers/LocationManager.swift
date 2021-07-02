//
//  LocationManager.swift
//  DenFriends
//
//  Created by Austin O'Neil on 7/2/21.
//

import Foundation

final class LocationManager: ObservableObject {
    @Published var locations: [DFLocation] = []
}
