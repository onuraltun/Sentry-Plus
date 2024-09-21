//
//  ConfigureVehicle.swift
//  Sentry Plus
//
//  Created by Onur Altun on 21.09.2024.
//

import Foundation
import SwiftUI

struct ConfigureVehicleView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @State var vehicle: Vehicle
    @State var teslaApi = TeslaApi()
    @State var configuring = false

    var body: some View {

        let vehicleConfig =
            appViewModel.vehicleConfigs[
                vehicle.vin]
            ?? VehicleConfig(
                vin: vehicle.vin,
                sendPushNotification: false,
                honkHorn: false,
                flashLights: false)

        if !vehicleConfig.configured {
            if vehicleConfig.configurationError?.contains(
                "missing_key")
                == true
            {
                Text("The vehicle configuration is not yet complete.")
                    .font(.headline)

                Text(
                    "In order to connect your vehicle, you must first add the Sentry Plus Key to your Tesla. After adding the key, you should see a success message similar to the one below."
                )

                Image("ConfigSuccess")
                    .resizable()
                    .scaledToFit()

                Button(action: {
                    if let url = URL(
                        string:
                            "https://tesla.com/_ak/sentry-plus.com")
                    {
                        UIApplication.shared.open(url)
                    }
                }) {
                    Text("Add Virtual Key")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(
                    EdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0))

                Text(
                    "If you have already added the key, please try configuring it again using the button below."
                )

                Button(action: {
                    teslaApi.ConfigureFleet()
                    configuring = true

                    DispatchQueue.main.asyncAfter(deadline: .now() + 40) {
                        configuring = false
                    }
                }) {
                    Text(configuring ? "Configuring..." : "Configure")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }.disabled(configuring)
            } else {
                if vehicleConfig.configurationError == ""
                    || vehicleConfig.configurationError == nil
                {
                    AnyView(
                        ProgressView()
                            .scaledToFit()
                            .frame(width: 25, height: 25)
                            .padding(.top))
                } else {
                    Text(
                        "There is an error connecting your vehicle. Please contact support. Error: \(vehicleConfig.configurationError ?? "")"
                    )
                }
            }
        }
    }
}
