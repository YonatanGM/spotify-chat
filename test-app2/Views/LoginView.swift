//
//  LoginView.swift
//  test-app2
//
//  Created by Yonatan Mamo on 06.05.22.
//

import SwiftUI

struct LoginView: View {

    @EnvironmentObject var model: AppStateModel
    @State var presentLogin = false
    @State var presentLoginFailedAlert = false

    var body: some View {

        
        Button(action: {
            presentLogin = true
        }) {
            Text("Sign in")
        }
        .sheet(isPresented: $presentLogin,
               onDismiss: {
            // presentLoginFailedAlert = !AuthManager.shared.isSignedIn
        }) {
            model.signIn { success in
                presentLogin = false
                presentLoginFailedAlert = !success
            }
            // ios 15+
//            .overlay {
//                if model.signInStatus == .signingIn {
//                    ProgressView()
//
//                }
//
//            }
        }
        .alert(isPresented: $presentLoginFailedAlert) {
            Alert(title: Text("Oops"),
                  message: Text("Something went wrong when signing in."),
                  dismissButton: .default(Text("Dismiss")))
        }

    }
}



/*
 
 struct LoginView_Previews: PreviewProvider {
     static var previews: some View {
         LoginView(model: .constant(false))
     }
 }

 */
