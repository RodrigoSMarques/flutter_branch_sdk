## 8.6.0
### 🔧 Native SDK Updates
* Updated included Branch Android SDK to 5.19.0 - [Android Version History](https://github.com/BranchMetrics/android-branch-deep-linking-attribution/releases)

### 🐛 Bug Fixes
* Fix issue #442: [Web] getShortUrl() Future never completes on alias conflict (err arrives as JS Error, not String)

### 🎉 Features
* Reviewing the documentation for the `FlutterBranchSdk.validateSDKIntegration()` method
* Improved error handling in Flutter Web

## 8.5.0
### 🔧 Native SDK Updates
* Updated included iOS SDK to 3.12.0 - [iOS Version History](https://github.com/BranchMetrics/ios-branch-deep-linking-attribution/releases)
* Updated included Branch Android SDK to 5.18.0 - [Android Version History](https://github.com/BranchMetrics/android-branch-deep-linking-attribution/releases)

## 8.4.1
### 🐛 Bug Fixes
* Fix issue #423: setRequestMetadata doesn't populate the key value pairs in the event request as expected

## 8.4.0
### 🔧 Native SDK Updates
* Updated included iOS SDK to 3.9.0 - [iOS Version History](https://github.com/BranchMetrics/ios-branch-deep-linking-attribution/releases)

## 8.3.2
### ⚠️ BREAKING CHANGE
* Minimum required Dart SDK version 3.3.0 (Flutter 3.19.0 - 15/02/2024)

### 🐛 Bug Fixes
* Fix issue #410: "reply already sent and a possible ANR". Tks @Junglee-Faisal

### 🎉 Features
* Migrated Gradle to declarative plugins block

## 8.3.1
### ⚠️ BREAKING CHANGE
* Minimum required Dart SDK version 3.3.0 (Flutter 3.19.0 - 15/02/2024)

### 🎉 Features
* Revised documentation including section to change **Flutter Deep link flag**
* New option in INFO.PLIST (`branch_disable_nativelink`) that allows disable NativeLink™ Deferred Deep Linking

## 8.3.0
### ⚠️ BREAKING CHANGE
* Minimum required Dart SDK version 3.3.0 (Flutter 3.19.0 - 15/02/2024)

### 🎉 Features
* New Methods:
    - `setConsumerProtectionAttributionLevel` - Sets the consumer protection attribution level. Read Branch documentation for details:
    	* [Introducing Consumer Protection Preference Levels](https://help.branch.io/using-branch/changelog/introducing-consumer-protection-preference-levels)
    	* [Consumer Protection Preferences](https://help.branch.io/developers-hub/docs/consumer-protection-preferences)

#### Deprecated / Removed
* `FlutterBranchSdk.disableTracking()`. Use `FlutterBranchSdk.setConsumerProtectionAttributionLevel()`.
* Removed `initSession` method.

### Native SDK Updates
### 🔧 Native SDK Updates
* Updated included iOS SDK to 3.7.0 - [iOS Version History](https://github.com/BranchMetrics/ios-branch-deep-linking-attribution/releases)
* Updated included Branch Android SDK to 5.15.0 - [Android Version History](https://github.com/BranchMetrics/android-branch-deep-linking-attribution/releases)

## 8.2.0
### ⚠️ BREAKING CHANGE
* Minimum required Dart SDK version 3.3.0 (Flutter 3.19.0 - 15/02/2024)

### 🎉 Features
* Issue #361: Migrate to dart:js_interop to support Webassamebly. Thanks @hnvn

## 8.1.1
### 🐛 Bug Fixes
* Fix issue #368: "-118, Warning. Session initialization already happened" triggered in the listSession callback

## 8.1.0
### 🔧 Native SDK Updates
* Updated included iOS SDK to 3.6.0 - [iOS Version History](https://github.com/BranchMetrics/ios-branch-deep-linking-attribution/releases)
* Updated included Branch Android SDK to 5.12.2 - [Android Version History](https://github.com/BranchMetrics/android-branch-deep-linking-attribution/releases)

## 8.0.4
### ⚠️ BREAKING CHANGE
This is a major release which contains breaking API changes.
#### ⚠️ SDK Initialization Changed
* `useTestKey` parameter is no longer supported at `FlutterBranchSdk.init()`.

Check the instructions in `README.MD` on how to activate the `key_test_`.

### 🐛 Bug Fixes
* Fix issue #347: ios plugin v8.0.3 crashes when no url is returned
* Fix issue #338: Changing the return value in didFinishLaunchingWithOptions crashes the application from SDK version above 8.0.0

## 8.0.3
### ⚠️ BREAKING CHANGE
This is a major release which contains breaking API changes.
#### ⚠️ SDK Initialization Changed
* `useTestKey` parameter is no longer supported at `FlutterBranchSdk.init()`.

Check the instructions in `README.MD` on how to activate the `key_test_`.

### 🐛 Bug Fixes
* Fix issue #340: Logging not working in Android Studio Emulator

## 8.0.2
### ⚠️ BREAKING CHANGE
This is a major release which contains breaking API changes.
#### ⚠️ SDK Initialization Changed
* `useTestKey` parameter is no longer supported at `FlutterBranchSdk.init()`.

Check the instructions in `README.MD` on how to activate the `key_test_`.

### 🐛 Bug Fixes
* Fix Enable and Disable Tracking on `FlutterBranchSdk.init()` method

## 8.0.1
### ⚠️ BREAKING CHANGE
This is a major release which contains breaking API changes.
#### ⚠️ SDK Initialization Changed
* `useTestKey` parameter is no longer supported at `FlutterBranchSdk.init()`.
 
 Check the instructions in `README.MD` on how to activate the `key_test_`.

### 🐛 Bug Fixes
* Fix issue #325: Android cannot get the opening link (onInitFinished called after clicking on deep link two times)

## 8.0.0
### ⚠️ BREAKING CHANGE
This is a major release which contains breaking API changes.
#### ⚠️ SDK Initialization Changed
* `useTestKey` parameter is no longer supported at `FlutterBranchSdk.init()`.
 
 Check the instructions in `README.MD` on how to activate the `key_test_`.

### 🐛 Bug Fixes
* Fix issue #283: Android app not getting correct deeplink from Branch when app is opened
* Fix issue #308: Android non branch deep link sometimes not available
* Fix issue #309: Completion of await FlutterBranchSdk.init() doesn't mean native iOS plugin is ready?
* Fix issue #311: Flutter SDK init falls into loop when race condition happens during the initialization.
* Fix issue #314: Issue with Branch.io Integration on Apple 14 pro
* Fix issue #316: Not getting link after fresh install

### 🔧 Native SDK Updates

* Updated included iOS SDK to 3.4.3 - [iOS Version History](https://github.com/BranchMetrics/ios-branch-deep-linking-attribution/releases)
* Updated included Branch Android SDK to 5.12.0 - [Android Version History](https://github.com/BranchMetrics/android-branch-deep-linking-attribution/releases)


## 7.3.0
### 🔧 Native SDK Updates

* Updated included Branch Android SDK to 5.11.0 - [Android Version History](https://github.com/BranchMetrics/android-branch-deep-linking-attribution/releases)
* Updated included Branch iOS SDK to 3.4.1 - [iOS Version History](https://github.com/BranchMetrics/ios-branch-deep-linking-attribution/releases)

## 7.2.0
### 🎉 Features
* `showShareSheet` method will now display the native Android share sheet.
* Documentation review

### 🔧 Dependencies Update
* Updated dependency `js`. From version 0.6.7 to 7.0.0

### 🔧 Native SDK Updates
* Updated included Branch Android SDK to 5.10.1 - [Android Version History](https://github.com/BranchMetrics/android-branch-deep-linking-attribution/releases)

## 7.1.0
### 🎉 Features
* New Methods:
    - `setDMAParamsForEEA` - In response to the European Union's enactment of the Digital Markets Act (DMA), this new method  help pass consent information from your user to Google. 
    See [documentation](https://github.com/RodrigoSMarques/flutter_branch_sdk?tab=readme-ov-file#user-data) for details.

### 🐛 Issues

* Fix issue #297: Allow Call setRequestMetadata after FlutterBranchSdk.init() method

### 🔧 Native SDK Updates

* Updated included Branch Android SDK to 5.9.0 - [Android Version History](https://github.com/BranchMetrics/android-branch-deep-linking-attribution/releases)
* Updated included Branch iOS SDK to 3.3.0 - [iOS Version History](https://github.com/BranchMetrics/ios-branch-deep-linking-attribution/releases)

## 7.0.4
### Issues

* Fix issue #289 : reverts `js` dependency update. From version 0.7.0 to 0.6.7

## 7.0.3
### Issues

* Fix issue #277 : PlatformException - NullPointerException

### Features
* PR #286 : fix: export platform_interface
* Updated configuration steps in README.MD
* Sample app - code review

## 7.0.2
### Issues

* Fix issue #261 / #266 / #268: Calling startActivity() from outside of an Activity
* Fix issue #264: Android (PlayStore) : Branch SDK Params empty on background state 
* Fix issue #265: New release 7.0.0+ not getting a deeplink data on first launch, when app is on resume
* Fix issue #270: Indicate when error is thrown in init

### Native SDK Updates

* Updated included Android SDK to 5.8.0 - [Android Version History](https://github.com/BranchMetrics/android-branch-deep-linking-attribution/releases)

## 7.0.1
* Fix issue #255: `Attempt to invoke virtual method 'int android.content.Intent.getFlags()' on a null object reference` when using FlutterFragmentActivity
* Fix issue #256: `A problem occurred configuring project ':flutter_branch_sdk'.` - Add compatibility with AGP 8 (Android Gradle Plugin)

## 7.0.0
⚠️ This is a major release which contains breaking API changes.
### BREAKING CHANGE

* Minimum required Dart SDK version to 2.18 (Flutter 3.3.0)
* Xcode 15 is the min version
* iOS 12 is the min version

#### SDK Initialization Required
* Use `FlutterBranchSdk.init()` method to initialize the SDK.

Initialization must be called from `main` or at any time (for example after getting consent for GPDR).

```dart
  await FlutterBranchSdk.init(
      useTestKey: false, enableLogging: false, disableTracking: false);
```

Check additional instructions in the README

#### Deprecated / Removed

* `FlutterBranchSdk.initSession()`. Use `FlutterBranchSdk.listSession()`.
* Removed `setIOSSKAdNetworkMaxTime` method
* Removed Facebook App Install Ads on iOS

### Features

* Issue #244 - Support for setting customer_event_alias for BranchEvent
* Updated compile & target SDK to Android API 33.
* Updated example app Android compileSdkVersion to 33.

### Native SDK Updates

* Updated included iOS SDK to 3.0.0 - [iOS Version History](https://github.com/BranchMetrics/ios-branch-deep-linking-attribution/releases)

## 6.9.0
### Enhancement
* Issue #244 - Support for setting customer_event_alias for BranchEvent

## 6.8.0
* Updated Native `Android` SDKs:
    * Android Native SDK Update 5.7.+ - [Android Version History](https://github.com/BranchMetrics/android-branch-deep-linking-attribution/releases)
    * iOS Native SDK Update 2.2.1 - [iOS Version History](https://github.com/BranchMetrics/ios-branch-deep-linking-attribution/releases)
* Removed:
    - Facebook App Install Ads on Android (parameter `branch_enable_facebook_ads`)

## 6.7.1
* Fix issue #237: `Pass long URL when try creating Short URL in Offline`

## 6.7.0
* Updated Native `Android` and `iOS` SDKs:
    * Android Native SDK Update 5.6.+ - [Android Version History](https://github.com/BranchMetrics/android-branch-deep-linking-attribution/releases)
    * iOS Native SDK Update 2.2.0 - [iOS Version History](https://github.com/BranchMetrics/ios-branch-deep-linking-attribution/releases)
* Removed:
	- Firebase App Indexing in Android (`listOnSearch` and `removeFromSearch` return `success` but do not perform any action)
	- Old Apple Search Ads APIs (parameter `branch_check_apple_ads`)

## 6.6.0
* Updated Native `Android` and `iOS` SDKs:
    * Android Native SDK Update 5.4.+ - [Android Version History](https://github.com/BranchMetrics/android-branch-deep-linking-attribution/releases)
    * iOS Native SDK Update 2.1.0 - [iOS Version History](https://github.com/BranchMetrics/ios-branch-deep-linking-attribution/releases)

* New Methods:
    - `addSnapPartnerParameter` - See [documentation](https://help.branch.io/using-branch/docs/snap) on partner parameters for details.

## 6.5.0
* Updated Native `iOS` SDK:
    * iOS Native SDK Update 2.0.0 - [iOS Version History](https://github.com/BranchMetrics/ios-branch-deep-linking-attribution/releases)

## 6.4.0
* Fix issue #193: `Flutter app won't get notified about the quick link event if the app is at foreground on Android devices`

* New Methods:
    - `addFacebookPartnerParameter` - See [documentation](https://help.branch.io/developers-hub/docs/pass-hashed-information-for-facebook-advanced-matching) on partner parameters for details.
    - `clearPartnerParameter` - Clears all Partner Parameters
    - `setPreinstallCampaign` -  [Add the pre-install campaign analytics](https://help.branch.io/developers-hub/docs/pre-install-analytics)
    - `setPreinstallPartner` -  [Add the pre-install campaign analytics](https://help.branch.io/developers-hub/docs/pre-install-analytics)
* Updated Native `iOS` SDK:
    * iOS Native SDK Update 1.45.0 - [iOS Version History](https://github.com/BranchMetrics/ios-branch-deep-linking-attribution/releases)
	 
     > Note: _Requires Xcode 14+_

## 6.3.0
* New Method `handleDeepLink`
* Fix issue #188: `Failed to handle method call: java.lang.NullPointerException`
* Fix issue #189: `Fix crash when adding a boolean control param`
* Fix issue #190: `getTrackingAuthorizationStatus will open the iOS-dialog to requestTrackingAuthorization`

## 6.2.1
* Fix issue #181: `Calling the getLastAttributedTouchData() exit with exception on IOS 15.7`

## 6.2.0
* Update `BranchStandardEvent` list.

## 6.1.0
* Updated `Android Advertising ID (AAID)` version in Android SDK.

## 6.0.0
### BREAKING CHANGE
* Minimum required Dart SDK version to 2.17 (Flutter 3.0)
* Removed deprecated methods: 
  * `initWeb`
  * `loadRewards`
  * `redeemRewards`
  * `getCreditHistory`

### Enhancement
* New Methods:
   - `getQRCodeAsData`
   - `getQRCodeAsImage`
   - `shareWithLPLinkMetadata`
* General improvements in code
* Fix analyzer code style warnings
* Updated Native `Android` and `iOS` SDKs:
    * Android Native SDK Update 5.2.+ - [Android Version History](https://github.com/BranchMetrics/android-branch-deep-linking-attribution/releases)
    * iOS Native SDK Update 1.43.+ - [iOS Version History](https://github.com/BranchMetrics/ios-branch-deep-linking-attribution/releases)

## 5.1.1
* Updated Native `Android` SDK:
    * Android Native SDK Update 5.1.5 - [Android Version History](https://github.com/BranchMetrics/android-branch-deep-linking-attribution/releases)
* Removed dependencies: `flutter_lints` (not in used) 

## 5.1.0
* Fix issue #143: Infinite loop with POST requests when offline
* Fix issue #146: clicked_branch_link is to true when app is opened from deeplink and then putted in background and reopened
* Fix issue #113: Fatal Exception: java.lang.IllegalStateException Reply already submitted
* New Method `getLastAttributedTouchData`
* Updated Native `Android` and `iOS` SDKs:
	* Android Native SDK Update 5.1.4 - [Android Version History](https://github.com/BranchMetrics/android-branch-deep-linking-attribution/releases)
	* iOS Native SDK Update 1.42.0 - [iOS Version History](https://github.com/BranchMetrics/ios-branch-deep-linking-attribution/releases)

## 5.0.0
###BREAKING CHANGE:

* `FlutterBranchSdk.initWeb` deprecated.
* Branch for Flutter Web initialized in `index.html`, see `Web Integration` section
* `FlutterBranchSdk.trackContent` method changed to accept List of Branch Universal Object :

	*Before:*
	```dart
	FlutterBranchSdk.trackContent(
	  buo: buo,
	  branchEvent: event
	);
   ```

   *After:*
 	```dart
     FlutterBranchSdk.trackContent(
       buo: [buo],
       branchEvent: event
     );
   ```
 
 ------------
 
* Updated Native `Android` and `iOS` SDKs:
	* Android Native SDK Update 5.1.0 - [Android Version History](https://github.com/BranchMetrics/android-branch-deep-linking-attribution/releases)
	* iOS Native SDK Update 1.41.0 - [iOS Version History](https://github.com/BranchMetrics/ios-branch-deep-linking-attribution/releases)

## 4.0.0
* Migrate maven repository from jcenter to mavenCentral.
* Updated compile & target SDK to Android API 31.
* Updated minSdkVersion to Android API 21.
* Updated example app Android compileSdkVersion to 31.
* Removed support for the V1 Android embedding.
* Deprecate Referral rewards SDK Methods (loadRewards, redeemRewards, getCreditHistory)
* Removed Referral rewards SDK Methods from example app
* Updated Native `Android` and `iOS` SDKs:
  **Android Native SDK Update 5.0.15 - [Android Version History](https://github.com/BranchMetrics/android-branch-deep-linking-attribution/releases)
  **iOS Native SDK Update 1.40.2 - [iOS Version History](https://github.com/BranchMetrics/ios-branch-deep-linking-attribution/releases)

## 3.5.0
* Updated Native `Android` and `iOS` SDKs:  
  **Android Native SDK Update 5.0.14 - [Android Version History](https://github.com/BranchMetrics/android-branch-deep-linking-attribution/releases)  
  **iOS Native SDK Update 1.40.1 - [iOS Version History](https://github.com/BranchMetrics/ios-branch-deep-linking-attribution/releases)
* Bug fix #124: typo in android BUO converter

## 3.4.0
* Updated Native `Android` and `iOS` SDKs:  
**Android Native SDK Update 5.0.10 - [Android Version History](https://github.com/BranchMetrics/android-branch-deep-linking-attribution/releases)  
**iOS Native SDK Update 1.39.4 - [iOS Version History](https://github.com/BranchMetrics/ios-branch-deep-linking-attribution/releases)
* [Added support to Clipboard Deferred Deep Linking](https://help.branch.io/developers-hub/docs/ios-advanced-features#clipboard-deferred-deep-linking)

## 3.3.0
* Added support to `FlutterFragmentActivity`

## 3.2.0
* Updated Native `Android` and `iOS` SDKs:  
**Android Native SDK Update 5.0.9 - [Android Version History](https://github.com/BranchMetrics/android-branch-deep-linking-attribution/releases)  
**iOS Native SDK Update 1.39.3 - [iOS Version History](https://github.com/BranchMetrics/ios-branch-deep-linking-attribution/releases)
* [Added support to Facebook App Install Ads](https://help.branch.io/using-branch/docs/facebook-app-install-ads)
* Allow to enable and disable Branch Log 
* Bug fix #100 NullPointerException when leaving the app
* Bug fix eventSink nulllpointer exception

## 3.1.0
* Updated Native `iOS` SDKs:  
**iOS Native SDK Update 1.39.2 - [iOS Version History](https://github.com/BranchMetrics/ios-branch-deep-linking-attribution/releases)
* Added new method `requestTrackingAuthorization` : In iOS 14+,  show tracking authorization dialog and request permission. Send `ATTrackingManager.AuthorizationStatus` to monitor `ATT prompt performance` and  return `ATTrackingManager.AuthorizationStatus`. 
* Added new method `getTrackingAuthorizationStatus`: Return `ATTrackingManager.AuthorizationStatus`
* Added new method `getAdvertisingIdentifier`: Return Device Advertising Identifier 
 
## 3.0.0
* Initial support to Flutter Web. Thanks @mathatan 

## 2.0.0
* Stable null safety release.
* Updated Native `Android` and `iOS` SDKs:  
**Android Native SDK Update 5.0.7 - [Android Version History](https://github.com/BranchMetrics/android-branch-deep-linking-attribution/releases)  
**iOS Native SDK Update 1.39.0 - [iOS Version History](https://github.com/BranchMetrics/ios-branch-deep-linking-attribution/releases)  

## 2.0.0-nullsafety.3
* Updated Native `Android` and `iOS` SDKs:  
**Android Native SDK Update 5.0.5 - [Android Version History](https://github.com/BranchMetrics/android-branch-deep-linking-attribution/releases)  
**iOS Native SDK Update 1.38.0 - [iOS Version History](https://github.com/BranchMetrics/ios-branch-deep-linking-attribution/releases)  
* Fix issue #83 - [Android - app crashed when click on back button](https://github.com/RodrigoSMarques/flutter_branch_sdk/issues/83)  
* Fix deprecated API usage warning 

## 2.0.0-nullsafety.1
* Android: fixed assertion failures due to reply messages that were sent on the wrong thread.
* iOS: fixed assertion failures due to reply messages that were sent on the wrong thread.
* Fix crash when setting expirationDateInMilliSec on Android

## 2.0.0-nullsafety.0
* Initial support for null safety

## 1.3.0
* iOS Native SDK Update 0.36.0 - [iOS Version History](https://github.com/BranchMetrics/ios-branch-deep-linking-attribution/releases)

## 1.2.0
* Android: BugFix on ```onNewIntent```
* iOS:     new method: ```setRequestMetadata```
           new method: ```setIOSSKAdNetworkMaxTime```

## 1.1.0
Updated Native ```Android``` and ```iOS``` SDKs
* Android Native SDK Update 5.0.3 - [Android Version History](https://github.com/BranchMetrics/android-branch-deep-linking-attribution/releases)
* iOS Native SDK Update 0.35.0 - [iOS Version History](https://github.com/BranchMetrics/ios-branch-deep-linking-attribution/releases)

###BREAKING CHANGES
 
Add KEY ```branch_check_apple_ads``` in INFO.PLIST  to enable checking for Apple Search Ads before Branch initialization

## 1.0.0
* Documentation Update
* Remove Android dependencies fallback.
* Require Flutter SDK 1.12.13+hotfix.5 or greater.

## 0.5.0
* Added new method trackContentWithoutBuo
* Added new currency values for BranchContentMetaData
* Added the campaign parameter in the BranchLinkProperties constructor

## 0.4.0
* Updated minimum Android Branch SDK version to 5.x.x
* Updated minimum iOS Branch SDK version to 0.32.0.<br/>
  **Note**: Branch SDK 0.32.0 requires at least **iOS 9.0**. Update the minimum version in the project, in the section **"Deployment Info" -> "Target"**.

## 0.3.1
* Fix error when index mode in BranchUniversalObject is not populated

## 0.3.0
* Fix handled by Branch links
* Improve attribution for Apple Search Ads
* Documentation Update

## 0.2.0
* Add Referral System Rewarding Functionality

## 0.1.5
* Bugfix Branch SDK initialization

## 0.1.4
* Bugfix BranchUniversalObject with keywords empty
* Documentation update

## 0.1.3
* Updated Android dependencies: From play-services-appindexing to firebase-appindexing

## 0.1.2
* Compatibility with apps built on earlier versions of Flutter 1.12
* Improved error handling in initSession

## 0.1.1
* Minor adjustments and fix initial deep link data loss

## 0.0.1+1
* Pubspec.yaml Update

## 0.0.1
* Initial version
