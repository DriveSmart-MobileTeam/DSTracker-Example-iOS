import UIKit
import DSTracker

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        if let licenseKey = Bundle.main.infoDictionary?["DSTRACKER_LICENSE_KEY"] as? String {
            Tracker.configure(licenseKey: licenseKey, doRequestPermissions: true) { outcome in
                if let error = outcome.failure {
                    print(error.localizedDescription)
                } else if let success = outcome.success as? Bool, success {
                    print("🐛\(#file.split(separator: "/").last ?? "") - \(#function) Success")
                }
            }
        }
        return true
    }

    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}
