# DriveSmart migration guide from *DSFramework* to *DSTracker*

## Requisites
No change at this point.


## 1) Installation

WE keep using Cocoapods for distributing our dependency.

## 2) Configure the *DSTracker* with your license key

### 2.1) Old
```
import DSFramework

func anySwiftFunction() {
  DRSApp.configure(license key: "__license key__")
}
```

### 2.2) New way

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

In this way the *DSTracker* will rely on that your app already handles the permissions request and will operate silently, but informing about any arros using the `TrackerListenerInterface`, so we encourage you to implement it for keep track of those errors.

## 3) Setup the *DSTracker* with your users

### 3.a) Register your user into the DS *DSTracker* 

#### 3.a.1) Old
```
import DSFramework

func anySwiftFunction() {
    DRSApp.getOrAddUserIdBy(clientId: "some user identifier that's under your control, typically it use to be an user`s email")
}
```
If it works, it will return you the string representing the DriveSmart user identifier associated to the one you passed as argument, you can check it like this:
``` 

DRSApp.addUnique(userId: uniqueID) { result, error in
  guard let signInResult = result as? SignInSuccessResponseModel,
    let dsUserId = signInResult.userID else {
    return
  }

```
#### 3.a.1) New
In this new way all is done in a single call for a cleaner code.
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
### 3.b) Setup with a known DriveSmart user identifier
### 3.b.1) Old
If you known the *DS*  user id, or you stored the one provided in *3.a.1* you can just use it for setup like:

```
import DSFramework

func anySwiftFunction() {
    DRSApp.setUserId("a known DriveSmart user identifier")
}
```
### 3.b.2) New
Tottally equivalent, just rename of the global object.
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

## Use the *DSTracker*
> You can check this section followin code of "TripRecordingViewController" class provided inside the example project

### 4) Assign an *DSTracker* delegate
The *DS*  *DSTracker* uses delegation for inform about important internal events that you may need for your integration. 
For that, provide the delegate implementation
```
DRSApp.delegate = ds*DSTrackerDelegate*
```

### 5) Implement the *DSTracker* delegate
Following the example provided:
```
extension TripRecordingViewController: DRSAppProtocol {
```

### 6) Handling trip recording 
#### 6.1) Old
```
@IBAction func buttonStart(_ sender: Any) {
    //MARK: - 6) Start trip recording
    DRSApp.startService()
}

@IBAction func buttonStop(_ sender: Any) {
    //MARK: - 7) Stop trip recording
    DRSApp.stopService()
}
@IBAction func buttonPauseRestart(_ sender: Any) {
    //MARK: - 8) Pause the trip
    DRSApp.pauseService { [weak self] (result, error) in
    }
}
```
#### 6.2) New
```
@IBAction func buttonStart(_ sender: Any) {
    //MARK: - 6) Start trip recording
    Tracker.start()
}

@IBAction func buttonStop(_ sender: Any) {
    //MARK: - 7) Stop trip recording
    Tracker.stop()
}
```
