//
//  ConversationsView.swift
//  test-app2
//
//  Created by Yonatan Mamo on 14.09.22.
//

import SwiftUI

struct ConversationsView: View {
    @EnvironmentObject var model: AppStateModel
    @State var isTapping = false
    @State var isTappingAccept = false
    
    @State var selectedGroup: String?
    @State var showChat = false
    
    
    @State var rowTranslationOffset = 0.0
    @State var groupBeingDragged: String?
    var body: some View {
        ZStack(alignment: .top) {
            NavigationLink(isActive: $showChat,
                           destination: {
                if let selectedGroup = selectedGroup {
                    SwiftyChatView(groupID: selectedGroup)
                }
            }, label: { EmptyView() })
            
            LinearGradient(colors: [
                Color(.sRGB,
                      red: Double(20) / 255,
                      green: Double(20) / 255,
                      blue: Double(20) / 255,
                      opacity: 0.75),
                Color(.sRGB,
                      red: Double(10) / 255,
                      green: Double(10) / 255,
                      blue: Double(10) / 255,
                      opacity: 1)
                
            ], startPoint: .topLeading, endPoint: .center)
            .ignoresSafeArea(.all, edges: .all)

            List {
                ForEach(model.groups.sorted { $0.0 > $1.0 }, id: \.key) { id, group in
                    
                    ConversationGroupRow(group: group)
                        .listRowBackground(Color.backdrop.brightness(selectedGroup == group.id && isTapping ? 0.3: 0).ignoresSafeArea())
                        .listRowInsets(.init(top: 10, leading: 10, bottom: 10, trailing: 10))
                        .scaleEffect(selectedGroup == group.id && isTapping ? 0.9 : 1)
                        .contentShape(Rectangle())
                        .overlay(
                                              // Accept button
                            ZStack {
                                if group.pending == true {
                                    HStack {
                                        Text("Accept")
                                            .font(.headline)
                                    }
                                    .padding([.horizontal], 10)
                                    .padding([.vertical], 7.5)
                                    .foregroundColor(.white)
                                    .background(
                                        Color.backdrop
                                    )
                                    
                                    .clipShape(Capsule())
                                    .scaleEffect(selectedGroup == id && isTappingAccept ? 0.9 : 1)
                                    .brightness(selectedGroup == id && isTappingAccept ? 0.1 : 0)
                                    .onTapGesture {
                                        // animation
                                        selectedGroup = group.id
                                        withAnimation(.easeIn(duration: 0.1)) {
                                            isTappingAccept = true
                                        }
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                            withAnimation {
                                                isTappingAccept = false
                                            }
                                            DatabaseManager.shared.acceptPendingInvitation(group.id) { _ in
                                                
                                            }
                                            
                                        }
                                    }
                                } else {
//                                    if let unseenCount = model.groups[id]?.unseenCount, unseenCount >= 0 {
                                        HStack {
                                            Text("\( model.groups[id]?.unseenCount ?? -1)")
                                                .font(.headline)
                                        }
                                        .padding([.horizontal], 10)
                                        .padding([.vertical], 7.5)
                                        .foregroundColor(.white)
                                        .background(
                                            Color.backdrop
                                        )
                                        
                                        .clipShape(Capsule())
                                        .scaleEffect(selectedGroup == id && isTappingAccept ? 0.9 : 1)
                                        .brightness(selectedGroup == id && isTappingAccept ? 0.1 : 0)
//                                    }
                                }
                            }
                            , alignment: .trailing)
                            .onTapGesture {
                                selectedGroup = group.id
                                // animation
                                withAnimation(.easeIn(duration: 0.1)) {
                                    isTapping = true
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                                    withAnimation {
                                        isTapping = false
                                        
                                    }
                                    if group.pending == false {
                                        showChat = true
                                    }
                                    
                                }
                            }
                            .gesture(DragGesture(minimumDistance: 5, coordinateSpace: .global)
                                .onEnded { value in
                                    if value.translation.width < -1 * Double(UIScreen.main.bounds.width) / 2.5 {
                                        withAnimation(.spring()) {
                                            rowTranslationOffset = -1 * Double(UIScreen.main.bounds.width)
                                            
                                        }
                                        
                                        guard let currentUserID = AuthManager.shared.currentUser?.uid else {
                                            withAnimation(.spring(response: 0.2)) {
                                                rowTranslationOffset = 0
                                            }
                                            return
                                        }
                                        // current user is admin
                                        if currentUserID == group.admin {
                                            DatabaseManager.shared.deleteGroup(id) { success in
                                                if success == false  {
                                                    withAnimation(.spring(response: 0.2)) {
                                                        rowTranslationOffset = 0
                                                    }
                                                }
                                            }
                                        } else {
                                            DatabaseManager.shared.leaveGroup(id) { success in
                                                if success == false  {
                                                    withAnimation(.spring(response: 0.2)) {
                                                        rowTranslationOffset = 0
                                                    }
                                                }
                                            }
                                        }
                                    } else {
                                        withAnimation(.spring(response: 0.2)) {
                                            rowTranslationOffset = 0
                                        }
                                    }
                                }
                                .onChanged { value in
                                    if value.translation.width < 0  {
                                        groupBeingDragged = group.id
                                        rowTranslationOffset = value.translation.width
                                    }
                                }
                            )
                            .offset(x: groupBeingDragged == group.id ? rowTranslationOffset : 0.0)
                            .opacity(groupBeingDragged == group.id ? max(0.0, 1 + rowTranslationOffset * 2 /  Double(UIScreen.main.bounds.width)) : 1.0)
                }
                            
            }
            .listStyle(.plain)
        }
        .navigationTitle("Conversations")
        .navigationBarTitleDisplayMode(.inline)
        // bar
        .navigationBarItems(trailing: NewGroupButton().frame(height: 20))
    }
}
                            

