//
//  DM.swift
//  test-app2
//
//  Created by Yonatan Mamo on 04.10.22.
//

import SwiftUI

struct DM: View {
    @State var showGroupChat = false
    @State var isTapping: Bool = false
    var buttonHeight = 25.0
    
    var body: some View {
        NavigationLink(isActive: $showGroupChat,
                       destination: { ConversationsView() },
                       label: { EmptyView() })
        HStack(alignment: .center, spacing: 0) {
            Image(systemName: "paperplane.fill")
                .resizable()
                .scaledToFit()
                .frame(height: buttonHeight)
                .scaleEffect(0.5)
        }
        .padding(buttonHeight / 5)
        .foregroundColor(.white)
        .background(Color.backdrop)
        .clipShape(Capsule())
        .scaleEffect(isTapping ? 0.9 : 1)
        .brightness(isTapping ? 0.1 : 0)
        .onTapGesture {
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
    }
}

