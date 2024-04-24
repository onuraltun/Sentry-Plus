//
//  VehicleView.swift
//  Sentry Plus
//
//  Created by Onur Altun on 19.04.2024.
//

import Foundation
import SwiftUI

struct VehicleView: View {
    @State var vehicle: Vehicle
    
    @State var sentryEvents: [SentryEvent] = [
        SentryEvent(eventDate: Date(), state: "off", duration: 10),
        SentryEvent(eventDate: Date().addingTimeInterval(864), state: "online", duration: 20),
        SentryEvent(eventDate: Date().addingTimeInterval(864 * 2), state: "off", duration: 30),
        SentryEvent(eventDate: Date().addingTimeInterval(864 * 3), state: "online", duration: 40),
        SentryEvent(eventDate: Date().addingTimeInterval(864 * 4), state: "Aware", duration: 10),
        SentryEvent(eventDate: Date().addingTimeInterval(864 * 5), state: "online", duration: 60),
        SentryEvent(eventDate: Date().addingTimeInterval(864 * 6), state: "Aware", duration: 2),
        SentryEvent(eventDate: Date().addingTimeInterval(864 * 7), state: "online", duration: 10),
        SentryEvent(eventDate: Date().addingTimeInterval(864 * 8), state: "off", duration: 10),
        SentryEvent(eventDate: Date().addingTimeInterval(864 * 9), state: "online", duration: 10),
    ]
    
    func isPushNotification() -> Binding<Bool> {
        return Binding<Bool>(
            get: {
                return vehicle.sendPushNotification ?? false
            },
            set: { newValue in
                vehicle.sendPushNotification = newValue
            }
        )
    }
    
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
                .padding()
                
                Toggle("Send a push notification on Sentry Mode activated", isOn: isPushNotification())
                    .padding()
                
                Text("Last Sentry Events")
                    .font(.largeTitle)
                    .padding(.horizontal)
                
                List(sentryEvents) { event in
                    Text("(\(event.eventDate, format: .dateTime)) \(event.state) for \(event.duration) min")
                        .foregroundStyle(event.state == "Aware" ? .red : .primary)
                }
            })
        })
    }
}

struct VehicleView_Previews: PreviewProvider {
    static var previews: some View {
        let vehicle = Vehicle(id: 1, vin: "5YJ3E1EA8JF006588", displayName: "Model 3", state: "online", isConfigured: false, sendPushNotification: false, hornOnState: false)
        
        VehicleView(vehicle: vehicle)
    }
}

