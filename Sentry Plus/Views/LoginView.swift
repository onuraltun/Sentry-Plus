//
//  LoginView.swift
//  Sentry Plus
//
//  Created by Onur Altun on 19.04.2024.
//

import Foundation
import SwiftUI
import AuthenticationServices

let AUTH_URL = "https://sentry-plus.com/authViaTesla"
let REDIRECT_URI = "sentry-plus"

class AuthenticationSessionManager: NSObject, ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return ASPresentationAnchor()
    }
}

struct LoginView:View {
    @EnvironmentObject var appViewModel: AppViewModel
    @State var authSession: ASWebAuthenticationSession?
    var teslaApi: TeslaApi?
    
    init(teslaApi: TeslaApi) {
        self.teslaApi = teslaApi
    }
    
    let authManager = AuthenticationSessionManager()
    
    var body: some View {
        VStack{
            Spacer()
            
            Image("pluslogo")
                .resizable()
                .frame(width: 200)
                .aspectRatio(1.5, contentMode: .fit)
                .padding()
            
            Text("Sentry Plus")
                .font(.largeTitle)
            
            Text("Enhance your Tesla's security")
                .font(.title2)
                .padding()
            
            Text("Sentry Plus is a third-party app that allows you to see security events on your phone. For it to do this, you just need to sign in with your Tesla account. This will give your Tesla the necessary permissions to send the data to it.")
                .font(.title3)
                .multilineTextAlignment(.center)
                .padding()
            
            Spacer()
            
            Button(action: {
                if let url = URL(string: AUTH_URL) {
                    authSession = ASWebAuthenticationSession(url: url, callbackURLScheme: REDIRECT_URI) { callbackURL, error in
                        if let error = error {
                            print(error.localizedDescription)
                        } else {
                            let queryItems = URLComponents(string: callbackURL!.absoluteString)?.queryItems
                            appViewModel.accessToken = queryItems?.first(where: { $0.name == "access_token" })?.value ?? ""
                            appViewModel.refreshToken = queryItems?.first(where: { $0.name == "refresh_token" })?.value ?? ""
                            
                            UserDefaults.standard.set(appViewModel.accessToken, forKey : "accessToken")
                            UserDefaults.standard.set(appViewModel.refreshToken, forKey : "refreshToken")
                            
                            self.teslaApi!.GetVehicles(saveApnc: true)
                        }
                    }
                    authSession?.prefersEphemeralWebBrowserSession = true
                    authSession?.presentationContextProvider = authManager
                    authSession?.start()
                }
            }) {
                Text("Sign in with Tesla")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(Color.white)
                    .cornerRadius(10)
            }
            .buttonStyle(PlainButtonStyle())
            .padding()
            
            Button(action: {
                appViewModel.accessToken = "demo"
                UserDefaults.standard.set(appViewModel.accessToken, forKey : "accessToken")
            }) {
                Text("Demo Mode")
                    .padding()
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(teslaApi: TeslaApi(appViewModel: AppViewModel()))
    }
}
