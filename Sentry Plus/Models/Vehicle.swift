//
//  Vehicle.swift
//  Sentry Plus
//
//  Created by Onur Altun on 17.04.2024.
//

import Foundation

struct Vehicle: Codable, Identifiable {
    let id: Int64
    let vehicleId: Int64
    let vin: String
    let color: String?
    let accessType: String
    let displayName: String
    let granularAccess: GranularAccess
    let tokens: [String]?
    let state: String
    let inService: Bool
    let idS: String?
    let calendarEnabled: Bool
    let apiVersion: Int
    let backseatToken: String?
    let backseatTokenUpdatedAt: String?
    
    init(id: Int64, vin: String, displayName: String, state: String) {
        self.id = id
        self.vehicleId = 0
        self.vin = vin
        self.color = ""
        self.accessType = ""
        self.displayName = displayName
        self.granularAccess = GranularAccess()
        self.tokens = []
        self.state = state
        self.inService = false
        self.idS = ""
        self.calendarEnabled = false
        self.apiVersion = 1
        self.backseatToken = ""
        self.backseatTokenUpdatedAt = ""
    }

    enum CodingKeys: String, CodingKey {
        case id
        case vehicleId = "vehicle_Id"
        case vin
        case color
        case accessType = "access_Type"
        case displayName = "display_Name"
        case granularAccess = "granular_Access"
        case tokens
        case state
        case inService = "in_Service"
        case idS = "id_S"
        case calendarEnabled = "calendar_Enabled"
        case apiVersion = "api_Version"
        case backseatToken = "backseat_Token"
        case backseatTokenUpdatedAt = "backseat_Token_Updated_At"
    }
}

struct GranularAccess: Codable {
    let hidePrivate: Bool
    
    init() {
        self.hidePrivate = false
    }
    
    enum CodingKeys: String, CodingKey {
        case hidePrivate = "hide_Private"
    }
}
