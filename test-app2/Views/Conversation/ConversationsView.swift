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
    
    var pendingGroups: [Group] {
        model.groups.filter { $0.pending == true }.reversed()
    }
    
   
    var body: some View {
        ZStack(alignment: .top) {
            NavigationLink(isActive: $showChat,
                           destination: {
                if let selectedGroup = selectedGroup {
                    SwiftyChatView(groupID: selectedGroup)
                }
            },
                           label: { EmptyView() })
            
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
            
            //            ScrollView(showsIndicators: false) {
            // list groups the user is currently in first
            List {
                // ForEach(Array(model.groups.keys.sorted(by: >)), id: \.self) { key in
                
                if !pendingGroups.isEmpty {
                        ForEach(pendingGroups, id: \.id) { group in
                            ConversationGroupRow(group: group)
                                .listRowBackground(Color.backdrop.brightness(selectedGroup == group.id && isTapping ? 0.3: 0).ignoresSafeArea())
                                .listRowInsets(.init(top: 10, leading: 10, bottom: 10, trailing: 10))
                                .scaleEffect(selectedGroup == group.id && isTapping ? 0.9 : 1)
                                 .contentShape(Rectangle())
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
                                        showChat = true
                                    }
                                }
                        }
       
                }

                ForEach(model.groups.filter { $0.pending == false }.reversed(), id: \.id) { group in
                    ConversationGroupRow(group: group)
                        .listRowBackground(Color.backdrop.brightness(selectedGroup == group.id && isTapping ? 0.3: 0).ignoresSafeArea())
                        .listRowInsets(.init(top: 10, leading: 10, bottom: 10, trailing: 10))
                        .scaleEffect(selectedGroup == group.id && isTapping ? 0.9 : 1)
                         .contentShape(Rectangle())
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
                                showChat = true
                                
                            }
                            
                        }
                }
                
            }
            .listStyle(.plain)
        }

        .navigationTitle("Conversations")
        .navigationBarTitleDisplayMode(.inline)
        
        // bar
        .navigationBarItems(trailing: NewGroupButton()
            .frame(height: 20)
                            
        )
    }
}

struct ConversationsView_Previews: PreviewProvider {
    static var previews: some View {
        ConversationsView()
    }
}
