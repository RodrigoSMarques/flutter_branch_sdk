## 1.2.0
* Android: BugFix on ```onNewIntent```
* iOS:     new method: ```setRequestMetadata```
           new method: ```setIOSSKAdNetworkMaxTime```
## 1.1.0
Updated Native ```Android``` and ```iOS``` SDKs
* Android Native SDK Update 5.0.3 - [Android Version History](https://help.branch.io/developers-hub/docs/android-version-history)
* iOS Native SDK Update 0.35.0 - [iOS Version History](https://help.branch.io/developers-hub/docs/ios-version-history)

 __BREAKING CHANGES__
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