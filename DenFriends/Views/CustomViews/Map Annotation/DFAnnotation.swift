//
//  DFAnnotation.swift
//  DenFriends
//
//  Created by Austin O'Neil on 7/2/21.
//

import SwiftUI

struct DFAnnotation: View {
    
    var location: DFLocation
    var number: Int
    
    var body: some View {
        VStack {
            ZStack {
                MapBalloon()
                    .frame(width: 100, height: 70)
                    .foregroundColor(.brandPrimary)
                Image(uiImage: location.createSquareImage())
                    .resizable()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                    .offset(y: -11)
                if number > 0 {
                    Text("\(min(number, 99))")
                        .font(.system(size: 11, weight: .bold))
                        .frame(width: 26, height: 18)
                        .background(Color.grubRed)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                        .offset(x: 20, y: -28)
                }
             
            }
          
            Text(location.name)
                .font(.caption)
                .fontWeight(.semibold)
        }
    }
}

struct DFAnnotation_Previews: PreviewProvider {
    static var previews: some View {
        DFAnnotation(location: DFLocation(record: MockData.location), number: 44)
    }
}
