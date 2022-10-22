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
    @State var onlineStatusHandle: UInt?
    @State var isOnline = false
    
    
    let user: Message.ChatUserItem
    var body: some View {

        VStack {
            NavigationLink(isActive: $showUserDetail,
                           destination: { UserDetail(user: user) },
                           label: { EmptyView() })
            
            VStack {
                if let url = user.avatarURL {
                    AnimatedImage(url: url)
                        .resizable()
                        .scaledToFit()
                        .clipShape(Circle())
                        
                        .shadow(radius: 5)
                        .overlay(
                            GeometryReader { geometry in
                                ZStack {
                                    Image(systemName: "circle.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 10)
                                        .foregroundColor(.green)
                                        .offset(x: cos(Angle(degrees: -45).radians) * geometry.size.width / 2,
                                                y: sin(Angle(degrees: -45).radians) * geometry.size.height / 2)
                                    
                            
                                }
                                .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
                            }
                            .opacity(isOnline ? 1.0 : 0.0 )
                        )
                } else {
                    UserPicInitials(name: user.userName)
  
                        .overlay(
                            GeometryReader { geometry in
                                ZStack {
                                    Image(systemName: "circle.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 10)
                                        .foregroundColor(.green)
                                        .offset(x: cos(Angle(degrees: -45).radians) * geometry.size.width / 2,
                                                y: sin(Angle(degrees: -45).radians) * geometry.size.height / 2)
                                    
                            
                                }
                                .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
                            }
                            .opacity(isOnline ? 1.0 : 0.0 )
                        )
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
        .onAppear {
            // check online status
            onlineStatusHandle = DatabaseManager.shared.checkOnlineStatus(for: user.id) { status in
                isOnline = status
                
            }
        }
        .onDisappear {
            if let onlineStatusHandle = onlineStatusHandle {
                DatabaseManager.shared.removeObserver(with: onlineStatusHandle)
            }
           
        }
    }
}
   
