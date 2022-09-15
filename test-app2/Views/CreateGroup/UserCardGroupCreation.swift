//
//  UserCardGroupCreation.swift
//  test-app2
//
//  Created by Yonatan Mamo on 14.09.22.
//

import SwiftUI
import SDWebImageSwiftUI


struct UserCardGroupCreation: View {
    let user: Message.ChatUserItem
    let namespace: Namespace.ID
    var body: some View {
        VStack {
            
            VStack {
                if let url = user.avatarURL {
                    AnimatedImage(url: url)
                        .resizable()
                        .scaledToFit()
                        .clipShape(Circle())
                        .frame(height: Double(UIScreen.main.bounds.width) / 3)
                        .shadow(radius: 5)
                        .matchedGeometryEffect(id: user.id, in: namespace)
                } else {
//                    InitialsUI(initials: user.userName.components(separatedBy: " ").first ?? "", useDefaultForegroundColor: true, fontWeight: .light)
                    
                    Image(systemName: "circle.fill")
                        .resizable()
                        .foregroundColor(.gray)
                    
                        .scaledToFit()
                        .clipShape(Circle())
                        .frame(height: Double(UIScreen.main.bounds.width) / 3)
                        .shadow(radius: 5)
                        .overlay(
                            Text(user.userName.components(separatedBy: " ").reduce("") { ($0.first?.description ?? "") +  ($1.first?.description ?? "")})
                                .font(.largeTitle)
                                .fontWeight(.thin)
                                .foregroundColor(.white)
                                
                        , alignment: .center)
                        .matchedGeometryEffect(id: "picInitial" + user.id, in: namespace)
                        
                        
                    
                }
                
                HStack {
                    Spacer()
                    Text(user.userName)
                        .font(.body)
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
                .frame(height: 20)
                .frame(width: 125)
                .cornerRadius(10)
                .animation(nil)
            }
            .padding([.vertical], 10)
            .padding([.horizontal])
            
        }
        .background(Color.backdrop.animation(nil))
        .cornerRadius(5)

    }
}

