//
//  ChatButton.swift
//  test-app2
//
//  Created by Yonatan Mamo on 09.09.22.
//

import SwiftUI
import UIKit

struct ChatButton: View {
    @EnvironmentObject var model: AppStateModel
    var numOfUnseenMessages: Int {
        
        model.groups.keys.reduce(0) {
            print($1)
            print(model.groups[$1]?.unseenCount)
            return $0 + (model.groups[$1]?.unseenCount ?? 0)
        }
    }
    @State var showGroupChat = false
    @State var isTapping: Bool = false
    @State var lastSeenHandle: UInt?
    
    var body: some View {
        NavigationLink(isActive: $showGroupChat,
                       destination: { ConversationsView() },
                       label: { EmptyView() })
        HStack(spacing:0) {
            Image(systemName: "paperplane.fill")
                .resizable()
                .scaledToFit()
            if numOfUnseenMessages > 0 {
                Text("\(numOfUnseenMessages)")
                    .scaleEffect(0.8, anchor: .topTrailing)
                
                
            }
            
        }
        .padding([.horizontal], 10)
        .padding([.vertical], 7.5)
        .foregroundColor(.white)
        .background(
            Color.backdrop
        )
        
        .clipShape(Capsule())
        .scaleEffect(isTapping ? 0.9 : 1)
        .brightness(isTapping ? 0.1 : 0)
        .onTapGesture {
            // animation
            withAnimation(.easeIn(duration: 0.1)) {
                isTapping = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation {
                    isTapping = false 
                }
                showGroupChat = true

            }
            
        }
//        .onChange(of: model.indicesOfLastMessages) { indices in
//            print(indices)
//
//        }
//        .onAppear {
//            lastSeenHandle = DatabaseManager.shared.observeLastSeenMessage { (groupID, messageID) in
//                print(groupID, messageID)
//
//
//            }
//        }
//        .onDisappear {
//            if let handle = lastSeenHandle {
//                DatabaseManager.shared.removeObserver(with: handle)
//            }
//        }
               
    }
       


}


struct ChatButton_Previews: PreviewProvider {
    static var previews: some View {
        ChatButton()
    }
}
