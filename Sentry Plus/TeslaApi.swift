//
//  TeslaApi.swift
//  Sentry Plus
//
//  Created by Onur Altun on 17.04.2024.
//

import Foundation
import UIKit

struct TeslaApi{
    
    private let appViewModel: AppViewModel
    
    init(appViewModel: AppViewModel) {
        self.appViewModel = appViewModel
    }
    
    func GetVehicles() {
        DispatchQueue.main.async {
            self.appViewModel.isLoading = true
        }
        
        let accessToken = UserDefaults.standard.string(forKey: "accessToken")
        
        if accessToken == nil {
            print("Access token is nil")
            self.appViewModel.vehicles = []
            return
        }
        
        let vehiclesURL = URL(string: "https://sentry-plus.com/api/vehicles")!
        var request = URLRequest(url: vehiclesURL)
        request.addValue("Bearer " + accessToken!, forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.appViewModel.isLoading = false
            }
            
            if let error = error {
                print(error.localizedDescription)
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Couldn't get response")
                return
            }
            
            switch httpResponse.statusCode {
            case 200..<300:
                if let data = data {
                    let jsonString = String(data: data, encoding: .utf8)!
                    
                    guard let jsonData = jsonString.data(using: .utf8) else {
                        fatalError("Couldn't convert data to JSON")
                    }
                    
                    do {
                        let decodedVehicles = try JSONDecoder().decode([Vehicle].self, from: jsonData)
                        DispatchQueue.main.async {
                            self.appViewModel.vehicles = decodedVehicles
                            UserDefaults.standard.set(jsonString, forKey: "vehicles")
                        }
                    } catch {
                        print("Error decoding JSON: \(error)")
                    }
                }
            case 401:
                print("Unauthorized. Refreshing token...")
                self.RefreshToken()
            default:
                print("Unexpected error. Code: \(httpResponse.statusCode)")
            }
        }
        
        task.resume()
    }
    
    func RefreshToken() {
        let refreshToken = UserDefaults.standard.string(forKey: "refreshToken")
        
        if refreshToken == nil {
            print("Refresh token is nil")
            return
        }
        
        let refreshTokenURL = URL(string: "https://sentry-plus.com/api/refreshToken")!
        
        var request = URLRequest(url: refreshTokenURL)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(refreshToken!, forHTTPHeaderField: "refreshToken")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print(error.localizedDescription)
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Couldn't get response")
                return
            }
            
            switch httpResponse.statusCode {
            case 200..<300:
                if let data = data {
                    let jsonString = String(data: data, encoding: .utf8)!
                    
                    guard let jsonData = jsonString.data(using: .utf8) else {
                        fatalError("Couldn't convert data to JSON")
                    }
                    
                    do {
                        let decodedToken = try JSONDecoder().decode(TeslaToken.self, from: jsonData)
                        UserDefaults.standard.set(decodedToken.accessToken, forKey: "accessToken")
                        UserDefaults.standard.set(decodedToken.refreshToken, forKey: "refreshToken")
                    } catch {
                        print("Error decoding JSON: \(error)")
                    }
                }
            default:
                print("Unexpected error. Code: \(httpResponse.statusCode)")
            }
        }
        
        task.resume()
        
    }
}
