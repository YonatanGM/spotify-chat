//
//  NewGroupButton.swift
//  test-app2
//
//  Created by Yonatan Mamo on 14.09.22.
//

import SwiftUI

struct NewGroupButton: View {
    @State var isTapping: Bool = false
    @State var presentSheet: Bool = false
    var body: some View {
        Button(action: {
            // animation
            withAnimation(.easeIn(duration: 0.1)) {
                isTapping = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation {
                    isTapping = false
                    
                }
                presentSheet = true
            }
            
        }, label: {
        
            Label("New group", systemImage: "plus")
                .accentColor(.white)
        })
        .scaleEffect(isTapping ? 0.9 : 1)
        .brightness(isTapping ? 0.1 : 0)
        .sheet(isPresented: $presentSheet,
               onDismiss: { }) {
            CreateGroup(present: $presentSheet)
        }
        
    }
}

struct NewGroupButton_Previews: PreviewProvider {
    static var previews: some View {
        NewGroupButton()
    }
}
