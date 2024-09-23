//
//  VehicleConfig.swift
//  Sentry Plus
//
//  Created by Onur Altun on 6.05.2024.
//

import Foundation

struct VehicleConfig: Codable {
    let vin: String
    var sendPushNotification: Bool
    var honkHorn: Bool
    var flashLights: Bool
    var configured: Bool
    var configurationError: String?

    init(
        vin: String, sendPushNotification: Bool, honkHorn: Bool,
        flashLights: Bool, configured: Bool = false,
        configurationError: String? = nil
    ) {
        self.vin = vin
        self.sendPushNotification = sendPushNotification
        self.honkHorn = honkHorn
        self.flashLights = flashLights
        self.configured = configured
        self.configurationError = configurationError
    }

    enum CodingKeys: String, CodingKey {
        case vin
        case sendPushNotification
        case honkHorn
        case flashLights
        case configured
        case configurationError
    }
}
