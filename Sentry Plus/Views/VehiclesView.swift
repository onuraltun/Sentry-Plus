//
//  VehiclesView.swift
//  Sentry Plus
//
//  Created by Onur Altun on 19.04.2024.
//

import Foundation
import SwiftUI
import WebKit
import SwiftData
import UIKit

struct VehiclesView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @State var selectedIndex: Int?
    var teslaApi: TeslaApi
    
    init(teslaApi: TeslaApi) {
        self.teslaApi = teslaApi
    }
    
    let timer = Timer.publish(every: 30, on: .main, in: .common).autoconnect()
    
    var body: some View {
        if(self.appViewModel.vehicles.isEmpty)
        {
            AnyView(Text("No vehicles found."))
                .refreshable() {
                    self.teslaApi.GetVehicles()
                }
                .onAppear(){
                    UITableView.appearance().allowsMultipleSelection = false
                    self.teslaApi.GetVehicles()
                }
        }else{
            VStack{
                List(self.appViewModel.vehicles, id: \.vin, selection: $selectedIndex)
                { vehicle in
                    NavigationLink(destination: VehicleView(vehicle: vehicle,
                        teslaApi: self.teslaApi,
                            vehicleConfig: Binding<VehicleConfig>(
                                get: {self.appViewModel.vehicleConfigs[vehicle.vin] ?? VehicleConfig(vin: vehicle.vin, sendPushNotification: false, honkHorn: false, flashLights: false)},
                                set: {
                                    self.appViewModel.vehicleConfigs[vehicle.vin] = $0
                                    teslaApi.SetConfig(vin: vehicle.vin, pushNotifications: $0.sendPushNotification, honkHorn: $0.honkHorn, flashLights: $0.flashLights)
                                }
                               )
                               ), label: {
                        VehicleRow(vehicle: vehicle)
                    })
               }
                .refreshable {
                    self.teslaApi.GetVehicles()
                }
                .onAppear(){
                    UITableView.appearance().allowsMultipleSelection = false
                    self.teslaApi.GetVehicles()
                }
            }
        }
    }
}
