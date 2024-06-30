//
//  VehicleView.swift
//  Sentry Plus
//
//  Created by Onur Altun on 19.04.2024.
//

import Foundation
import SwiftUI

struct VehicleView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @State var vehicle: Vehicle
    @State var teslaApi = TeslaApi(appViewModel: AppViewModel())
    
    @Binding var vehicleConfig: VehicleConfig
    
    var body: some View {
        HStack(alignment: .top, content: {
            VStack(alignment: .leading, content: {
                HStack{
                    if vehicle.state == "asleep" {
                        Image(systemName: "powersleep")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.red)
                            .padding()
                    } else {
                        Image(systemName: "car.front.waves.up")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.green)
                            .padding()
                    }
                    VStack(alignment: .leading, content: {
                        Text(vehicle.displayName)
                            .font(.title)
                        Text(vehicle.vin)
                            .font(.subheadline)
                    })
                }
                
                Text("Sentry Event Actions")
                    .font(.largeTitle)
                    .padding(.horizontal)
                
                Toggle("Send a push notification",
                       isOn: $vehicleConfig.sendPushNotification).padding()
                
                Toggle("Honk horn",
                       isOn: $vehicleConfig.honkHorn).padding()
                       
                Toggle("Flash lights",
                       isOn:$vehicleConfig.flashLights).padding()
                
                Text("Last Sentry Events")
                    .font(.largeTitle)
                    .padding(.horizontal)
                
                List(self.appViewModel.sentryData[vehicle.vin]?
                    .sorted(by: { $0.createdAt > $1.createdAt}) ?? []){ event in
                    HStack{
                        Text(event.state)
                            .font(.title3)
                        
                        Spacer()
                        
                        VStack(alignment: .leading, content: {
                            Text("Started at \(event.createdAt.formatted(date: Date.FormatStyle.DateStyle.abbreviated, time: Date.FormatStyle.TimeStyle.shortened))")
                                .font(.callout)
                            Text("Finished at \((event.finishedAt ?? Date()).formatted(date: Date.FormatStyle.DateStyle.abbreviated, time: Date.FormatStyle.TimeStyle.shortened))")
                                .font(.callout)
                        })
                    }
                    .foregroundStyle(event.state == "Aware" ? .red : .primary)
                }
            })
        }).onAppear(){
            teslaApi.getConfig(vin: vehicle.vin)
        }
    }
}

struct VehicleView_Previews: PreviewProvider {
    static var previews: some View {
        let vehicle = Vehicle(id: 1, vin: "5YJ3E1EA8JF006588", displayName: "Model 3", state: "online")
        
        VehicleView(vehicle: vehicle, vehicleConfig: .constant(VehicleConfig(vin: "5YJ3E1EA8JF006588", sendPushNotification: false, honkHorn: false, flashLights: false)))
            .environmentObject(AppViewModel())
    }
}

