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
                    if let urlString = admin.photoURL,
                       let url = URL(string: urlString) {
                        AnimatedImage(url: url)
                            .resizable()
                            .scaledToFit()
                            .clipShape(Circle())
                            .shadow(radius: 5)
                            
                    } else {
                        UserPicInitials(name: admin.name)
                    }
                    
                    VStack(alignment: .leading, spacing: 2.5) {
                        Spacer()
                        VStack(alignment: .leading, spacing: -2.5) {
                            Text(group.name)
                                .font(.title)
                                .foregroundColor(.white)
                                .fontWeight(.semibold)
                            if let lastMessage = lastMessage, group.pending == false {
                                Text(lastMessage)
                                    .italic()
                                    .fontWeight(.light)
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
            } else {
                HStack {
                    if let urlString = group.otherUser?.photoURL,
                       let url = URL(string: urlString) {
                        AnimatedImage(url: url)
                            .resizable()
                            .scaledToFit()
                            .clipShape(Circle())
                            .shadow(radius: 5)
                    } else {
                        UserPicInitials(name:  group.otherUser?.name ?? "")
                    }
                    
                    VStack(alignment: .leading, spacing: 2.5) {
                        Spacer()
                        VStack(alignment: .leading, spacing: -2.5) {
                            Text(group.otherUser?.name ?? "")
                                .font(.title)
                                .foregroundColor(.white)
                                .fontWeight(.semibold)
                            if let lastMessage = lastMessage {
                                Text(lastMessage)
                                    .italic()
                                    .fontWeight(.light)
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
