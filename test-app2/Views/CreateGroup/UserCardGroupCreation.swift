//
//  UserCardGroupCreation.swift
//  test-app2
//
//  Created by Yonatan Mamo on 14.09.22.
//

import SwiftUI
import SDWebImageSwiftUI

struct UserCardGroupCreation: View {
    let namespace: Namespace.ID
    let user: Message.ChatUserItem
    var body: some View {
        VStack {
            VStack {
                if let url = user.avatarURL {
                    VStack {
                        AnimatedImage(url: url)
                            .resizable()
                            .scaledToFit()
                            .clipShape(Circle())
                           
                            .shadow(radius: 5)
                 
                            .matchedGeometryEffect(id: "pic", in: namespace)
                            
                        
                        HStack {
                            Spacer()
                            Text(user.userName)
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .lineLimit(1)
                            Spacer()

                        } 

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

                }
            }
            
            .padding([.vertical], 10)
            .padding([.horizontal])
     
        }
        
        .background(Color.backdrop)
        .cornerRadius(5)

    }
}

