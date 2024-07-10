//
//  Sentry_PlusApp.swift
//  Sentry Plus
//
//  Created by Onur Altun on 2.04.2024.
//

import SwiftUI
import SwiftData

@main
struct Sentry_PlusApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var teslaApi: TeslaApi?
    
    init() {
        teslaApi = TeslaApi()
    }
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            ContentView(teslaApi: self.teslaApi!)
                .environmentObject(AppViewModel.shared)
                .onAppear(){
                    Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { timer in
                        if(AppViewModel.shared.accessToken.isEmpty)
                        {
                            timer.invalidate()
                            return
                        }
                        
                        teslaApi!.GetVehicles()
                    }
                    
                    teslaApi!.GetVehicles()
                }
        }
        .modelContainer(sharedModelContainer)
    }
}
