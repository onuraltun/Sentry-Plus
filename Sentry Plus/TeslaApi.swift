//
//  TeslaApi.swift
//  Sentry Plus
//
//  Created by Onur Altun on 17.04.2024.
//

import Foundation
import UIKit

struct TeslaApi {

    func GetVehicles(saveApnc: Bool = false) {
        DispatchQueue.main.async {
            AppViewModel.shared.isLoading = true
        }

        let accessToken = UserDefaults.standard.string(forKey: "accessToken")

        if accessToken == "demo" {
            let vehicles = [
                Vehicle(
                    id: 1, vin: "demo", displayName: "Demo", state: "asleep")
            ]
            let sentryData = [
                SentryData(
                    vin: "demo", state: "Off",
                    createdAt: Date().addingTimeInterval(-6600),
                    finishedAt: Date().addingTimeInterval(-3600)),
                SentryData(
                    vin: "demo", state: "Armed",
                    createdAt: Date().addingTimeInterval(-3600),
                    finishedAt: Date().addingTimeInterval(-1800)),
                SentryData(
                    vin: "demo", state: "Aware",
                    createdAt: Date().addingTimeInterval(-1800),
                    finishedAt: Date().addingTimeInterval(-200)),
                SentryData(
                    vin: "demo", state: "Idle",
                    createdAt: Date().addingTimeInterval(-200),
                    finishedAt: Date().addingTimeInterval(0)),
            ]

            DispatchQueue.main.async {
                AppViewModel.shared.vehicles = vehicles
                let jsonEncoder = JSONEncoder()
                if let jsonData = try? jsonEncoder.encode(vehicles) {
                    UserDefaults.standard.set(jsonData, forKey: "vehicles")
                }
                AppViewModel.shared.sentryData["demo"] = sentryData
                AppViewModel.shared.isLoading = false
            }

            let demoVehicleConfig = VehicleConfig(
                vin: "demo", sendPushNotification: false,
                honkHorn: false, flashLights: false, configured: true,
                configurationError: "")

            DispatchQueue.main.async {
                if let index = AppViewModel.shared.vehicleConfigs
                    .firstIndex(where: { $0.0 == "demo" })
                {
                    AppViewModel.shared.vehicleConfigs.values[
                        index] = demoVehicleConfig
                } else {
                    AppViewModel.shared.vehicleConfigs["demo"] =
                        demoVehicleConfig
                }
            }

            return
        }

        if accessToken == nil {
            print("Access token is nil")
            AppViewModel.shared.vehicles = []
            return
        }

        let vehiclesURL = URL(string: "https://sentry-plus.com/api/vehicles")!
        var request = URLRequest(url: vehiclesURL)
        request.addValue(
            "Bearer " + accessToken!, forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.dataTask(with: request) {
            data, response, error in
            DispatchQueue.main.async {
                AppViewModel.shared.isLoading = false
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
                        let decodedVehicles = try JSONDecoder().decode(
                            [Vehicle].self, from: jsonData)
                        DispatchQueue.main.async {
                            AppViewModel.shared.vehicles = decodedVehicles
                            UserDefaults.standard.set(
                                jsonString, forKey: "vehicles")
                        }

                        for vehicle in decodedVehicles {
                            if saveApnc {
                                self.saveApns(vin: vehicle.vin)
                            }

                            self.getConfig(vin: vehicle.vin)

                            self.getSentryData(vin: vehicle.vin)
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

        let refreshTokenURL = URL(
            string: "https://sentry-plus.com/api/refreshToken")!

        var request = URLRequest(url: refreshTokenURL)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(refreshToken!, forHTTPHeaderField: "refreshToken")

        let task = URLSession.shared.dataTask(with: request) {
            data, response, error in
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
                        let decodedToken = try JSONDecoder().decode(
                            TeslaToken.self, from: jsonData)
                        UserDefaults.standard.set(
                            decodedToken.accessToken, forKey: "accessToken")
                        UserDefaults.standard.set(
                            decodedToken.refreshToken, forKey: "refreshToken")
                    } catch {
                        print("Error decoding JSON: \(error)")
                    }
                }
            case 401:
                print("Refresh token expired. Logging out...")
                DispatchQueue.main.async {
                    self.logout()
                    let alert = UIAlertController(
                        title: "Error",
                        message:
                            "Your session has expired. Please login again.",
                        preferredStyle: .alert)
                    alert.addAction(
                        UIAlertAction(
                            title: "OK", style: .default, handler: nil))

                    if let windowScene = UIApplication.shared.connectedScenes
                        .first as? UIWindowScene,
                        let window = windowScene.windows.first
                    {
                        window.rootViewController?.present(
                            alert, animated: true, completion: nil)
                    }
                }
            default:
                print("Unexpected error. Code: \(httpResponse.statusCode)")
            }
        }

        task.resume()
    }

    func getSentryData(vin: String) {
        let accessToken = UserDefaults.standard.string(forKey: "accessToken")

        if accessToken == nil {
            print("Access token is nil")
            return
        }

        let sentryDataURL = URL(
            string: "https://sentry-plus.com/api/sentryData/\(vin)")!
        var request = URLRequest(url: sentryDataURL)
        request.addValue(
            "Bearer " + accessToken!, forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.dataTask(with: request) {
            data, response, error in
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

                    let dateFormatter = DateFormatter()
                    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"

                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .formatted(dateFormatter)

                    do {
                        let decodedSentryData = try decoder.decode(
                            [SentryData].self, from: jsonData)
                        DispatchQueue.main.async {
                            if let index = AppViewModel.shared.sentryData
                                .firstIndex(where: { $0.0 == vin })
                            {
                                AppViewModel.shared.sentryData.values[index] =
                                    decodedSentryData
                            } else {
                                AppViewModel.shared.sentryData[vin] =
                                    decodedSentryData
                            }
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

    func saveApns(vin: String) {
        let token = UserDefaults.standard.string(forKey: "deviceToken")

        if token == nil {
            print("APNS token is nil")
            return
        }

        let apnsTokenURL = URL(
            string: "https://sentry-plus.com/api/saveApns/\(vin)")!

        var request = URLRequest(url: apnsTokenURL)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(token!, forHTTPHeaderField: "deviceToken")

        let task = URLSession.shared.dataTask(with: request) {
            data, response, error in
            if let error = error {
                print(error.localizedDescription)
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                print("Couldn't get response")
                return
            }

            switch httpResponse.statusCode {
            case 200..<300:
                print("APNS token saved")
            default:
                print("Unexpected error. Code: \(httpResponse.statusCode)")
            }
        }

        task.resume()
    }

    func logout() {
        let accessToken = UserDefaults.standard.string(forKey: "accessToken")

        if accessToken == nil || accessToken!.isEmpty {
            print("Access token is nil or empty")
            return
        }

        UserDefaults.standard.removeObject(forKey: "accessToken")
        UserDefaults.standard.removeObject(forKey: "refreshToken")

        AppViewModel.shared.accessToken = ""
        AppViewModel.shared.refreshToken = ""
        AppViewModel.shared.vehicles.removeAll()
        AppViewModel.shared.sentryData.removeAll()

        for vehicle in AppViewModel.shared.vehicles {
            let vin = vehicle.vin
            let logoutUrl = URL(
                string: "https://sentry-plus.com/api/logout/\(vin)")!

            var request = URLRequest(url: logoutUrl)
            request.httpMethod = "POST"
            request.addValue(
                "application/json", forHTTPHeaderField: "Content-Type")
            request.addValue(
                "Bearer " + accessToken!, forHTTPHeaderField: "Authorization")

            let task = URLSession.shared.dataTask(with: request) {
                data, response, error in
                if let error = error {
                    print(error.localizedDescription)
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    print("Couldn't get response")
                    return
                }

                switch httpResponse.statusCode {
                case 200..<300:
                    print("Logged out")
                default:
                    print("Unexpected error. Code: \(httpResponse.statusCode)")
                }
            }

            task.resume()
        }
    }

    func SetConfig(
        vin: String, pushNotifications: Bool, honkHorn: Bool, flashLights: Bool
    ) {
        let accessToken = UserDefaults.standard
            .string(forKey: "accessToken")

        if accessToken == nil {
            print("Access token is nil")
            return
        }

        let newVehicleConfig = VehicleConfig(
            vin: vin, sendPushNotification: pushNotifications,
            honkHorn: honkHorn, flashLights: flashLights)
        let newVehicleConfigJson =
            try! JSONSerialization.jsonObject(
                with: try! JSONEncoder().encode(newVehicleConfig))
            as! [String: Any]
        let sentryDataURL = URL(
            string: "https://sentry-plus.com/api/setConfig/\(vin)")!
        var request = URLRequest(url: sentryDataURL)
        request.httpMethod = "POST"
        request.addValue(
            "Bearer " + accessToken!, forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try! JSONSerialization.data(
            withJSONObject: newVehicleConfigJson)
        let task = URLSession.shared.dataTask(with: request) {
            data, response, error in
            if let error = error {
                print(error.localizedDescription)
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                print("Couldn't get response")
                return
            }

            switch httpResponse.statusCode {
            case 200..<300:
                print("SetPushNotification successful")
            case 401:
                print("Unauthorized. Refreshing token...")
                self.RefreshToken()
            default:
                print("Unexpected error. Code: \(httpResponse.statusCode)")
            }
        }

        task.resume()
    }

    func getConfig(vin: String) {
        let accessToken = UserDefaults.standard.string(forKey: "accessToken")

        if accessToken == nil {
            print("Access token is nil")
            return
        }

        let sentryDataURL = URL(
            string: "https://sentry-plus.com/api/getConfig/\(vin)")!
        var request = URLRequest(url: sentryDataURL)
        request.httpMethod = "GET"
        request.addValue(
            "Bearer " + accessToken!, forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let task = URLSession.shared.dataTask(with: request) {
            data, response, error in
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

                    let decoder = JSONDecoder()

                    do {
                        let decodedConfig = try decoder.decode(
                            VehicleConfig.self, from: jsonData)
                        DispatchQueue.main.async {
                            if let index = AppViewModel.shared.vehicleConfigs
                                .firstIndex(where: { $0.0 == vin })
                            {
                                AppViewModel.shared.vehicleConfigs.values[
                                    index] = decodedConfig
                            } else {
                                AppViewModel.shared.vehicleConfigs[vin] =
                                    decodedConfig
                            }
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

    func HonkHorn(vin: String, retry: Bool = false) {
        let accessToken = UserDefaults.standard.string(forKey: "accessToken")

        if accessToken == nil {
            print("Access token is nil")
            return
        }

        let sentryDataURL = URL(
            string: "https://sentry-plus.com/api/honkHorn/\(vin)")!
        var request = URLRequest(url: sentryDataURL)
        request.httpMethod = "POST"
        request.addValue(
            "Bearer " + accessToken!, forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let task = URLSession.shared.dataTask(with: request) {
            data, response, error in
            if let error = error {
                print(error.localizedDescription)
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                print("Couldn't get response")
                return
            }

            switch httpResponse.statusCode {
            case 200..<300:
                print("Honk horn successful")
            case 401:
                print("Unauthorized. Refreshing token...")
                self.RefreshToken()
                if retry {
                    self.HonkHorn(vin: vin, retry: false)
                }
            default:
                print("Unexpected error. Code: \(httpResponse.statusCode)")
            }
        }

        task.resume()
    }

    func FlashLights(vin: String, retry: Bool = false) {
        let accessToken = UserDefaults.standard.string(forKey: "accessToken")

        if accessToken == nil {
            print("Access token is nil")
            return
        }

        let sentryDataURL = URL(
            string: "https://sentry-plus.com/api/flashLights/\(vin)")!
        var request = URLRequest(url: sentryDataURL)
        request.httpMethod = "POST"
        request.addValue(
            "Bearer " + accessToken!, forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let task = URLSession.shared.dataTask(with: request) {
            data, response, error in
            if let error = error {
                print(error.localizedDescription)
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                print("Couldn't get response")
                return
            }

            switch httpResponse.statusCode {
            case 200..<300:
                print("Flash lights successful")
            case 401:
                print("Unauthorized. Refreshing token...")
                self.RefreshToken()
                if retry {
                    self.FlashLights(vin: vin, retry: false)
                }
            default:
                print("Unexpected error. Code: \(httpResponse.statusCode)")
            }
        }

        task.resume()
    }

    func RemoteBoombox(vin: String, retry: Bool) {
        let accessToken = UserDefaults.standard.string(forKey: "accessToken")

        if accessToken == nil {
            print("Access token is nil")
            return
        }

        let sentryDataURL = URL(
            string: "https://sentry-plus.com/api/remoteBoombox/\(vin)")!
        var request = URLRequest(url: sentryDataURL)
        request.httpMethod = "POST"
        request.addValue(
            "Bearer " + accessToken!, forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let task = URLSession.shared.dataTask(with: request) {
            data, response, error in
            if let error = error {
                print(error.localizedDescription)
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                print("Couldn't get response")
                return
            }

            switch httpResponse.statusCode {
            case 200..<300:
                print("Remote boombox successful")
            case 401:
                print("Unauthorized. Refreshing token...")
                self.RefreshToken()
                if retry {
                    self.RemoteBoombox(vin: vin, retry: false)
                }
            default:
                print("Unexpected error. Code: \(httpResponse.statusCode)")
            }
        }

        task.resume()
    }

    func ConfigureFleet() {
        let accessToken = UserDefaults.standard.string(forKey: "accessToken")

        if accessToken == nil {
            print("Access token is nil")
            return
        }

        let sentryDataURL = URL(
            string: "https://sentry-plus.com/api/initializeTelemetry")!

        var request = URLRequest(url: sentryDataURL)
        request.httpMethod = "GET"
        request.addValue(
            "Bearer " + accessToken!, forHTTPHeaderField: "Authorization")

        let task = URLSession.shared.dataTask(with: request) {
            data, response, error in
            if let error = error {
                print(error.localizedDescription)
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                print("Couldn't get response")
                return
            }

            if httpResponse.statusCode != 200 {
                print("Status code: \(httpResponse.statusCode)")
            }
        }

        task.resume()
    }
}
