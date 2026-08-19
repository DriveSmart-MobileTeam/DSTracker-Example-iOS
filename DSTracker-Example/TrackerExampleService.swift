import Combine
import CoreLocation
import DSTracker
import Foundation

final class TrackerExampleService: NSObject, ObservableObject {
    @Published var uniqueUserID = ""
    @Published var knownTrackerUserID = ""
    @Published var activeTrackerUserID: String?
    @Published private(set) var isIdentifyingUser = false
    @Published private(set) var tripState = "Stopped"
    @Published private(set) var elapsedTime = ""
    @Published private(set) var distance = ""
    @Published private(set) var gpsQuality = ""
    @Published private(set) var tripStart = ""

    private let locationManager = CLLocationManager()
    private var statusTimer: Timer?
    private var hasRequestedAlwaysAuthorization = false

    override init() {
        super.init()
        locationManager.delegate = self
        knownTrackerUserID = UserDefaults.standard.string(forKey: "driveSmartUserId") ?? ""
    }

    deinit {
        statusTimer?.invalidate()
    }

    // MARK: - 3.a) Register a new user with your identifier
    func registerUniqueUser() {
        beginUserIdentification()
        Tracker.getOrAddUserIdBy(clientId: uniqueUserID) { [weak self] result in
            self?.finishUserIdentification()
            if let error = result.failure {
                print("🐛❌\(#file) - \(#function) addUniqueUserId error=\(error.localizedDescription)")
            }
            guard let trackerUserID = result.success as? String else {
                print("🐛❌\(#file) - \(#function) Response doesn't contain a DS user ID, please contact DS.")
                return
            }
            self?.setActiveUser(trackerUserID)
        }
    }

    // MARK: - 3.b) Setup with a known DriveSmart user identifier
    func setupKnownUser() {
        let inputTrackerUserID = knownTrackerUserID
        beginUserIdentification()
        Tracker.setUserId(inputTrackerUserID) { [weak self] result in
            self?.finishUserIdentification()
            if let error = result.failure {
                print("🐛❌\(#file) - \(#function) addUniqueUserId error=\(error.localizedDescription)")
            }
            guard let trackerUserID = result.success as? String else {
                print("🐛❌\(#file) - \(#function) Response doesn't contain a DS user ID, please contact DS.")
                return
            }
            self?.setActiveUser(trackerUserID)
            print("🐛✅ \(#file) - \(#function) Tracker.setUserId(\(inputTrackerUserID))")
        }
    }

    // MARK: - 3.c) Allow DriveSmart to register a new user for you
    func registerAnonymousUser() {
        beginUserIdentification()
        Tracker.getAnonymousUserId { [weak self] outcome in
            self?.finishUserIdentification()
            if let error = outcome.failure {
                print("🐛❌\(#file) - \(#function) error=\(error)")
            }
            guard let trackerUserID = outcome.success as? String else {
                print("🐛❌\(#file) - \(#function) Response doesn't contain a DS user ID, please contact DS.")
                return
            }
            self?.setActiveUser(trackerUserID)
            print("🐛✅ \(#file) - \(#function) userId: \(trackerUserID)")
        }
    }

    func prepareTripRecording() {
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            return
        case .authorizedWhenInUse:
            requestAlwaysAuthorizationIfNeeded()
        case .authorizedAlways, .restricted, .denied:
            break
        @unknown default:
            break
        }
        Tracker.delegate = self
    }

    // MARK: - 4) Start trip recording
    func startTrip() {
        Tracker.start()
        statusTimer?.invalidate()
        statusTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.refreshTrackingStatus()
        }
        tripState = "Tracking"
    }

    // MARK: - 7) Stop trip recording
    func stopTrip() {
        Tracker.stop()
        statusTimer?.invalidate()
        statusTimer = nil
        tripState = "Stopped"
    }

    private func setActiveUser(_ trackerUserID: String) {
        UserDefaults.standard.set(trackerUserID, forKey: "driveSmartUserId")
        DispatchQueue.main.async {
            self.knownTrackerUserID = trackerUserID
            self.activeTrackerUserID = trackerUserID
        }
    }

    private func beginUserIdentification() {
        DispatchQueue.main.async {
            self.isIdentifyingUser = true
        }
    }

    private func finishUserIdentification() {
        DispatchQueue.main.async {
            self.isIdentifyingUser = false
        }
    }

    private func refreshTrackingStatus() {
        let trackingStatus = Tracker.getStatus()
        DispatchQueue.main.async {
            switch trackingStatus.levelGPS {
            case .bad: self.gpsQuality = "BAD"
            case .good: self.gpsQuality = "GOOD"
            case .regular: self.gpsQuality = "REGULAR"
            @unknown default: break
            }
            self.elapsedTime = Self.secondsToTime(trackingStatus.timer)
            self.distance = "\(trackingStatus.totalDistance.rounded()) m"
            self.tripStart = Self.dateToString(date: trackingStatus.serviceTime, format: "dd/MM/yyy HH:mm:ss")
        }
    }

    private static func secondsToTime(_ timer: Double) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .full
        return formatter.string(from: TimeInterval(timer)) ?? ""
    }

    private static func dateToString(date: Date, format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: date)
    }

    private func requestAlwaysAuthorizationIfNeeded() {
        guard !hasRequestedAlwaysAuthorization else { return }
        hasRequestedAlwaysAuthorization = true
        locationManager.requestAlwaysAuthorization()
    }
}

extension TrackerExampleService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse:
            requestAlwaysAuthorizationIfNeeded()
            Tracker.delegate = self
        case .authorizedAlways:
            Tracker.delegate = self
        case .restricted, .denied, .notDetermined:
            break
        @unknown default:
            break
        }
    }
}

extension TrackerExampleService: TrackerListenerInterface {
    // MARK: - 5) TrackerListenerInterface
    func onEvent(_ event: TrackerEvent) {
        var whatHappened = "Unhandled event"
        switch event {
        case .dataAllSent: whatHappened = "All pending tracking data batch has been sent to our servers"
        case .dataSendFailed: whatHappened = "A tracking data batch has failed to be communicated to our servers"
        case .dataSendPaused: whatHappened = "A tracking data batch communication has been paused"
        case .dataSendStarted: whatHappened = "A tracking data batch communication has started"
        case .dataSendSuccess: whatHappened = "A tracking data batch communication has succeeded"
        case .trackingAlreadyStarted: whatHappened = "An attempt to start recording was performed while it was already running"
        case .trackingAlreadyStopped: whatHappened = "An attempt to stop recording was performed while it was already stopped"
        case .trackingStarted: whatHappened = "Tracker has started tracking location"
        case .trackingStopped: whatHappened = "Tracker has stopped tracking location"
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
        @unknown default: break
        }
        print("\(#function) \(#file) : \(error.localizedDescription)")
    }
}
