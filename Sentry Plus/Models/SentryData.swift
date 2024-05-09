//
//  SentryData.swift
//  Sentry Plus
//
//  Created by Onur Altun on 29.04.2024.
//

import Foundation

struct SentryData: Codable, Identifiable, Equatable {
    var id: String = UUID().uuidString
    
    let vin: String
    let state: String
    let createdAt: Date
    let finishedAt: Date?
    
    init(vin: String, state: String, createdAt: Date, finishedAt: Date?) {
        self.id = UUID().uuidString
        self.vin = vin
        self.state = state
        self.createdAt = createdAt
        self.finishedAt = finishedAt
    }

    enum CodingKeys: String, CodingKey {
        case vin
        case state
        case createdAt
        case finishedAt
    }
}
