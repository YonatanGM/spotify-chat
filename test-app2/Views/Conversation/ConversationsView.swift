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
    
    @State var selectedGroup: String?
    @State var showChat = false
    
    
    @State var rowTranslationOffset = 0.0
    @State var groupBeingDragged: String?
    
    // 10 groups max
    private var canCreateGroups: Bool {
        guard let currentUserID =  AuthManager.shared.currentUser?.uid else {
            return false
        }
        return model.groups.filter { $0.1.admin == currentUserID }.count <= 10
    }
    
    var body: some View {
        NavigationLink(isActive: $showChat,
                       destination: {
                            if let selectedGroup = selectedGroup {
                                SwiftyChatView(groupID: selectedGroup, showChat: $showChat)
                            }
                        },
                       label: { EmptyView() })
        
        List {
            ForEach(model.groups.sorted { $0.0 > $1.0 }, id: \.key) { id, group in
                ConversationGroupRow(group: group)
                    .listRowBackground(Color.backdrop.brightness(selectedGroup == group.id && isTapping ? 0.3: 0))
                    .listRowInsets(.init(top: 10, leading: 10, bottom: 10, trailing: 10))
                    .scaleEffect(selectedGroup == group.id && isTapping ? 0.9 : 1)
                    .contentShape(Rectangle())
                    .overlay(alignment: .trailing) {
                        if group.pending {
                            Button("Accept") {
                                selectedGroup = group.id
                                DatabaseManager.shared.acceptPendingInvitation(group.id) { _ in }
                            }
                            .buttonStyle(.bordered)
                            .buttonBorderShape(.capsule)
                            .foregroundColor(.white)
                        }
                    }
                    .overlay(alignment: .trailing) {
                        if let unseenCount = group.unseenCount, unseenCount > 0 {
                            Button("\(unseenCount)") {
                                selectedGroup = group.id
                                DatabaseManager.shared.acceptPendingInvitation(group.id) { _ in }
                            }
                            .buttonStyle(.bordered)
                            .buttonBorderShape(.capsule)
                            .foregroundColor(.white)
                            .allowsHitTesting(false)
                        }
                    }
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
                    .swipeActions(edge: .trailing) {
                        if let currentUserID = AuthManager.shared.currentUser?.uid {
                            Button {
                                if currentUserID == group.admin {
                                     DatabaseManager.shared.deleteGroup(id) { _ in }
                                 } else {
                                     DatabaseManager.shared.leaveGroup(id) { _ in }
                                 }
                            } label: {
                                if group.pending == false {
                                    if currentUserID == group.admin {
                                        Image(systemName: "trash")
                                    } else {
                                        Image(systemName: "person.crop.circle.fill.badge.minus")
                                    }
                                } else {
                                    Image(systemName: "trash")
                                }
                            }
                            .tint(.backdrop)
                           
                        }
                    }
            }
        }
        .listStyle(.plain)
        .background(
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
        )

        .navigationTitle("Conversations")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(trailing:
            NewGroupButton()
                .frame(height: 20)
                .disabled(!canCreateGroups)
        )
    }
}
                            

