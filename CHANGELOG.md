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
