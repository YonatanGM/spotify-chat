//
//  CurrentUserSettings.swift
//  test-app2
//
//  Created by Yonatan Mamo on 04.10.22.
//

import SwiftUI
import SDWebImageSwiftUI

struct CurrentUserSettings: View {
    @EnvironmentObject var model: AppStateModel
    @State var isTapping: Bool = false
    @State var showCurrentUserSettings = false
    var body: some View {
        ZStack {
        
            NavigationLink(isActive: $showCurrentUserSettings,
                           destination: { CurrentUserDetail() },
                           label: { EmptyView() })
            .isDetailLink(false)
            if let currentUser = model.currentUser {
                if let url = currentUser.avatarURL {
                    AnimatedImage(url: url)
                        .resizable()
                        .scaledToFill()
                        .clipShape(Circle())
                        .frame(height: 25)
                       // .shadow(radius: 1)
                        
                } else {
                    UserPicInitials(name: currentUser.userName, applyShadow: false)
                        .frame(height: 25)
                       //.shadow(radius: 1)
                }
            }
        }
        .scaleEffect(isTapping ? 0.9 : 1)
        .brightness(isTapping ? 0.1 : 0)
        .onTapGesture {
            
            withAnimation(.easeIn(duration: 0.1)) {
                isTapping = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation {
                    isTapping = false
                }
                showCurrentUserSettings = true

            }
            
        }
//        .navigationDestination(isPresented: $model.showCurrentUserSettings) {
//            CurrentUserDetail()
//        }
    }
}
