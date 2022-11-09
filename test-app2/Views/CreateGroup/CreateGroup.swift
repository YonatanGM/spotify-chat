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


        ScrollView {
            VStack {
                HStack {
                    Spacer()
                    Button("Done") {
                        if !name.isEmpty && !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !addedUsers.isEmpty  {
                            DatabaseManager.shared.createGroup(with: addedUsers, name: name) { result in
                                if result == true { // group creation is a success
                                    present = false  // hide the sheet
                                }
                            }
                        }
                    }
                    .buttonStyle(.bordered)
                    .buttonBorderShape(.capsule)
                    .foregroundColor(.white)
                }
                .padding([.top, .trailing], 10)
                
                VStack(alignment: .leading, spacing: 7.5) {
                    Text("Name of group")
                        // .fontWeight(.light)
                        .font(Font.custom("Modulus-Bold", size: 30)) +
                    Text("*").font(.title).fontWeight(.light).baselineOffset(4).foregroundColor(name.isEmpty || name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .white : .clear)
                    TextField("", text: $name) {}
                        .accentColor(.white)
                        .disableAutocorrection(true)
                        .padding(.leading)
                        .frame(height: 40)
                        .background(Color.backdrop)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                }
                .padding([.horizontal], 15)
                
                UserCardViewGroupCreation(addedUsers: $addedUsers)
                Spacer()
            }
            .foregroundColor(.white)
        }
        .background(
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
        )
    }
}

