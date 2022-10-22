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
    @State var isOnline = false
    @State var onlineStatusHandle: UInt?
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
                    if let otherUser = group.otherUser {
                       // let url = URL(string: urlString)  {
                        UserIcon(user: otherUser)
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
                .onAppear {
                    // check online status
                    guard let id = group.otherUser?.id else { return }
                    onlineStatusHandle = DatabaseManager.shared.checkOnlineStatus(for: id) { status in
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
       
    }
}
