//
//  NewGroupButton.swift
//  test-app2
//
//  Created by Yonatan Mamo on 14.09.22.
//

import SwiftUI

struct NewGroupButton: View {
    @State var presentSheet: Bool = false
    var body: some View {
        Button {
            presentSheet = true
        } label: {
            Label("New group", systemImage: "plus")
                .foregroundColor(.white)
        }
        .buttonStyle(.borderless)
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
