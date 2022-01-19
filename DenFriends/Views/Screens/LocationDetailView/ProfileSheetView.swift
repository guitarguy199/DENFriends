//
//  ProfileSheetView.swift
//  DenFriends
//
//  Created by Austin O'Neil on 1/13/22.
//

import SwiftUI

// Alternative profile modal view for larger dynamic type sizes

struct ProfileSheetView: View {
    
    var profile: DFProfile
    
    var body: some View {
        
        ScrollView {
            VStack(spacing: 20) {
                
                Image(uiImage: profile.avatarImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 110, height: 110)
                    .clipShape(Circle())
//                    .shadow(color: .black.opacity(0.5), radius: 4, x: 0, y: 6)
                    .accessibilityHidden(true)
                
                Text(profile.firstName + " " + profile.lastName)
                    .bold()
                    .font(.title2)
                    .minimumScaleFactor(0.9)
                
                Text(profile.companyName)
                    .fontWeight(.semibold)
                    .minimumScaleFactor(0.75)
                    .foregroundColor(.secondary)
                    .accessibilityLabel(Text("works at \(profile.companyName)"))
                
                Text(profile.bio)
                    .accessibilityLabel(Text("Bio, \(profile.bio)"))
            }
            .padding()
        }
    }
}

struct ProfileSheetView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileSheetView(profile: DFProfile(record: MockData.profile))
            .environment(\.dynamicTypeSize, .accessibility5)
    }
}
