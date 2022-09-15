//
//  CreateGroup.swift
//  test-app2
//
//  Created by Yonatan Mamo on 14.09.22.
//

import SwiftUI

struct CreateGroup: View {
    @State var isTapping: Bool = false
    @EnvironmentObject var model: AppStateModel
    @Binding var present: Bool
    @State var name = ""
    @State var nameIsMissing = false
    @State var addedUsers = [Message.ChatUserItem]()
    var body: some View {
        ZStack(alignment: .topLeading) {
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
                
            ], startPoint: .topLeading, endPoint: .bottom)
            ScrollView {
                VStack {
                    
                    HStack {
                        Spacer()
                        HStack {
                            Text("Done")
                                .font(.headline)
                        }
                        .padding([.horizontal], 10)
                        .padding([.vertical], 7.5)
                        
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
                                
                                if !name.isEmpty && !addedUsers.isEmpty  {
                                    DatabaseManager.shared.createGroup(with: addedUsers, name: name) { result in
                                        if result == true { // group creation is a success
                                            present = false  // hide the sheet
                                        }
                                    }
                                }
                            }
                        }
           
                    }
                    .padding([.top, .trailing], 10)
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Name of group")
                            .fontWeight(.light)
                            .font(.title) +
                        Text(" *").fontWeight(.light).font(.title2).baselineOffset(4).foregroundColor(name.isEmpty ? .white : .clear)
                        
                            
                        ZStack {
                            Color.backdrop
                            TextField("", text: $name) {
                       
                            }
                            .accentColor(.white)
                            .disableAutocorrection(true)
                            .padding(.leading)
                            .frame(height: 40)
                            
                        }
                        .foregroundColor(.white)
                        .clipShape(Capsule())
               
                    }

                    .padding([.horizontal], 10)
                    
                    UserCardViewGroupCreation(addedUsers: $addedUsers)
                    
                    
                    Spacer()
                }
                .foregroundColor(.white)
            }
        }
    }
    
    private func validateAndCreateGroup() {
        guard !name.isEmpty && !addedUsers.isEmpty else {
            return
        }
        
        DatabaseManager.shared.createGroup(with: addedUsers, name: name) { result in
            // print("group creation \(result)")
        }
    }
}

