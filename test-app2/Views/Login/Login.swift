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
        ZStack {
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
            
            if model.signInStatus == .signedOut {
                 UserWebAnimationLoginView()
            }

            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Text("⁢⁢\u{17B5} \u{17B4} \u{115F}")
                        .font(Font.custom("Modulus-Bold", size: 40))
                    Spacer()
                }
                if model.signInStatus == .signedOut {
                    Button(action: {
                        presentLogin = true
                    }) {
                        HStack(spacing: 0) {
                            Text("Login with")
                                .font(.title2)
                                .fontWeight(.semibold)
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
                        model.signIn { success in
                            if !success {
                                
                                presentLoginFailedAlert = true
                            }
                        }
                    }
                }
                
                if model.signInStatus == .signingIn || model.finishedLoadingOfSuggestedUsers == false {
                    ProgressView()
                        .onChange(of: model.signInStatus){ _ in
                            print(model.signInStatus)
                        }
                }
                Spacer()
                if model.signInStatus == .signedOut {
                    PrivacyAndTerms()
                }
            }
            .alert(isPresented: $presentLoginFailedAlert) {
                Alert(title: Text("Error"),
                      message: Text("Something went wrong when signing you in."),
                      dismissButton: .default(Text("Dismiss")))
            }
        }
        .foregroundColor(.white)
        .navigationBarHidden(true)
    }
}


