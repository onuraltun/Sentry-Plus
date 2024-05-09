//
//  VehicleRow.swift
//  Sentry Plus
//
//  Created by Onur Altun on 19.04.2024.
//

import Foundation
import SwiftUI

struct VehicleRow: View {
    var vehicle: Vehicle
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(vehicle.displayName)
                    .font(.title)
                
                Spacer()
                
                HStack(alignment: .center) {
                    if vehicle.state == "asleep" {
                        Image(systemName: "powersleep")
                            .foregroundColor(.red)
                    } else {
                        Image(systemName: "car.front.waves.up")
                            .foregroundColor(.green)
                    }
                    Text(vehicle.state)
                        .font(.subheadline)
                }
            }
            .padding(.bottom)
            .padding(.top)
            
            EventsChartView(vin: vehicle.vin)
                .padding(.bottom)
        }
    }
}
