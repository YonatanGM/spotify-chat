//
//  UsersView.swift
//  test-app2
//
//  Created by Yonatan Mamo on 09.09.22.
//

import SwiftUI
import SDWebImageSwiftUI
import UIKit

struct GroupsView: View {
    @EnvironmentObject var model: AppStateModel
    @State var selectedUserID: String?
    @State var isTapping = false
    @State var showUserDetail = false
    
    var body: some View {
        VStack {
            
            ScrollView(.horizontal, showsIndicators: false) {

                HStack {
                    ForEach(model.usersInCurrentRoom, id: \.id) { user in
                        

                        VStack {
                            NavigationLink(isActive: $showUserDetail,
                                           destination: { Text(user.userName) },
                                           label: { EmptyView() })
                            if let url = user.avatarURL {
                                AnimatedImage(url: url)
                                    .resizable()
                                    .scaledToFill()
                                    .clipShape(Circle())
                                    .frame(height: Double(UIScreen.main.bounds.width) / 3)
                                Spacer()
                                HStack {
                                    Spacer()
                                    VStack(alignment: .leading) {
                                        Text(user.userName)
                                            .font(.footnote)
                                            .foregroundColor(.white)
                                            .lineLimit(1)
                                    
                                    }
                                    Spacer()
                                }
                                
                            } else {
                                // no profile pic
                                Image(systemName: "person.fill")
                                    .resizable()
                                    .scaledToFill()
                                    .clipShape(Circle())
                                    .frame(height: Double(UIScreen.main.bounds.width) / 3)
                                Spacer()
                                HStack {
                                    Spacer()
                                    VStack(alignment: .leading) {
                                        Text(user.userName)
                                            .font(.footnote)
                                            .foregroundColor(.white)
                                            .lineLimit(1)
                                    
                                    }
                                    Spacer()
                                }
                                
                            }
                        }
                        .padding(5)
                        .cornerRadius(5)
                        .scaleEffect(selectedUserID == user.id && isTapping ? 0.9 : 1)
                        .brightness(selectedUserID == user.id && isTapping ? 0.1 : 0)
                        .onTapGesture {
                            selectedUserID = user.id
                            // animation
                            withAnimation(.easeIn(duration: 0.1)) {
                                isTapping = true
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                withAnimation {
                                    isTapping = false
                                    // showUserDetail = true
                                    DatabaseManager.shared.createGroup(with: model.usersInCurrentRoom, name: UUID().uuidString) { success in
                                        print(success)
                                        
                                    }
                                    
                                }
                            }
                            
                            
                            
                        }

                    }
                }
            }
        }
    }
}

struct GroupsView_Previews: PreviewProvider {
    static var previews: some View {
        UsersView()
    }
}

