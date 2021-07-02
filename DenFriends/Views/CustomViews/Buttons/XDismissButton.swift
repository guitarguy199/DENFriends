//
//  XDismissButton.swift
//  DenFriends
//
//  Created by Austin O'Neil on 7/2/21.
//

import SwiftUI

struct XDismissButton: View {
    var body: some View {
        ZStack {
            Circle()
                .foregroundColor(.brandPrimary)
                .frame(width: 30, height: 30)
            Image(systemName: "xmark")
                .foregroundColor(.white)
                .imageScale(.small)
                .frame(width: 44, height: 44)
        }
    }
}

struct XDismissButton_Previews: PreviewProvider {
    static var previews: some View {
        XDismissButton()
    }
}

