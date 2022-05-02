//
//  TestTripsViewController.swift
//  DS-SDK-Example
//
//  Created by DriveSmart IOS on 13/04/2020.
//  Copyright © 2020 DriveSmart. All rights reserved.
//

import UIKit
import CoreLocation
import DSTracker

final class TripRecordingViewController: UIViewController, CLLocationManagerDelegate, TrackerListenerInterface {
    @IBOutlet weak var dsUserIDTextField: UITextField!
    @IBOutlet weak var labelDistance: UILabel!
    @IBOutlet weak var labelTime: UILabel!
    @IBOutlet weak var labelGPS: UILabel!
    @IBOutlet weak var labelTripStart: UILabel!
    @IBOutlet weak var labelState: UILabel!
    @IBOutlet weak var switchModeOnline: UISwitch!
    @IBOutlet weak var switchMotionStart: UISwitch!

    var dsUserId: String!

    let locationMgr = CLLocationManager()

    fileprivate var timerService: Timer?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // MARK: - Request location permissions
        locationMgr.delegate = self
        if CLLocationManager.authorizationStatus() == .notDetermined {
            locationMgr.requestWhenInUseAuthorization()
            return
        }
        // MARK: - 5
        Tracker.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let dsUserId = self.dsUserId else { return }
        dsUserIDTextField.text = dsUserId
    }

    // MARK: - IBActions
    @IBAction func buttonStart(_ sender: Any) {
        // MARK: - 4
        Tracker.start()
        timerService = Timer.scheduledTimer(timeInterval: 1,
                                            target: self,
                                            selector: #selector(getTrackingStatusInfo),
                                            userInfo: nil,
                                            repeats: true)
        DispatchQueue.main.async {
            self.labelState.text = "Tracking"
        }
    }

    @IBAction func buttonStop(_ sender: Any) {
        // MARK: - 7) Stop trip recording
        Tracker.stop()
        timerService?.invalidate()
        timerService = nil
        DispatchQueue.main.async {
            self.labelState.text = "Stopped"
        }
    }

    // MARK: - 5 TrackerListenerInterface
    func onEvent(_ event: TrackerEvent) {
        var whatHappened = "Unnhandled event"
        switch event {
        case .dataAllSent:
            whatHappened = "All pending tracking data batch has been sent to our servers"

        case .dataSendFailed:
            whatHappened = "A tracking data batch has failed to been comunicated to our servers"

        case .dataSendPaused:
            whatHappened = "A tracking data batch has failed to been comunicated to our servers"

        case .dataSendStarted:
            whatHappened = "A tracking data batch comunication has started"

        case .dataSendSuccess:
            whatHappened = "A tracking data batch comunication has succeded"

        case .trackingAlreadyStarted:
            whatHappened = "An attempt to start recording has been performed while it was already being done"

        case .trackingAlreadyStopped:
            whatHappened = "An attempt to stop recording has been performed while it was already sttoped"

        case .trackingStarted:
            whatHappened = "Tracker has start tracking location"

        case .trackingStopped:
            whatHappened = "Tracker has stopped tracking location"
        @unknown default: break
        }
        print("\(#function) \(#file) : \(whatHappened)")
    }

    func onError(_ error: TrackerError) {
        switch error {
        case .insecureDevice, .invalidCarplate, .invalidClientId, .invalidLicense, .invalidUserId,
                .locationAuthorizationNotGranted, .locationServicesDisabled, .manuallyLaunchNotConfigured,
                .missingLicense, .missingBluetoothDevicesParameter, .motionTrackingAuthorizationNotGranted,
                .motionTrackingNotAvailable, .noNetworkConnection, .unknown, .userIdNotConfigured:
            break
        @unknown default:
            break
        }
        print("\(#function) \(#file) : \(error.localizedDescription)")
    }

    // MARK: - Private methods
    @objc private func getTrackingStatusInfo() {
        let trackingStatus = Tracker.getStatus()

        DispatchQueue.main.async {
            switch trackingStatus.levelGPS {
            case .bad:
                self.labelGPS.text = "BAD"
            case .good:
                self.labelGPS.text = "GOOD"
            case .regular:
                self.labelGPS.text = "REGULAR"
            @unknown default:
                break
            }
            self.labelTime.text = self.secondsToTime(trackingStatus.timer)
            self.labelDistance.text = "\(trackingStatus.totalDistance.rounded()) m"
            self.labelTripStart.text = self.dateToString(date: trackingStatus.serviceTime,
                                                         dateFormat: "dd/MM/yyy HH:mm:ss")
        }
    }

    private func secondsToTime(_ timer: Double) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .full

        return formatter.string(from: TimeInterval(timer)) ?? ""
    }

    private func dateToString(date: Date, dateFormat format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: date)
    }

    // MARK: - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            break
        case .restricted, .denied:
            break
        case .notDetermined:
            break
        @unknown default:
            break
        }
    }
}
