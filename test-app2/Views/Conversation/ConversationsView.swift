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
    var body: some View {
        ZStack(alignment: .top) {
//
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
                    ForEach(model.groups, id: \.id) { group in
                        ConversationGroupRow(group: group)
                            .listRowBackground(Color.backdrop.brightness(selectedGroup == group.id && isTapping ? 0.3: 0).ignoresSafeArea())
                            .listRowInsets(.init(top: 10, leading: 10, bottom: 10, trailing: 10))
                            .scaleEffect(selectedGroup == group.id && isTapping ? 0.9 : 1)
            
                            .onTapGesture {
                                selectedGroup = group.id
                                // animation
                                withAnimation(.easeIn(duration: 0.1)) {
                                    isTapping = true
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    withAnimation {
                                        isTapping = false
                                        
                                    }

                                }
                            }
                    }
                  
                }
                .listStyle(.plain)
        }


                   
                    // the pending ones
//                    ForEach(model.pendingGroups, id: \.id) { group in
//                        ConversationGroupRowPending(group: group)
//
////                        HStack {
////                            Text("\(group)")
////                            Spacer()
////                        }
////                        .border(.red)
//
//                    }
                    
//                }

                   
//            }
            
//            .padding([.horizontal, .top], 10)
            
 
            .navigationTitle("Conversations")
            .navigationBarTitleDisplayMode(.inline)
            
            // bar
            .navigationBarItems(trailing: NewGroupButton()
                .frame(height: 20)
            
            )
            /*
            .overlay(
                HStack {
                    Spacer()
                   
                    NewGroupButton()

                }
                .frame(height: Double(UIScreen.main.bounds.width) / 10)
                .padding(10), alignment: .top
            )
             */
            
            
            
//        }
    }
}

struct ConversationsView_Previews: PreviewProvider {
    static var previews: some View {
        ConversationsView()
    }
}
