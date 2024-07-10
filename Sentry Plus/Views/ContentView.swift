//
//  ContentView.swift
//  Sentry Plus
//
//  Created by Onur Altun on 2.04.2024.
//

import SwiftUI
import SwiftData
import UIKit

struct ContentView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    
    let teslaApi: TeslaApi
    
    init(teslaApi: TeslaApi) {
        self.teslaApi = teslaApi
    }
    
    var body: some View {
        if appViewModel.accessToken.isEmpty {
            LoginView(teslaApi: self.teslaApi)
        } else {
            NavigationStack{
                HStack{
                    VStack{
                        VehiclesView(teslaApi: self.teslaApi)
                            .navigationBarItems(leading: (
                                NavigationLink(destination: MenuView()) {
                                    Image(systemName: "line.horizontal.3")
                                        .imageScale(.large)
                                }
                            ), trailing: {
                                if appViewModel.isLoading {
                                    return AnyView(
                                        ProgressView()
                                            .scaledToFit()
                                            .frame(width: 25, height: 25)
                                            .padding(.top))
                                } else {
                                    return AnyView(
                                        Button(action: {
                                            teslaApi.GetVehicles()
                                        }, label: {
                                            Image("pluslogo")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 25, height: 25)
                                        })
                                    )
                                }
                            }())
                            .offset(x: appViewModel.isMenuOpen ? 250 : 0, y: 0)
                            .animation(.default)
                            .navigationBarTitle("Sentry Plus", displayMode: .inline)
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    
    static var previews: some View {
        let appViewModel = AppViewModel()
        let teslaApi = TeslaApi()
        
        ContentView(teslaApi: teslaApi)
            .environmentObject(appViewModel)
    }
}
