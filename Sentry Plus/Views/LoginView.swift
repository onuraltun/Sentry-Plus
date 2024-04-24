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
                        
                        self.teslaApi!.GetVehicles()
                    }
                }
                authSession?.prefersEphemeralWebBrowserSession = true
                authSession?.presentationContextProvider = authManager
                authSession?.start()
            }
        }) {
            Text("Login Via Tesla")
                .padding()
                .background(Color.blue)
                .foregroundColor(Color.white)
                .cornerRadius(10)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
