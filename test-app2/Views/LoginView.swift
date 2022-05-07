//
//  LoginView.swift
//  test-app2
//
//  Created by Yonatan Mamo on 06.05.22.
//

import SwiftUI

struct LoginView: View {

    @Binding var isLoggedIn: Bool
    @State var presentLogin = false
    @State var presentLoginFailedAlert = false
    
    init(_ isLoggedIn: Binding<Bool>) {
        self._isLoggedIn = isLoggedIn
    }
    
    var body: some View {
    
        if !isLoggedIn {
            Button(action: {
                presentLogin = true
            }) {
                Text("Sign in")
            }
            .sheet(isPresented: $presentLogin,
                   onDismiss: {
                // presentLoginFailedAlert = !AuthManager.shared.isSignedIn
            }) {
                if let url = AuthManager.shared.signInUrl  {
                    WebView(url: url) { success in
                        presentLogin = false
                        presentLoginFailedAlert = !success
                        isLoggedIn = success
                        
                    }
                    .padding(.top)
                }
            }
            .alert(isPresented: $presentLoginFailedAlert) {
                Alert(title: Text("Oops"),
                      message: Text("Something went wrong when signing in."),
                      dismissButton: .default(Text("Dismiss")))
            }
        }
    }
}


struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(.constant(false))
    }
}
