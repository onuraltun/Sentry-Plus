//
//  TeslaToken.swift
//  Sentry Plus
//
//  Created by Onur Altun on 17.04.2024.
//

import Foundation

struct TeslaToken: Codable {
    let accessToken: String
    let refreshToken: String
    let expiresIn: Int
    let state: String?
    let tokenType: String?
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case expiresIn = "expires_in"
        case state = "state"
        case tokenType = "token_type"
    }
}
