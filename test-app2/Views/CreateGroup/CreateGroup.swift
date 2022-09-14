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
    var body: some View {
        ZStack(alignment: .top) {
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
                            present = false

                        }
                        
                    }
                   
                    
                }
                .padding(10)

                
                VStack (spacing: 2) {
              
         
                         HStack {
                             TextField("Name of group", text: $name) {

                             }
                    
                             .accentColor(.black)
                             .keyboardType(.webSearch)
                             .disableAutocorrection(true)
                             .textFieldStyle(.roundedBorder)
   
                         }
                       
                         .foregroundColor(.black)
                         .padding(13)
     
                     
                    
                    
                    
                }
                .padding()
                VStack(spacing: 2) {
                    Text("From suggested users")
                        .font(.largeTitle)
                    UserCardViewGroupCreation()
                    
                }
                
                VStack(spacing: 2) {
                    Text("Find")
                        .font(.largeTitle)
                    SearchBar(searchText: $name)
                    
                }
                
              
                Spacer()
                    
            }
            .foregroundColor(.white)
            
        }
    }
}

/*

struct CreateGroup_Previews: PreviewProvider {
    static var previews: some View {
        CreateGroup()
    }
}
*/
