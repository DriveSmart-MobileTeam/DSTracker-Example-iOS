//
//  ViewController.swift
//  DS-SDK-Example
//
//  Created by DriveSmart IOS on 13/04/2020.
//  Copyright © 2020 DriveSmart. All rights reserved.
//

import UIKit
import DSTracker

final class SetupViewController: UIViewController {

    @IBOutlet weak var uniqueUserIDTextField: UITextField!
    @IBOutlet weak var dsUserIDTextField: UITextField!

    var dsUserId: String? {
        didSet {
            if let driveSmartUserId = dsUserId {
                UserDefaults.standard.set(driveSmartUserId, forKey: "driveSmartUserId")
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        if let driveSmartUserId = UserDefaults.standard.string(forKey: "driveSmartUserId") {
            dsUserIDTextField.text = driveSmartUserId
        }
    }

    // MARK: - 3.a) Register a new user with your identifier
    @IBAction func signInUniqueId(_ sender: Any) {
        guard let uniqueID = uniqueUserIDTextField.text else {
            return
        }
        Tracker.getOrAddUserIdBy(clientId: uniqueID) { result in
            if let error = result.failure {
                print("🐛❌\(#file) - \(#function) addUniqueUserId error=\(error.localizedDescription)")
            }
            guard let dsUserId = result.success as? String else {
                print("🐛❌\(#file) - \(#function) Response doesn't contains a DS user ID, please contact DS.")
                return
            }
            self.dsUserId = dsUserId
            // MARK: - On success, the DS SDK is setted up with a DS user ID,
            // so you are ready to start recording trip for that user
            self.performSegue(withIdentifier: "showTestTrip", sender: nil)
        }
    }

    // MARK: - 3.b) Setup with a known DriveSmart user identifier
    @IBAction func setupDSUserID(_ sender: Any) {
        guard let inputDsUserId = dsUserIDTextField.text else { return }
        Tracker.setUserId(inputDsUserId) { result in
            if let error = result.failure {
                print("🐛❌\(#file) - \(#function) addUniqueUserId error=\(error.localizedDescription)")
            }
            guard let dsUserId = result.success as? String else {
                print("🐛❌\(#file) - \(#function) Response doesn't contains a DS user ID, please contact DS.")
                return
            }
            self.dsUserId = dsUserId
            print("🐛✅ \(#file) - \(#function) Tracker.setUserId(\(inputDsUserId))")
            // MARK: - On success you are ready to start recording trip for that user
            self.performSegue(withIdentifier: "showTestTrip", sender: nil)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let recordingVC = segue.destination as? TripRecordingViewController,
              let dsUserId = self.dsUserId else {
            return
        }
        recordingVC.dsUserId = dsUserId
    }
}
