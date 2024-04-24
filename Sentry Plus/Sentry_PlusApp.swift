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
    var appViewModel: AppViewModel
    var teslaApi: TeslaApi?
    
    init() {
        appViewModel = AppViewModel()
        teslaApi = TeslaApi(appViewModel: self.appViewModel)
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
                .environmentObject(appViewModel)
                .onAppear(){
                    Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { timer in
                        if(appViewModel.accessToken.isEmpty)
                        {
                            timer.invalidate()
                            return
                        }
                        
                        teslaApi!.GetVehicles()
                    }
                }
        }
        .modelContainer(sharedModelContainer)
    }
}
