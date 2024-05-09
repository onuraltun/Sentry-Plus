//
//  VehicleConfig.swift
//  Sentry Plus
//
//  Created by Onur Altun on 6.05.2024.
//

import Foundation

struct VehicleConfig: Codable{
    let vin: String
    let sendPushNotification: Bool
    
    init(vin: String, sendPushNotification: Bool){
        self.vin = vin
        self.sendPushNotification = sendPushNotification
    }
    
    enum CodingKeys: String, CodingKey {
        case vin
        case sendPushNotification
    }
}
