//
//  PrivacyAndTerms.swift
//  test-app2
//
//  Created by Yonatan Mamo on 31.10.22.
//

import SwiftUI

struct PrivacyAndTerms: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("By continuing, you agree to our ") +
            Text(.init("[Terms of Service](https://testapp-79467.web.app/terms-and-conditions.html)")) +
            Text(" and acknowledge that you have read our ") +
            Text(.init("[Privacy Policy](https://testapp-79467.web.app/privacy.html)")) +
            Text(" to learn how we collect, use and share your data.") +
            Text(" This app is not affiliated with Spotify.")
//                .font(.system(size: 10))
        }
        .padding()
        .font(.caption2)
        
    }
}

