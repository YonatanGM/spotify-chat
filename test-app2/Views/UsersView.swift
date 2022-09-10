//
//  UsersView.swift
//  test-app2
//
//  Created by Yonatan Mamo on 09.09.22.
//

import SwiftUI
import SDWebImageSwiftUI
import UIKit

struct UsersView: View {
    @EnvironmentObject var model: AppStateModel
    @State var selectedUserID: String?
    @State var isTapping = false
    @State var showUserDetail = false
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {

            HStack {
                ForEach(model.usersInCurrentRoom, id: \.id) { user in
                    

                    VStack {
                        if let url = user.avatarURL {
                            NavigationLink(isActive: $showUserDetail,
                                           destination: { Text(user.userName) },
                                           label: { EmptyView() })
                            AnimatedImage(url: url)
                                .resizable()
                                .scaledToFill()
                                .clipShape(Circle())
                                .frame(height: Double(UIScreen.main.bounds.width) / 3)
                            Spacer()
                            HStack {
                                Spacer()
                                VStack(alignment: .leading) {
                                    Text(user.userName)
                                        .font(.footnote)
                                        .foregroundColor(.white)
                                        .lineLimit(1)
                                
                                }
                                Spacer()
                            }
                            
                        }
                    }
                    .padding(5)
                    .cornerRadius(5)
                    .scaleEffect(selectedUserID == user.id && isTapping ? 0.9 : 1)
                    .brightness(selectedUserID == user.id && isTapping ? 0.1 : 0)
                    .onTapGesture {
                        selectedUserID = user.id
                        // animation
                        withAnimation(.easeIn(duration: 0.1)) {
                            isTapping = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            withAnimation {
                                isTapping = false
                                showUserDetail = true
                            }
                        }
                        
                    }

                }
            }
        }
    }
}

struct UsersView_Previews: PreviewProvider {
    static var previews: some View {
        UsersView()
    }
}
