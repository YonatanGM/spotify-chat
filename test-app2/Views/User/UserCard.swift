//
//  UserCard.swift
//  test-app2
//
//  Created by Yonatan Mamo on 12.09.22.
//

import SwiftUI
import SDWebImageSwiftUI
import UIKit

struct UserCard: View {
    
    @EnvironmentObject var model: AppStateModel
    @State var selectedUserID: String?
    @State var isTapping = false
    @State var showUserDetail = false
    let user: Message.ChatUserItem
    
    
    
    var body: some View {
        
        VStack {
            NavigationLink(isActive: $showUserDetail,
                           destination: { UserDetail(user: user) },
                           label: { EmptyView() })
            VStack {
                UserIcon(user: .init(id: user.id, name: user.userName, photoURL: user.avatarURL?.absoluteString, genreDisplay: nil))
                    .onAppear {
                        print(user.userName, user.avatarURL)
                    }
                HStack {
                    Spacer()
                    Text(user.userName)
                        .font(.footnote)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .lineLimit(1)
                    Spacer()
                    
                }
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 1) {
                        if let topArtistResponse = user.topArtists {
                            ForEach(topArtistResponse.items.prefix(20), id: \.id) { artist in
                                if let urlString = artist.images?.first?.url,
                                   let url = URL(string: urlString) {
                                    ArtistAnimatedIcon(url: url)
                                }
                            }
                        }
                    }
                    
                }
                .frame(width: 125, height: 18)
                .coordinateSpace(name: "artistIcons")
                .cornerRadius(10)
            }
            .frame(width: Double(UIScreen.main.bounds.width) / 3)
            .padding([.vertical], 10)
            .padding([.horizontal])
        }
        .background(Color.backdrop)
        .cornerRadius(5)
        .scaleEffect(selectedUserID == user.id && isTapping ? 0.9 : 1)
        .brightness(selectedUserID == user.id && isTapping ? 0.1 : 0)
        .onTapGesture {
            // print(model.usersInCurrentRoom.map { $0.id })
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
   
