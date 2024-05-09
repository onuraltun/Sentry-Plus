//
//  MenuView.swift
//  Sentry Plus
//
//  Created by Onur Altun on 19.04.2024.
//

import Foundation
import SwiftUI
import MessageUI
import UIKit

struct MenuView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @State private var teslaApi = TeslaApi(appViewModel: AppViewModel())
    
    var body: some View {
        HStack (alignment: .top, content: {
            VStack(alignment: .center, content: {
                Image("pluslogo")
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .padding()
                
                Text("Sentry Plus")
                    .font(.largeTitle)
                
                Text("Version \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "")")
                    .font(.caption)
                
                List{
                    Button(action: {
                        MailComposeViewController.shared.sendEmail()
                    }) {
                        HStack {
                            Image(systemName: "envelope.fill")
                                .foregroundColor(.secondary)
                            VStack(alignment: .leading, content: {
                                Text("Contact Us")
                                    .font(.title2)
                                    .padding()
                                Text("Send us an email for feedback or support")
                                    .font(.caption)
                            })
                        }
                    }
                    
                    Button(action: {
                        rateApp()
                    }) {
                        HStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, content: {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                            VStack(alignment: .leading, content: {
                                Text("Rate App")
                                    .font(.title2)
                                    .padding()
                                Text("Rate the app on the App Store. It helps us a lot!")
                                    .font(.caption)
                            })
                        })
                    }
                    
                    Button(action: {
                        let accessToken = UserDefaults.standard.string(forKey: "accessToken")
                        teslaApi.logout(accessToken: accessToken ?? "")
                        
                        self.appViewModel.vehicles.removeAll()
                        self.appViewModel.sentryData.removeAll()
                        
                        UserDefaults.standard.removeObject(forKey: "accessToken")
                        UserDefaults.standard.removeObject(forKey: "refreshToken")
                        
                        self.appViewModel.accessToken = ""
                        self.appViewModel.refreshToken = ""
                    }) {
                        HStack {
                            Image(systemName: "lock.fill")
                                .foregroundColor(.red)
                            VStack(alignment: .leading, content: {
                                Text("Logout")
                                    .font(.title2)
                                    .padding()
                                Text("Logout your Tesla account from the app")
                                    .font(.caption)
                            })
                        }
                    }
                }
            })
        })
    }
    
    func rateApp() {
        guard let writeReviewURL = URL(string: "https://apps.apple.com/app/6483864350?action=write-review") else {
            return
        }
        UIApplication.shared.open(writeReviewURL, options: [:], completionHandler: nil)
    }
}

struct MenuView_Previews: PreviewProvider {
    static var previews: some View {
        MenuView()
    }
}
