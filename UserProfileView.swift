//
//  UserProfileView.swift
//  test-app2
//
//  Created by Yonatan Mamo on 18.04.22.
//

import SwiftUI
import SDWebImageSwiftUI

struct UserProfileView: View {
    var profile: UserProfile
    var body: some View {
        Text(profile.display_name)
        if let urlString = profile.images.first?.url {

            AnimatedImage(url: URL(string: urlString))
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
                .cornerRadius(25)
        }
    }
}

/*
struct UserProfileView_Previews: PreviewProvider {
    static var previews: some View {
        UserProfileView()
    }
}
*/
