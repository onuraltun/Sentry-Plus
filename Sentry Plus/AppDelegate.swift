import UIKit
import UserNotifications

class AppDelegate: UIResponder, UIApplicationDelegate {
    let teslaApi = TeslaApi(appViewModel: AppViewModel())
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        teslaApi.GetVehicles()
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
            } else {
                DispatchQueue.main.async {
                    print("Notification permission denied")
                    
                    let alert = UIAlertController(title: "Error", message: "Push notification permission denied. Please enable push notifications in Settings for getting alerts.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true, completion: nil)
                }
            }
        }
        application.registerForRemoteNotifications()
        
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("APN token: \(token)")
        UserDefaults.standard.set(token, forKey: "deviceToken")
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        DispatchQueue.main.async {
            print("Failed to register for push notifications: \(error.localizedDescription)")
            let alert = UIAlertController(title: "Error", message: "Failed to register for push notifications: \(error.localizedDescription). Please try again later.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true, completion: nil)
        }
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        teslaApi.GetVehicles()
    }
}
