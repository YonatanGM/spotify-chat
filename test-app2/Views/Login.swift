//
//  LoginView.swift
//  test-app2
//
//  Created by Yonatan Mamo on 06.05.22.
//

import SwiftUI
import BetterSafariView

struct Login: View {
    
    @EnvironmentObject var model: AppStateModel
    @State var presentLogin = false
    @State var presentLoginFailedAlert = false
    @State var isTapping = false
    let logoHeight = 30.0
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Text("⁢⁢\u{17B5} \u{17B4} \u{115F}")
                    .font(Font.custom("Glyphter", size: UIFont.preferredFont(forTextStyle: .largeTitle).pointSize))
                Spacer()
            }
            Button(action: {
                presentLogin = true
            }) {
                HStack(spacing: 0) {
                    Text("Login with")
                        .font(.title2)
                        .fontWeight(.bold)
                        .minimumScaleFactor(0.9)
                        .lineLimit(1)
                    spotifyWhiteLogo.applying(CGAffineTransform(scaleX: 3.33 * logoHeight, y: logoHeight))
                        .frame(width: 3.33 * logoHeight, height: logoHeight)
                        .padding(.leading, logoHeight / 2)
                }
                .padding(logoHeight / 2)
                .background(Color.backdrop)
                .clipShape(Capsule())
                .scaleEffect(isTapping ? 0.9 : 1)
                .brightness(isTapping ? 0.1 : 0)
                .shadow(radius: 5)
            }
            .webAuthenticationSession(isPresented: $presentLogin) {
                model.signIn() 
            }
            .overlay {
                if model.signInStatus == .signingIn {
                    ProgressView()
                }
            }
//            .sheet(isPresented: $presentLogin,
//                   onDismiss: {
//                // presentLoginFailedAlert = !AuthManager.shared.isSignedIn
//            }) {
//                model.signIn { success in
//                    presentLogin = false
//                    presentLoginFailedAlert = !success
//                }
//
//                .overlay {
//                    if model.signInStatus == .signingIn {
//                        ProgressView()
//
//                    }
//
//                }
//            }
            .alert(isPresented: $presentLoginFailedAlert) {
                Alert(title: Text("Oops"),
                      message: Text("Something went wrong when signing in."),
                      dismissButton: .default(Text("Dismiss")))
            }
            
            Spacer()
        }
        .foregroundColor(.white)
        .background(
            LinearGradient(colors: [
                Color(.sRGB,
                      red: Double(20) / 255,
                      green: Double(20) / 255,
                      blue: Double(20) / 255,
                      opacity: 0.6),
                Color(.sRGB,
                      red: Double(10) / 255,
                      green: Double(10) / 255,
                      blue: Double(10) / 255,
                      opacity: 1)
                
            ], startPoint: .topLeading, endPoint: .center)
            .edgesIgnoringSafeArea(.all)
            
        )
        .navigationBarHidden(true)
    }
}


