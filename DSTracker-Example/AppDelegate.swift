//
//  AppDelegate.swift
//  DS-SDK-Example
//
//  Created by DriveSmart IOS on 13/04/2020.
//  Copyright © 2020 DriveSmart. All rights reserved.
//

import UIKit
import DSTracker

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        // MARK: - 2
        if let licenseKey = Bundle.main.infoDictionary?["DSTRACKER_LICENSE_KEY"] as? String {
            Tracker.configure(licenseKey: licenseKey) { result in
                if let error = result.failure {
                    fatalError(error.localizedDescription)
                } else if let successData = result.success {
                    print("🐛✅\(#function) DSTracker.configure result:\(successData)")
                }
            }
        }
        return true
    }
    // MARK: UISceneSession Lifecycle
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

}
