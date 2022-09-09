//
//  BAR.swift
//  test-app2
//
//  Created by Yonatan Mamo on 09.09.22.
//

import SwiftUI

struct Bar: View {
    var body: some View {
        HStack {
            Spacer()
            ChatButton()
            InviteButton()
        }
        .frame(height: Double(UIScreen.main.bounds.width) / 10)

 
    }
}

struct BAR_Previews: PreviewProvider {
    static var previews: some View {
        Bar()
    }
}
