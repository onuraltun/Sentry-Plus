//
//  AppViewModel.swift
//  Sentry Plus
//
//  Created by Onur Altun on 17.04.2024.
//

import Foundation
import Combine

class AppViewModel: ObservableObject {
    static let shared = AppViewModel()
    
    @Published var accessToken: String = ""
    @Published var refreshToken: String = ""
    @Published var vehicles: [Vehicle] = []
    @Published var isMenuOpen = false
    @Published var isLoading = false
    @Published var sentryData = [String: [SentryData]]()
    @Published var vehicleConfigs = [String: VehicleConfig]()
    
    init() {
        if let accessToken = UserDefaults.standard.string(forKey: "accessToken") {
            self.accessToken = accessToken
        }
        
        if let refreshToken = UserDefaults.standard.string(forKey: "refreshToken") {
            self.refreshToken = refreshToken
        }

        if let vehicles = UserDefaults.standard.string(forKey: "vehicles") {
            let jsonData = vehicles.data(using: .utf8)!
            do {
                let decodedVehicles = try JSONDecoder().decode([Vehicle].self, from: jsonData)
                self.vehicles = decodedVehicles
            } catch {
                print("Couldn't decode vehicles")
            }
        }
    }
    
    init(accessToken: String, refreshToken: String) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
    }
}
