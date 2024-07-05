[![DSTracker](https://img.shields.io/badge/platform-iOS%2012.1-blue)](https://github.com/DriveSmart-MobileTeam/)
[![Swift](https://img.shields.io/badge/Language-ObjectiveC%20Swift_5.0-orange)](https://img.shields.io/badge/Swift-5.Orange)

# DriveSmart *Tracker* Swift example

This project act as an example on how to integrate DriveSmart (*DS*  in advance) *Tracker* on an iOS app written in Swift.

## Requisites
* [Cocoapods](https://cocoapods.org) as the dependency manager
* iOS 12.1 in advance as requirement
* An __access_token__ provided by *DS*
* You will need an __license key__ provided by *DS*  in order to make your app work with our *Tracker*.
* Your app needs to be configured for request user location (follow [Apple documentation](https://developer.apple.com/documentation/corelocation/adding_location_services_to_your_app) )

If your project doesn´t fills any of this requirements please contact us at [mobileteam@drive-smart.com](mailto:mobileteam@drive-smart.com) in order to look for alternatives for use our *Tracker*.

## 1) Installation

### 1.1) Add the __access_token__ to your Podfile
Add this line to the top of your  _Podfile_:
```ds_pod_repo_token = "REPLACE_WITH_THE_PROVIDED_ACCESS_TOKEN"```
Replace _REPLACE_WITH_THE_PROVIDED_ACCESS_TOKEN_ with the __access_token__ provided by *DS*

> Giving this you can treat this __access_token__ in a secure way on your CI/CD pipelines
### 1.2) Add the *DS* Cocoapods respository as source on your Podifle
In your _Podfile_, below line added in the previous step, add the following:

```source "https://#{ds_pod_repo_token}@tfsdrivesmart.visualstudio.com/DefaultCollection/Drive%20Smart%202.0/_git/Private-Clients-Pod-Specs"```

### 1.3) Add *DS* as a new dependency

Add our *Tracker* dependency on your targets Podfile as:

```pod 'DSTracker'```

### 1.4) Check your _Podfile_
It should look like this:

```
platform :ios, '12.1'
use_frameworks!

# // MARK: - 1.1
ds_pod_repo_token = "irjnntdvscy4jbfn6hxva6yq3ty6hcli6p3pbqqmlyibvzpuurpq"
# // MARK: - 1.2
source "https://#{ds_pod_repo_token}@tfsdrivesmart.visualstudio.com/DefaultCollection/Drive%20Smart%202.0/_git/Private-Clients-Pod-Specs"

project 'DSTracker-Example'

target 'DSTracker-Example' do
  # MARK: - 1.3
  pod 'DSTracker', '1.0.0'
end

```

### 1.5) Install pods
Just execute `pod install --repo-update` and open the workspace for the app to run.

## 2) Configure the *Tracker*

In order to configure the *Tracker* to work with yours *DS* account credentials, it needs you to provide the __license key__.

As the main purpouse of the *Tracker* is to track user device location, the app to use it needs to be granted with `Location Always` user permission for it to work on foreground and background.

> If your app pretends to use the *Tracker* intensively we encourage you to do this in your _UIApplicationDelegate_.
> 
### 2.1) Default configuration
In this way the *Tracker* will rely on that your app already handles the permissions request and will operate silently, but informing about any arros using the `TrackerListenerInterface`, so we encourage you to implement it for keep track of those errors.

```
import DSTracker

func anySwiftFunction() {
  Tracker.configure(licenseKey: "__license key__") { result in
      if let error = result.failure {
          fatalError(error.localizedDescription)
      } else if let successData = result.success {
          print("\(#function) DSTracker.configure result:\(successData)")
      }
  }
}
```

> In this demo project you can add this license key to the `Debug-Config.xcconfig` and `Release-Config.xcconfig` files included being, you can find more info about this `*.xconfig` files in [this post](https://nshipster.com/xcconfig/).

### 2.2) Configure the *Tracker* to request permissions
You can configure the *Tracker* for let it request permissions to the user just when needed:

```
import DSTracker

func anySwiftFunction() {
  Tracker.configure(
    licenseKey: "__license key__", 
    doRequestPermissions: true
  ) { result in
      if let error = result.failure {
          fatalError(error.localizedDescription)
      } else if let successData = result.success {
          print("\(#function) DSTracker.configure result:\(successData)")
      }
  }
}
```

## 3) Setup the *Tracker* with your users
> You can check this section followin code of "SetupViewController" class provided inside the example project 

As you pretend to use *Tracker* for record trips associated with your users, you will need to identify them within the *Tracker*. For that you have 2 options:

### 3.a) Register your user into the *Tracker* 

```
import DSTracker

func anySwiftFunction() {
    let uniqueID = "some user identifier that's under your control, typically it use to be an user`s email"
    Tracker.getOrAddUserIdBy(clientId: uniqueID) { result in
        if let error = result.failure {
            print("\(#file) - \(#function) addUniqueUserId error=\(error.localizedDescription)")
        }
        guard let trackerUserId = result.success as? String else {
            print("\(#file) - \(#function) Response doesn't contains a DS user ID, please contact DS.")
            return
        }
        // MARK: - On success, the DSTracker is setted up with a DSTracker user ID,
        // so you are ready to start recording trip for that use
    }
}
```
> In order to improve the setup workflow we recommend you to store the "trackerUserId" returned here for use it in future app runs using the method below.
### 3.b) Setup with a known *Tracker* user identifier
If you known the *Tracker* user id, or you stored the one provided in teh step *3.a*, you can just use it for a quick setup like:

```
import DSTracker

func anySwiftFunction() {
    Tracker.setUserId("a known DSTracker user identifier") { result in
        if let error = result.failure {
            print("\(#file) - \(#function) addUniqueUserId error=\(error.localizedDescription)")
        }
        guard let trackerUserId = result.success as? String else {
            print("\(#file) - \(#function) Response doesn't contains a DS user ID, please contact DS.")
            return
        }
    }
}
```

### 3.c) Get a DSTracker user identifier for you to associate it with your user
If you dont´w wnat to pass your user's identifier to our systems for us to stablish the relationship with our user identifier, you can get a DSTracker user identifier for yopu to save it and stablish the relationship with your userts. For that use this:


```
import DSTracker

func anySwiftFunction() {
    Tracker.setUserId("a known DSTracker user identifier") { result in
        if let error = result.failure {
            print("\(#file) - \(#function) addUniqueUserId error=\(error.localizedDescription)")
        }
        guard let trackerUserId = result.success as? String else {
            print("\(#file) - \(#function) Response doesn't contains a DS user ID, please contact DS.")
            return
        }
    }
}
```

## 4) Trip recording
> You can check this section following code of "TripRecordingViewController" class provided inside the example project.
At this point all is set and ready to start recording trips, so:
### 4.1) Start
This method will start capturing device location inmediately based until you call to following method.
```
    @IBAction func buttonStart(_ sender: Any) {
        // MARK: - 4
        Tracker.start()
```
### 4.2) Get information about the trip in progress
At any time that *Tracker* is recordin a trip, you can check how it is going, again taking as example the code inside `TripRecordingViewController`, you can do something similar to:
```
    @objc func getTrackingStatusInfo() {
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
            self.labelDistance.text = "\(trackingStatus.totalDistance) m"
            self.labelTripStart.text = self.dateToString(date: trackingStatus.serviceTime,
                                                         dateFormat: "dd/MM/yyy HH:mm:ss")
        }
    }

```
### 4.3) Stop
This will stop capturing device location and will try to send all pending tracking data to our servers.
```
    @IBAction func buttonStop(_ sender: Any) {
        // MARK: - 7) Stop trip recording
        Tracker.stop()
```
## 6) [Optional] Get informed about *Tracker* events and errors
The *Tracker* uses delegation for inform about important internal events that you may need for your integration. 
For that, provide the delegate implementation of `TrackerListenerInterface` like:
```
extension TripRecordingViewController: DSTrackerDelegate {
    //...
    Tracker.delegate = self
```
And implemente the protocol like this:
``` 
    // MARK: - TrackerListenerInterface
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
``` 
