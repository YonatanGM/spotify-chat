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
    @State var shouldAnimate = false
    let user: Message.ChatUserItem
    var body: some View {
        VStack {
            VStack {
                NavigationLink(isActive: $showUserDetail,
                               destination: { Text(user.userName) },
                               label: { EmptyView() })
                if let url = user.avatarURL {
                    AnimatedImage(url: url)
                        .resizable()
                        .scaledToFit()
                        .clipShape(Circle())
                        .frame(height: Double(UIScreen.main.bounds.width) / 3)
                    VStack {
               
                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHStack(spacing: 0) {
                                if let topArtistResponse = user.topArtists {
                                    ForEach(topArtistResponse.items.prefix(20), id: \.id) { artist in
                                        if let urlString = artist.images?.first?.url,
                                            let url = URL(string: urlString) {
                                            ArtistAnimatedIcon(url: url, shouldAnimate: shouldAnimate)
    
                                        }
                                    }
                                }
                            }
                            .background(GeometryReader {
                                Color.clear.preference(key: ViewOffsetKey.self,
                                value: -$0.frame(in: .named("scroll")).origin.x)
                            }).onPreferenceChange(ViewOffsetKey.self) {
                                // print("offset >> \($0)")
                                shouldAnimate = $0 > 0.0
                                // print(" SS", shouldAnimate)
                                
                            }
                           
                        }
                        .frame(height: 20)
        
                        .coordinateSpace(name: "scroll")
                        .frame(width: Double(UIScreen.main.bounds.width) / 4)
                        .cornerRadius(10)
                    Text(user.userName)
                            .font(.headline)
                        .foregroundColor(.white)
                        .lineLimit(1)
                        
                        
                    }

   
                } else {
                    // no profile pic
                    Image(systemName: "person.fill")
                        .resizable()
                        .scaledToFill()
                        // .clipShape(Circle())
                        .cornerRadius(5)
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
            
            .padding(10)
     
        }

        .cornerRadius(5)

        
        .scaleEffect(selectedUserID == user.id && isTapping ? 0.9 : 1)
        .brightness(selectedUserID == user.id && isTapping ? 0.1 : 0)
        .onTapGesture {
            print(model.usersInCurrentRoom.map { $0.id })
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

struct ViewOffsetKey: PreferenceKey {
    typealias Value = CGFloat
    static var defaultValue = CGFloat.zero
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value += nextValue()
    }
}

/*
struct UserCard_Previews: PreviewProvider {
    static var previews: some View {
        UserCard()
    }
}
*/
