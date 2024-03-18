# Branch SDK Plugin

[![Branch](https://github.com/RodrigoSMarques/flutter_branch_sdk/blob/master/assets/branch.png?raw=true)](https://branch.io)

[![Plugin code analysis](https://github.com/RodrigoSMarques/flutter_branch_sdk/actions/workflows/ci.yaml/badge.svg?branch=master)](https://github.com/RodrigoSMarques/flutter_branch_sdk/actions/workflows/ci.yaml)

This is a Flutter plugin that implemented [Branch SDK](https://branch.io).

Branch.io helps mobile apps grow with deep links that power referral systems, sharing links and invites with full attribution and analytics.

Supports Android, iOS and Web.

* Android - Branch SDK Version >= 5.10.1 [Android Version History](https://github.com/BranchMetrics/android-branch-deep-linking-attribution/releases)
* iOS - Branch SDK Version >= 3.3.0 [iOS Version History](https://github.com/BranchMetrics/ios-branch-deep-linking-attribution/releases)

Implemented functions in plugin:

Function | Android | iOS | Web 
--- | --- | --- | --- |
Test Branch Integration | X | X | Not supported
Track users | X | X | X
Enable / Disable User Tracking | X | X | X
Get First and Last Parameters | X | X | X
Generate Deep Link for Branch Universal Object (BUO)| X | X | X
Show Share Sheet for Branch Universal Object (BUO)| X | X | X
List BUO on Search / Remove BUO from Search|  | X | 
Register view| X | X | X
Track User Actions and Events| X | X | X
Init Branch Session and Deep Link| X | X | X
Last Attributed Touch Data| X | X | X
QR codes| X | X | X
Share with LPLinkMetadata |  | X | 
Handle Links in Your Own App| X | X | X

## Getting Started
### Configure Branch Dashboard
* Register Your App
* Configure Branch Dashboard [Branch Dashboard](https://dashboard.branch.io/login)

For details see:

* [iOS: only section: **Configure Branch Dashboard**](https://help.branch.io/developers-hub/docs/ios-basic-integration#1-configure-branch-dashboard)
* [Android - only section: **Configure Branch Dashboard**](https://help.branch.io/developers-hub/docs/android-basic-integration#1-configure-branch-dashboard)

## Configure Platform Project
### Android Integration

Follow only the steps:

* [Configure App](https://help.branch.io/developers-hub/docs/android-basic-integration#4-configure-app)
* [Configure ProGuard](https://help.branch.io/developers-hub/docs/android-basic-integration#7-configure-proguard)

**Note**: It is not necessary to perform the Branch Android SDK installation steps. The plugin performs these steps.

### iOS Integration
Follow only the steps:

* [Configure bundle identifier](https://help.branch.io/developers-hub/docs/ios-basic-integration#2-configure-bundle-identifier)
* [Configure associated domains](https://help.branch.io/developers-hub/docs/ios-basic-integration#3-configure-associated-domains)
* [Configure Info.plist](https://help.branch.io/developers-hub/docs/ios-basic-integration#4-configure-infoplist)

**Note**: It is not necessary to perform the Branch iOS SDK installation steps. The plugin performs these steps.

#### NativeLink™ Deferred Deep Linking
Use iOS pasteboard to enable deferred deep linking via Branch NativeLink™, which enables 100% matching on iOS through Installs.

Follow the steps on the [page](https://help.branch.io/developers-hub/docs/ios-advanced-features#nativelink-deferred-deep-linking), session _**NativeLink™ Deferred Deep Linking**_,

**Note**: Code implementation in Swift is not necessary. The plugin already implements the code, requiring only configuration on the Dashboard.

### Web Integration

You need add Branch Javascript in your `web\index.html` at the top of your `<body>` tag, to be able to use this package.

```javascript
  <script>
    // load Branch
    (function(b,r,a,n,c,h,_,s,d,k){if(!b[n]||!b[n]._q){for(;s<_.length;)c(h,_[s++]);d=r.createElement(a);d.async=1;d.src="https://cdn.branch.io/branch-latest.min.js";k=r.getElementsByTagName(a)[0];k.parentNode.insertBefore(d,k);b[n]=h}})(window,document,"script","branch",function(b,r){b[r]=function(){b._q.push([r,arguments])}},{_q:[],_v:1},"addListener banner closeBanner closeJourney data deepview deepviewCta first init link logout removeListener setBranchViewData setIdentity track trackCommerceEvent logEvent disableTracking getBrowserFingerprintId crossPlatformIds lastAttributedTouchData setAPIResponseCallback qrCode setRequestMetaData setAPIUrl getAPIUrl setDMAParamsForEEA".split(" "), 0);
    // init Branch
    branch.init('key_live_or_test_YOUR_KEY_GOES_HERE');
  </script>
```
Change `key_live_or_test_YOUR_KEY_GOES_HERE ` to match your [Branch Dashboard](https://dashboard.branch.io/account-settings/app)

If `branch.init()` fails, all subsequent Branch methods will fail.

Full example `index.html`:

```html
<!DOCTYPE html>
<html>
<head>
  <!--
    If you are serving your web app in a path other than the root, change the
    href value below to reflect the base path you are serving from.

    The path provided below has to start and end with a slash "/" in order for
    it to work correctly.

    Fore more details:
    * https://developer.mozilla.org/en-US/docs/Web/HTML/Element/base
  -->
  <base href="/">

  <meta charset="UTF-8">
  <meta content="IE=Edge" http-equiv="X-UA-Compatible">
  <meta name="description" content="Demonstrates how to use the flutter_branch_sdk plugin.">

  <!-- iOS meta tags & icons -->
  <meta name="apple-mobile-web-app-capable" content="yes">
  <meta name="apple-mobile-web-app-status-bar-style" content="black">
  <meta name="apple-mobile-web-app-title" content="flutter_branch_sdk_example">
  <link rel="apple-touch-icon" href="icons/Icon-192.png">

  <!-- Favicon -->
  <link rel="icon" type="image/png" href="favicon.png"/>

  <title>flutter_branch_sdk_example</title>
  <link rel="manifest" href="manifest.json">
</head>
<body>
  <script>
    // load Branch
    (function(b,r,a,n,c,h,_,s,d,k){if(!b[n]||!b[n]._q){for(;s<_.length;)c(h,_[s++]);d=r.createElement(a);d.async=1;d.src="https://cdn.branch.io/branch-latest.min.js";k=r.getElementsByTagName(a)[0];k.parentNode.insertBefore(d,k);b[n]=h}})(window,document,"script","branch",function(b,r){b[r]=function(){b._q.push([r,arguments])}},{_q:[],_v:1},"addListener banner closeBanner closeJourney data deepview deepviewCta first init link logout removeListener setBranchViewData setIdentity track trackCommerceEvent logEvent disableTracking getBrowserFingerprintId crossPlatformIds lastAttributedTouchData setAPIResponseCallback qrCode setRequestMetaData setAPIUrl getAPIUrl setDMAParamsForEEA".split(" "), 0);
    // init Branch
    branch.init('key_live_or_test_YOUR_KEY_GOES_HERE');
  </script>
  <!-- This script installs service_worker.js to provide PWA functionality to
       application. For more information, see:
       https://developers.google.com/web/fundamentals/primers/service-workers -->
  <script>
    if ('serviceWorker' in navigator) {
      window.addEventListener('flutter-first-frame', function () {
        navigator.serviceWorker.register('flutter_service_worker.js');
      });
    }
  </script>
  <script src="main.dart.js" type="application/javascript"></script>
</body>
</html>

```

## Installation
To use the plugin, add `flutter_branch_sdk` as a [dependency in your pubspec.yaml file](https://pub.dev/packages/flutter_branch_sdk/install).

## How to use

### Initializing

To initialize Branch:

```dart
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';

await FlutterBranchSdk.init(
      useTestKey: false, enableLogging: false, disableTracking: false);
```

The optional parameters are:

- *useTestKey* : Sets `true` to use the test `key_test_....` .Default value: false
- *enableLogging* : Sets `true` turn on debug logging. Default value: false
- *disableTracking*: Sets `true` to disable tracking in Branch SDK for GDPR compliant on start. Default value: false

Initialization must be called from `main` or at any time, for example after getting consent for GPDR.

To guarantee the success of this function, ensure you've called the below in the app's main function

```dart
WidgetsFlutterBinding.ensureInitialized();
```

### Test Branch Integration
Test your Branch Integration by calling:

```dart
FlutterBranchSdk.validateSDKIntegration();
```

Check logs to make sure all the SDK Integration tests pass.

Example of log for Android:

```java
------------------- Initiating Branch integration verification --------------------------- ... 
1. Verifying Branch instance creation ... 
Passed
2. Checking Branch keys ... 
Passed
3. Verifying application package name ... 
Passed
4. Checking Android Manifest for URI based deep link config ... 
Passed
5. Verifying URI based deep link config with Branch dash board. ... 
Passed
6. Verifying intent for receiving URI scheme. ... 
Passed
7. Checking AndroidManifest for AppLink config. ... 
Passed
8. Verifying any supported custom link domains. ... 
Passed
9. Verifying default link domains integrations. ... 
Passed
10. Verifying alternate link domains integrations. ... 
Passed
Passed
--------------------------------------------
Successfully completed Branch integration validation. Everything looks good!
 
Great! Comment out the 'validateSDKIntegration' line in your app. Next check your deep link routing.
Append '?bnc_validate=true' to any of your app's Branch links and click it on your mobile device (not the Simulator!) to start the test.
For instance, to validate a link like:
https://<yourapp>.app.link/NdJ6nFzRbK
click on:
https://<yourapp>.app.link/NdJ6nFzRbK?bnc_validate=true
```
Make sure to comment out or remove `validateSDKIntegration` in your production build.

### Read deep link

To listen to the clicks on the deep link and retrieve the data it is necessary to add the code below:

```dart
    StreamSubscription<Map> streamSubscription = FlutterBranchSdk.listSession().listen((data)  {
      if (data.containsKey("+clicked_branch_link") &&
          data["+clicked_branch_link"] == true) {
         //Link clicked. Add logic to get link data
         print('Custom string: ${data["custom_string"]}');
      }
    }, onError: (error) {
		print('listSession error: ${error.toString()}');
    });
```

When a deep link is clicked the above method will be called, with the app is open or closed.

### Retrieve Install (Install Only) Parameters
If you ever want to access the original session params (the parameters passed in for the first install event only), you can use this line. This is useful if you only want to reward users who newly installed the app from a referral link.

```dart
    Map<dynamic, dynamic> params = await FlutterBranchSdk.getFirstReferringParams();
```

*Note: You must call this method on `iOS` to obtain installation data if the return of the `FlutterBranchSdk.listSession()` function is {+is_first_session: true, +clicked_branch_link: false}*

### Retrieve session (install or open) parameters

These session parameters will be available at any point later on with this command. If no parameters are available then Branch will return an empty dictionary. This refreshes with every new session (app installs AND app opens).

```dart
    Map<dynamic, dynamic> params = await FlutterBranchSdk.getLatestReferringParams();
```

### Retrieve Branch's Last Attributed Touch Data

Allow retrieval of our last attributed touch data (LATD) from the client. This results in an asynchronous call being made to Branch’s servers with LATD data returned when possible.

Last attributed touch data contains the information associated with that user's last viewed impression or clicked link.


```dart
BranchResponse response =
        await FlutterBranchSdk.getLastAttributedTouchData();
    if (response.success) {
      print(response.result.toString());
    }
```

More information [here](https://help.branch.io/developers-hub/docs/retrieving-branchs-last-attributed-touch-data).

### Create content reference (Branch Universal Object)
The Branch Universal Object encapsulates the thing you want to share.

```dart
    BranchUniversalObject buo = BranchUniversalObject(
      canonicalIdentifier: 'flutter/branch',
      //canonicalUrl: '',
      title: 'Flutter Branch Plugin',
      imageUrl: 'https://raw.githubusercontent.com/RodrigoSMarques/flutter_branch_sdk/master/assets/branch_logo_qrcode.jpeg',
      contentDescription: 'Flutter Branch Description',
      keywords: ['Plugin', 'Branch', 'Flutter'],
      publiclyIndex: true,
      locallyIndex: true,
      contentMetadata: BranchContentMetaData()..addCustomMetadata('custom_string', 'abc')
          ..addCustomMetadata('custom_number', 12345)
          ..addCustomMetadata('custom_bool', true)
          ..addCustomMetadata('custom_list_number', [1,2,3,4,5 ])
          ..addCustomMetadata('custom_list_string', ['a', 'b', 'c']),
    );
```

> parameter **canonicalUrl**: 
> If your content lives both on the web and in the app, make sure you set its canonical URL (i.e. the URL of this piece of content on the web) when building any BUO.
> By doing so, we’ll attribute clicks on the links that you generate back to their original web page, even if the user goes to the app instead of your website! This will help your SEO efforts.

More information about the parameters, verify [Android documentation](https://help.branch.io/developers-hub/docs/android-full-reference#parameters) and [iOS documentation](https://help.branch.io/developers-hub/docs/ios-full-reference#methods-and-properties) 

### Create link reference (BranchLinkProperties)
* Generates the analytical properties for the deep link.
* Used for Create deep link and Share deep link.

```dart
    BranchLinkProperties lp = BranchLinkProperties(
	   //alias: 'flutterplugin', //define link url,
        channel: 'facebook',
        feature: 'sharing',
        stage: 'new share',
        tags: ['one', 'two', 'three']
    );
    lp.addControlParam('url', 'http://www.google.com');
    lp.addControlParam('url2', 'http://flutter.dev');
```

> parameter **alias**:
> Instead of our standard encoded short url, you can specify the vanity alias.
> For example, instead of a random string of characters/integers, you can set the vanity alias as \*.app.link/devonaustin.
> Aliases are enforced to be unique and immutable per domain, and per link - they cannot be reused unless deleted.

More information about the parameters, verify [Android documentation](https://help.branch.io/developers-hub/docs/android-full-reference#creating-a-deep-link) and [iOS documentation](https://help.branch.io/developers-hub/docs/ios-full-reference#link-properties-parameters) 
 
### Create deep link
Generates a deep link within your app.

```dart
    BranchResponse response =
        await FlutterBranchSdk.getShortUrl(buo: buo, linkProperties: lp);
    if (response.success) {
      print('Link generated: ${response.result}');
    } else {
        print('Error : ${response.errorCode} - ${response.errorMessage}');
    }
```
### Show Share Sheet with deep link
Will generate a Branch deep link and tag it with the channel the user selects.
> Note: _For Android additional customization is possible_

```dart
    BranchResponse response = await FlutterBranchSdk.showShareSheet(
        buo: buo,
        linkProperties: lp,
        messageText: 'My Share text',
        androidMessageTitle: 'My Message Title',
        androidSharingTitle: 'My Share with');

    if (response.success) {
      print('showShareSheet Sucess');
    } else {
      print('Error : ${response.errorCode} - ${response.errorMessage}');
    }
```

### Show Share Sheet with LPLinkMetadata
> Note: _Requires iOS 13 or higher, else call showShareSheet `function`_

Will show Share Sheet with customization.

#### Parameters
1. Content - verify section [Create content reference](#Create-content-reference)

2. Link Reference - verify section [Create link reference](#Create-link-reference)

3. Title (String) - Title for Share Sheet

3. Icon (Uint8List) - Image for Share Sheet. Load image before from Web or assets.


```dart
      FlutterBranchSdk.shareWithLPLinkMetadata(
          buo: buo!,
          linkProperties: lp,
          title: "Share With LPLinkMetadata",
          icon: iconData);
```

### Create a QR Code

> **QR Code Access Required**
> 
> Access to Branch's QR Code API and SDK requires premium product access. 
> Please reach out to your account manager or [https://branch.io/pricing/](https://branch.io/pricing/) to activate.


Will generates a custom QR Code with a unique Branch link which you can deep link and track analytics with.

#### Parameters
1. Content - verify section [Create content reference](#create-content-reference)

2. Link Reference - verify section [Create link reference](#create-link-reference)

3. BranchQrCode object (QR Code settings)

Parameter | Type | Definition 
--- | --- | --- 
primaryColor | Color | Color name ou Hex color value
backgroundColor | Color | Color name ou Hex color value of the background of the QR code itself.
margin|Integer (Pixels)|The number of pixels you want for the margin. Min 1px. Max 20px.
width|Integer (Pixels)|Output size of QR Code image. Min 300px. Max 2000px. (Only applicable to JPEG/PNG)
imageFormat|BranchImageFormat|JPEG, PNG
centerLogoUrl|String (HTTP URL)|URL to the image you want as a center logo e.g. [https://raw.githubusercontent.com/RodrigoSMarques/flutter_branch_sdk/master/assets/branch_logo_qrcode.jpeg](https://raw.githubusercontent.com/RodrigoSMarques/flutter_branch_sdk/master/assets/branch_logo_qrcode.jpeg)

```dart
    BranchResponse responseQrCodeImage =
        await FlutterBranchSdk.getQRCodeAsImage(
            buo: buo!,
            linkProperties: lp,
            qrCode: BranchQrCode(
                primaryColor: Colors.black,
                //primaryColor: const Color(0xff443a49), //Hex colors
                centerLogoUrl: imageURL,
                backgroundColor: Colors.white,
                imageFormat: BranchImageFormat.PNG));

    if (response.success) {
      print('QrCode Success');
      showQrCode(this.context, responseQrCodeImage.result);
 		/*
        Image(
          image: responseQrCodeImage.result,
          height: 250,
          width: 250,
        ),
      */
    } else {
      print('Error : ${response.errorCode} - ${response.errorMessage}');

```

- Method `getQRCodeAsImage` returns the QR code as a Image.
- Method `getQRCodeAsData`  returns the QR code as Uint8List. Can be stored in a file or converted to image.

### Handle Links in Your Own App

Allows you to deep link into your own from your app itself

```dart
    FlutterBranchSdk.handleDeepLink(
        'https://flutterbranchsdk.test-app.link/sxz79EtAPub');
```

Replace *"https://flutterbranchsdk.test-app.link/sxz79EtAPub"* with your own link URL.

> Handling a new deep link in your app will clear the current session data and a new referred "open" will be attributed.

### List content on Search
* For iOs list BUO links in Spotlight
* For Android no action will be taken
* For WEB not supported


```dart
    bool success = await FlutterBranchSdk.listOnSearch(buo: buo);
    print(success);
```

### Remove content from Search
Privately indexed Branch Universal Object can be removed.

```dart
    bool success = await FlutterBranchSdk.removeFromSearch(buo: buo);
    print('Remove sucess: $success');
```

### Register Event VIEW_ITEM
Mark the content referred by this object as viewed. This increment the view count of the contents referred by this object.

```dart
FlutterBranchSdk.registerView(buo: buo);
```

### Tracking User Actions and Events
Use the `BranchEvent` interface to track special user actions or application specific events beyond app installs, opens, and sharing. You can track events such as when a user adds an item to an on-line shopping cart, or searches for a keyword, among others.
The `BranchEvent` interface provides an interface to add contents represented by `BranchUniversalObject` in order to associate app contents with events.
Analytics about your app's BranchEvents can be found on the Branch dashboard, and BranchEvents also provide tight integration with many third party analytics providers.

```dart
BranchEvent eventStandard = BranchEvent.standardEvent(BranchStandardEvent.ADD_TO_CART);
FlutterBranchSdk.trackContent(buo: [buo], branchEvent: eventStandard);
```
You can use your own custom event names too:

```dart
BranchEvent eventCustom = BranchEvent.customEvent('Custom_event');
FlutterBranchSdk.trackContent(buo: [buo], branchEvent: eventCustom);
```
Extra event specific data can be tracked with the event as well:

```dart
    eventStandard.transactionID = '12344555';
    eventStandard.currency = BranchCurrencyType.BRL;
    eventStandard.revenue = 1.5;
    eventStandard.shipping = 10.2;
    eventStandard.tax = 12.3;
    eventStandard.coupon = 'test_coupon';
    eventStandard.affiliation = 'test_affiliation';
    eventStandard.eventDescription = 'Event_description';
    eventStandard.searchQuery = 'item 123';
    eventStandard.adType = BranchEventAdType.BANNER;
    eventStandard.addCustomData('Custom_Event_Property_Key1', 'Custom_Event_Property_val1');
    eventStandard.addCustomData('Custom_Event_Property_Key2', 'Custom_Event_Property_val2');
    FlutterBranchSdk.trackContent(buo: [buo], branchEvent: eventStandard);
```

`trackContent` accepts a list of Branch Universal Object.

You can register logs in BranchEvent without Branch Universal Object (BUO) for tracking and analytics:

```dart
BranchEvent eventStandart = BranchEvent.standardEvent(BranchStandardEvent.ADD_TO_CART);
FlutterBranchSdk.trackContentWithoutBuo(branchEvent: eventStandart);
```

You can use your own custom event names too:

```dart
BranchEvent eventCustom = BranchEvent.customEvent('Custom_event');
FlutterBranchSdk.trackContentWithoutBuo(branchEvent: eventCustom);
```

### Track users
Sets the identity of a user (email, ID, UUID, etc) for events, deep links, and referrals.

```dart
//login
FlutterBranchSdk.setIdentity('user1234567890');
```
```dart
//logout
FlutterBranchSdk.logout();
```
```dart
//check if user is identify
 bool isUserIdentified = await FlutterBranchSdk.isUserIdentified();
```

### Enable or Disable User Tracking
If you need to comply with a user's request to not be tracked for GDPR purposes, or otherwise determine that a user should not be tracked, utilize this field to prevent Branch from sending network requests. This setting can also be enabled across all users for a particular link, or across your Branch links.

```dart
FlutterBranchSdk.disableTracking(false);
```
```dart
FlutterBranchSdk.disableTracking(true);
```
You can choose to call this throughout the lifecycle of the app. Once called, network requests will not be sent from the SDKs. Link generation will continue to work, but will not contain identifying information about the user. In addition, deep linking will continue to work, but will not track analytics for the user.

More information [here](https://help.branch.io/developers-hub/docs/honoring-opt-out-of-processing-requests)

### Set Request Meta data
Add key value pairs to all requests

```dart
FlutterBranchSdk.setRequestMetadata(requestMetadataKey, requestMetadataValue);
```

### iOS 14+ App Tracking Transparency
Starting with iOS 14.5, iPadOS 14.5, and tvOS 14.5, you’ll need to receive the user’s permission through the AppTrackingTransparency framework to track them or access their device’s advertising identifier. Tracking refers to the act of linking user or device data collected from your app with user or device data collected from other companies’ apps, websites, or offline properties for targeted advertising or advertising measurement purposes. Tracking also refers to sharing user or device data with data brokers.

See: [https://developer.apple.com/app-store/user-privacy-and-data-use/](https://developer.apple.com/app-store/user-privacy-and-data-use/)

New methods have been made available to deal with App Tracking Transparency.

First, update `Info.plist` file located in ios/Runner directory and add the `NSUserTrackingUsageDescription` key with a custom message describing your usage.

```swift
    <key>NSUserTrackingUsageDescription</key>
    <string>App would like to access IDFA for tracking purpose</string>
```

#### Show tracking authorization dialog and ask for permission

```dart
AppTrackingStatus status = await FlutterBranchSdk.requestTrackingAuthorization();
print(status);
```
> Note: After the user's response, call the `handleATTAuthorizationStatus` Branch SDK method to monitor the performance of the ATT prompt.

![App tracking dialog](https://github.com/RodrigoSMarques/flutter_branch_sdk/blob/master/assets/app_tracking_dialog.png)


#### Get tracking authorization status

```dart
AppTrackingStatus status = await FlutterBranchSdk.getTrackingAuthorizationStatus();
print(status);
```

##### Values available for AppTrackingStatus

```dart
enum AppTrackingStatus {
  /// The user has not yet received an authorization request dialog
  notDetermined,

  /// The device is restricted, tracking is disabled and the system can't show a request dialog
  restricted,

  /// The user denies authorization for tracking
  denied,

  /// The user authorizes access to tracking
  authorized,

  /// The platform is not iOS or the iOS version is below 14.0
  notSupported,
}

```

#### Get Device Advertising Identifier

```dart
AppTrackingStatus status = await FlutterBranchSdk.getTrackingAuthorizationStatus();
print(status);
```

See: [https://developer.apple.com/documentation/adsupport/asidentifiermanager/1614151-advertisingidentifier](https://developer.apple.com/documentation/adsupport/asidentifiermanager/1614151-advertisingidentifier)


### User Data
#### Google DMA Compliance

In response to the European Union's enactment of the Digital Markets Act (DMA), the Branch Android SDK includes the `setDMAParamsForEEA` method to help you pass consent information from your user to Google.

The `setDMAParamsForEEA` method takes 3 parameters:

```dart
    FlutterBranchSdk.setDMAParamsForEEA(eeaRegion: true, adPersonalizationConsent: false, adUserDataUsageConsent: false);
```

Parameter Name | Type | Description | When `true`| When `false` 
|---|---|---|---|---|
eeaRegion | Boolean | Whether European regulations, including the DMA, apply to this user and conversion | User is `included` in European Union regulations. For example, if the user is located within the EEA, they are within the scope of DMA | User is considered `excluded` from European Union regulations
adPersonalizationConsent | Boolean | Whether end user has `granted` or denied ads personalization | User has `granted`  consent for ads personalization. | User has denied consent for ads personalization.
adUserDataUsageConsent | Boolean | Whether end user has granted or denied consent for 3P transmission of user level data for ads. | User has `granted` consent for 3P transmission of user-level data for ads. | User has `denied`  consent for 3P transmission of user-level data for ads.

When parameters are successfully set using `setDMAParamsForEEA`, they will be sent along with every future request to the following Branch endpoint.


# Getting Started
See the `example` directory for a complete sample app using Branch SDK.

![Example app](https://github.com/RodrigoSMarques/flutter_branch_sdk/blob/master/assets/example.png)

See example in Flutter Web: [https://flutter-branch-sdk.netlify.app/](https://flutter-branch-sdk.netlify.app/#/)

# Branch Universal Object best practices

Here are a set of best practices to ensure that your analytics are correct, and your content is ranking on Spotlight effectively.

1. Set the canonicalIdentifier to a unique, de-duped value across instances of the app
2. Ensure that the title, contentDescription and imageUrl properly represent the object
3. Initialize the Branch Universal Object and call `FlutterBranchSdk.registerView(buo: buo);` on `initState()`
4. Call `showShareSheet` and `getShortUrl` later in the life cycle, when the user takes an action that needs a link
5. Call the additional object events (purchase, share completed, etc) when the corresponding user action is taken

Practices to avoid:

1. Don't set the same title, contentDescription and imageUrl across all objects.
2. Don't wait to initialize the object and register views until the user goes to share.
3. Don't wait to initialize the object until you conveniently need a link.
4. Don't create many objects at once and register views in a for loop.

# Deep links with Short Links
More information [here](https://help.branch.io/using-branch/docs/creating-a-deep-link#short-links)

# Deep links with Long links
More information [here](https://help.branch.io/using-branch/docs/creating-a-deep-link#long-links)

# Branch Documentation
Read the iOS or Android documentation for all Branch object parameters:

* Android - [https://help.branch.io/developers-hub/docs/android-advanced-features](https://help.branch.io/developers-hub/docs/android-advanced-features)
* iOS - [https://help.branch.io/developers-hub/docs/ios-advanced-features](https://help.branch.io/developers-hub/docs/ios-advanced-features)

# Author
This project was authored by Rodrigo S. Marques. You can contact me at [rodrigosmarques@gmail.com](mailto:rodrigosmarques@gmail.com)
 
