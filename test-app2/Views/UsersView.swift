//
//  UsersView.swift
//  test-app2
//
//  Created by Yonatan Mamo on 09.09.22.
//

import SwiftUI


struct UsersView: View {
    @EnvironmentObject var model: AppStateModel

    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {

            HStack {
                ForEach(model.usersInCurrentRoom, id: \.id) { user in
                    UserCard2(user: user)



                }
            }
        }

    }
}

struct UsersView_Previews: PreviewProvider {
    static var previews: some View {
        UsersView()
    }
}
