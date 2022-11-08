//
//  ConversationRowUserPicBubbles.swift
//  test-app2
//
//  Created by Yonatan Mamo on 16.09.22.
//

import SwiftUI
import SDWebImageSwiftUI

struct ConversationGroupRow: View {
    @EnvironmentObject var model: AppStateModel
    let group: Group
    
    var admin: UserInfo! {
        group.users.filter { $0.id == group.admin }.first
    }
    
    var lastMessage: String? {
        guard let message = group.messages.last?.messageKind else {
            return nil
        }
        switch message {
        case .text(let messageString):
            return messageString
        default:
            return nil
        }
    }
    
    var body: some View {
        
        ZStack {
            if !group.isDm {
                HStack {
                    UserBubbles(users: group.users)
                    
                    VStack(alignment: .leading, spacing: 2.5) {
                        Spacer()
                        VStack(alignment: .leading, spacing: -2.5) {
                            Text(group.name)
                                // .font(.title)
                                .font(Font.custom("Modulus-Bold2", size: UIFont.preferredFont(forTextStyle: .title1).pointSize))
                                .fontWeight(.semibold)
                                .lineLimit(1)
                                .foregroundColor(.white)
                            if let lastMessage = lastMessage, group.pending == false {
                                Text(lastMessage)
                                    // .italic
                                    .fontWeight(.light)
                                    .lineLimit(1)
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.leading, 7.5)
               
                        GeometryReader { geometry in
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 1) {
                                    ForEach(group.users.compactMap { $0.genreDisplay }.unique, id: \.self ) { genre in
                                        GenresAnimatedIcon(genre: genre, parentFrame: geometry.size)
                                    }
                                }
                            }
                            .clipShape(Capsule())
                            .coordinateSpace(name: "userDetailGenres")
                        }
                        .frame(height: 15)
                        Spacer()
                    }
                    Spacer()
                }
                .frame(height: 60)
            } else {
                HStack {
                    if let otherUser = group.otherUser {
                       // let url = URL(string: urlString)  {
                        UserIcon(user: otherUser)
                    }
                    
                    VStack(alignment: .leading, spacing: 2.5) {
                        Spacer()
                        VStack(alignment: .leading, spacing: -2.5) {
                            Text(group.otherUser?.name ?? "")
                                .font(Font.custom("Modulus-Bold2", size: UIFont.preferredFont(forTextStyle: .title1).pointSize))
                                .fontWeight(.semibold)
                                .lineLimit(1)
                                .foregroundColor(.white)
                            if let lastMessage = lastMessage {
                                Text(lastMessage)
                                    // .italic()
                                    .fontWeight(.light)
                                    .lineLimit(1)
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.leading, 7.5)
               
                        GeometryReader { geometry in
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 1) {
                                    ForEach(group.users.compactMap { $0.genreDisplay }.unique, id: \.self ) { genre in
                                        GenresAnimatedIcon(genre: genre, parentFrame: geometry.size)
                                    }
                                }
                            }
                            .clipShape(Capsule())
                        }
                        .frame(height: 15)
                        Spacer()
                    }
                    Spacer()
                }
                .frame(height: 60)
            }
        }
       
    }
}
