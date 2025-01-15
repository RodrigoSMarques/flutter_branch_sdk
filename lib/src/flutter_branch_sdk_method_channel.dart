import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_branch_sdk/src/constants.dart';

import 'flutter_branch_sdk_platform_interface.dart';
import 'objects/app_tracking_transparency.dart';
import 'objects/branch_attribution_level.dart';
import 'objects/branch_universal_object.dart';

/// An implementation of [FlutterBranchSdkPlatform] that uses method channels.
class FlutterBranchSdkMethodChannel implements FlutterBranchSdkPlatform {
  /// The method channel used to interact with the native platform.
  final messageChannel = const MethodChannel(AppConstants.MESSAGE_CHANNEL);
  final eventChannel = const EventChannel(AppConstants.EVENT_CHANNEL);

  static Stream<Map<dynamic, dynamic>>? _initSessionStream;
  static bool isInitialized = false;

  /// Initializes the Branch SDK.
  ///
  /// This function initializes the Branch SDK with the specified configuration options.
  ///
  /// **Parameters:**
  ///
  /// - [enableLogging]: Whether to enable detailed logging. Defaults to `false`.
  /// - [branchAttributionLevel]: The level of attribution data to collect.
  ///   - `BranchAttributionLevel.FULL`: Full Attribution (Default)
  ///   - `BranchAttributionLevel.REDUCE`: Reduced Attribution (Non-Ads + Privacy Frameworks)
  ///   - `BranchAttributionLevel.MINIMAL`: Minimal Attribution - Analytics Only
  ///   - `BranchAttributionLevel.NONE`: No Attribution - No Analytics (GDPR, CCPA)
  ///
  /// **Note:** The `disableTracking` parameter is deprecated and should no longer be used.
  /// Please use `branchAttributionLevel` to control tracking behavior.
  ///
  @override
  Future<void> init(
      {bool enableLogging = false,
      @Deprecated('use BranchAttributionLevel') bool disableTracking = false,
      BranchAttributionLevel? branchAttributionLevel}) async {
    if (isInitialized) {
      return;
    }
    var branchAttributionLevelString = '';

    if (branchAttributionLevel == null) {
      branchAttributionLevelString = '';
    } else {
      branchAttributionLevelString =
          getBranchAttributionLevelString(branchAttributionLevel);
    }
    await messageChannel.invokeMethod('init', {
      'enableLogging': enableLogging,
      'disableTracking': disableTracking,
      'branchAttributionLevel': branchAttributionLevelString
    });
    isInitialized = true;
  }

  ///Identifies the current user to the Branch API by supplying a unique identifier as a userId value
  @override
  void setIdentity(String userId) {
    assert(isInitialized,
        'Call `setIdentity` after `FlutterBranchSdk.init()` method');
    messageChannel.invokeMethod('setIdentity', {'userId': userId});
  }

  ///Add key value pairs to all requests
  @override
  void setRequestMetadata(String key, String value) {
    messageChannel
        .invokeMethod('setRequestMetadata', {'key': key, 'value': value});
  }

  ///This method should be called if you know that a different person is about to use the app
  @override
  void logout() {
    assert(
        isInitialized, 'Call `logout` after `FlutterBranchSdk.init()` method');
    messageChannel.invokeMethod('logout');
  }

  ///Returns the last parameters associated with the link that referred the user
  @override
  Future<Map<dynamic, dynamic>> getLatestReferringParams() async {
    assert(isInitialized,
        'Call `getLatestReferringParams` after `FlutterBranchSdk.init()` method');
    return await messageChannel.invokeMethod('getLatestReferringParams');
  }

  ///Returns the first parameters associated with the link that referred the user
  @override
  Future<Map<dynamic, dynamic>> getFirstReferringParams() async {
    assert(isInitialized,
        'Call `getFirstReferringParams` after `FlutterBranchSdk.init()` method');
    return await messageChannel.invokeMethod('getFirstReferringParams');
  }

  ///Method to change the Tracking state. If disabled SDK will not track any user data or state.
  ///SDK will not send any network calls except for deep linking when tracking is disabled
  @Deprecated('Use [setConsumerProtectionAttributionLevel]')
  @override
  void disableTracking(bool value) async {
    assert(isInitialized,
        'Call `disableTracking` after `FlutterBranchSdk.init()` method');
    messageChannel.invokeMethod('setTrackingDisabled', {'disable': value});
  }

  ///Listen click em Branch DeepLinks
  @override
  Stream<Map<dynamic, dynamic>> listSession() {
    assert(isInitialized,
        'Call `listSession` after `FlutterBranchSdk.init()` method');
    _initSessionStream ??=
        eventChannel.receiveBroadcastStream().cast<Map<dynamic, dynamic>>();

    return _initSessionStream!;
  }

  ///Use the SDK integration validator to check that you've added the Branch SDK and
  ///handle deep links correctly when you first integrate Branch into your app.
  @override
  void validateSDKIntegration() {
    assert(isInitialized,
        'Call `validateSDKIntegration` after `FlutterBranchSdk.init()` method');
    messageChannel.invokeMethod('validateSDKIntegration');
  }

  ///Creates a short url for the BUO
  @override
  Future<BranchResponse> getShortUrl(
      {required BranchUniversalObject buo,
      required BranchLinkProperties linkProperties}) async {
    assert(isInitialized,
        'Call `getShortUrl` after `FlutterBranchSdk.init()` method');
    Map<dynamic, dynamic> response = await messageChannel.invokeMethod(
        'getShortUrl', {'buo': buo.toMap(), 'lp': linkProperties.toMap()});

    if (response['success']) {
      return BranchResponse.success(result: response['url']);
    } else {
      return BranchResponse.error(
          errorCode: response['errorCode'],
          errorMessage: response['errorMessage']);
    }
  }

  ///Showing a Share Sheet
  @override
  Future<BranchResponse> showShareSheet(
      {required BranchUniversalObject buo,
      required BranchLinkProperties linkProperties,
      required String messageText,
      String androidMessageTitle = '',
      String androidSharingTitle = ''}) async {
    assert(isInitialized,
        'Call `showShareSheet` after `FlutterBranchSdk.init()` method');
    Map<dynamic, dynamic> response =
        await messageChannel.invokeMethod('showShareSheet', {
      'buo': buo.toMap(),
      'lp': linkProperties.toMap(),
      'messageText': messageText,
      'messageTitle': androidMessageTitle,
      'sharingTitle': androidSharingTitle
    });

    if (response['success']) {
      return BranchResponse.success(result: response['url']);
    } else {
      return BranchResponse.error(
          errorCode: response['errorCode'],
          errorMessage: response['errorMessage']);
    }
  }

  ///Logs this BranchEvent to Branch for tracking and analytics
  @override
  void trackContent(
      {required List<BranchUniversalObject> buo,
      required BranchEvent branchEvent}) {
    assert(isInitialized,
        'Call `trackContent` after `FlutterBranchSdk.init()` method');
    Map<String, dynamic> params = {};
    params['buo'] = buo.map((b) => b.toMap()).toList();
    if (branchEvent.toMap().isNotEmpty) {
      params['event'] = branchEvent.toMap();
    }
    messageChannel.invokeMethod('trackContent', params);
  }

  ///Logs this BranchEvent to Branch for tracking and analytics
  @override
  void trackContentWithoutBuo({required BranchEvent branchEvent}) {
    assert(isInitialized,
        'Call `trackContentWithoutBuo` after `FlutterBranchSdk.init()` method');
    if (branchEvent.toMap().isEmpty) {
      throw ArgumentError('branchEvent is required');
    }
    messageChannel
        .invokeMethod('trackContentWithoutBuo', {'event': branchEvent.toMap()});
  }

  ///Mark the content referred by this object as viewed. This increment the view count of the contents referred by this object.
  @override
  void registerView({required BranchUniversalObject buo}) {
    assert(isInitialized,
        'Call `registerView` after `FlutterBranchSdk.init()` method');
    messageChannel.invokeMethod('registerView', {'buo': buo.toMap()});
  }

  ///For Android: Publish this BUO with Google app indexing so that the contents will be available with google search
  ///For iOS:     List items on Spotlight
  @override
  Future<bool> listOnSearch(
      {required BranchUniversalObject buo,
      BranchLinkProperties? linkProperties}) async {
    assert(isInitialized,
        'Call `listOnSearch` after `FlutterBranchSdk.init()` method');
    Map<String, dynamic> params = {};
    params['buo'] = buo.toMap();
    if (linkProperties != null && linkProperties.toMap().isNotEmpty) {
      params['lp'] = linkProperties.toMap();
    }
    return await messageChannel.invokeMethod('listOnSearch', params);
  }

  ///For Android: Remove the BUO from the local indexing if it is added to the local indexing already
  ///             This will remove the content from Google(Firebase) and other supported Indexing services
  ///For iOS:     Remove Branch Universal Object from Spotlight if privately indexed
  @override
  Future<bool> removeFromSearch(
      {required BranchUniversalObject buo,
      BranchLinkProperties? linkProperties}) async {
    assert(isInitialized,
        'Call `removeFromSearch` after `FlutterBranchSdk.init()` method');
    Map<String, dynamic> params = {};
    params['buo'] = buo.toMap();
    if (linkProperties != null && linkProperties.toMap().isNotEmpty) {
      params['lp'] = linkProperties.toMap();
    }
    return await messageChannel.invokeMethod('removeFromSearch', params);
  }

  ///Indicates whether or not this user has a custom identity specified for them. Note that this is independent of installs.
  ///If you call setIdentity, this device will have that identity associated with this user until logout is called.
  ///This includes persisting through uninstalls, as we track device id.
  @override
  Future<bool> isUserIdentified() async {
    assert(isInitialized,
        'Call `isUserIdentified` after `FlutterBranchSdk.init()` method');
    return await messageChannel.invokeMethod('isUserIdentified');
  }

  /// request AppTracking Autorization and return AppTrackingStatus
  /// on Android returns notSupported
  @override
  Future<AppTrackingStatus> requestTrackingAuthorization() async {
    assert(isInitialized,
        'Call `requestTrackingAuthorization` after `FlutterBranchSdk.init()` method');
    if (!Platform.isIOS) {
      return AppTrackingStatus.notSupported;
    }
    final int status = (await messageChannel
        .invokeMethod<int>('requestTrackingAuthorization'))!;
    return AppTrackingStatus.values[status];
  }

  /// return AppTrackingStatus
  /// on Android returns notSupported
  @override
  Future<AppTrackingStatus> getTrackingAuthorizationStatus() async {
    assert(isInitialized,
        'Call `getTrackingAuthorizationStatus` after `FlutterBranchSdk.init()` method');
    if (!Platform.isIOS) {
      return AppTrackingStatus.notSupported;
    }
    final int status = (await messageChannel
        .invokeMethod<int>('getTrackingAuthorizationStatus'))!;
    return AppTrackingStatus.values[status];
  }

  /// return advertising identifier (ie tracking data).
  /// on Android returns empty string
  @override
  Future<String> getAdvertisingIdentifier() async {
    assert(isInitialized,
        'Call `getAdvertisingIdentifier` after `FlutterBranchSdk.init()` method');
    if (!Platform.isIOS) {
      return "";
    }
    final String uuid = (await messageChannel
        .invokeMethod<String>('getAdvertisingIdentifier'))!;
    return uuid;
  }

  @override
  void setConnectTimeout(int connectTimeout) {
    assert(isInitialized,
        'Call `setConnectTimeout` after `FlutterBranchSdk.init()` method');
    messageChannel
        .invokeMethod('setConnectTimeout', {'connectTimeout': connectTimeout});
  }

  @override
  void setRetryCount(int retryCount) {
    assert(isInitialized,
        'Call `setRetryCount` after `FlutterBranchSdk.init()` method');
    messageChannel.invokeMethod('setRetryCount', {'retryCount': retryCount});
  }

  @override
  void setRetryInterval(int retryInterval) {
    assert(isInitialized,
        'Call `setRetryInterval` after `FlutterBranchSdk.init()` method');
    messageChannel
        .invokeMethod('setRetryInterval', {'retryInterval': retryInterval});
  }

  @override
  void setTimeout(int timeout) {
    assert(isInitialized,
        'Call `setTimeout` after `FlutterBranchSdk.init()` method');
    messageChannel.invokeMethod('setTimeout', {'timeout': timeout});
  }

  @override
  Future<BranchResponse> getLastAttributedTouchData(
      {int? attributionWindow}) async {
    assert(isInitialized,
        'Call `getLastAttributedTouchData` after `FlutterBranchSdk.init()` method');
    Map<String, dynamic> params = {};
    if (attributionWindow != null) {
      params['attributionWindow'] = attributionWindow;
    }
    Map<dynamic, dynamic> response =
        await messageChannel.invokeMethod('getLastAttributedTouchData', params);
    if (response['success']) {
      return BranchResponse.success(result: response['data']['latd']);
    } else {
      return BranchResponse.error(
          errorCode: response['errorCode'],
          errorMessage: response['errorMessage']);
    }
  }

  ///Creates a Branch QR Code image. Returns the QR code as Uint8List.
  @override
  Future<BranchResponse> getQRCodeAsData(
      {required BranchUniversalObject buo,
      required BranchLinkProperties linkProperties,
      required BranchQrCode qrCodeSettings}) async {
    assert(isInitialized,
        'Call `getQRCodeAsData` after `FlutterBranchSdk.init()` method');
    Map<dynamic, dynamic> response =
        await messageChannel.invokeMethod('getQRCode', {
      'buo': buo.toMap(),
      'lp': linkProperties.toMap(),
      'qrCodeSettings': qrCodeSettings.toMap()
    });

    if (response['success']) {
      return BranchResponse.success(result: response['result']);
    } else {
      return BranchResponse.error(
          errorCode: response['errorCode'],
          errorMessage: response['errorMessage']);
    }
  }

  ///Creates a Branch QR Code image. Returns the QR code as a Image.
  @override
  Future<BranchResponse> getQRCodeAsImage(
      {required BranchUniversalObject buo,
      required BranchLinkProperties linkProperties,
      required BranchQrCode qrCodeSettings}) async {
    assert(isInitialized,
        'Call `getQRCodeAsImage` after `FlutterBranchSdk.init()` method');
    Map<dynamic, dynamic> response =
        await messageChannel.invokeMethod('getQRCode', {
      'buo': buo.toMap(),
      'lp': linkProperties.toMap(),
      'qrCodeSettings': qrCodeSettings.toMap()
    });

    if (response['success']) {
      return BranchResponse.success(result: Image.memory(response['result']));
    } else {
      return BranchResponse.error(
          errorCode: response['errorCode'],
          errorMessage: response['errorMessage']);
    }
  }

  ///Share with LPLinkMetadata on iOS
  @override
  void shareWithLPLinkMetadata(
      {required BranchUniversalObject buo,
      required BranchLinkProperties linkProperties,
      required Uint8List icon,
      required String title}) async {
    assert(isInitialized,
        'Call `shareWithLPLinkMetadata` after `FlutterBranchSdk.init()` method');
    Map<String, dynamic> params = {};
    params['buo'] = buo.toMap();
    params['lp'] = linkProperties.toMap();
    params['messageText'] = title;
    params['iconData'] = icon;

    messageChannel.invokeMethod('shareWithLPLinkMetadata', params);
  }

  ///Have Branch end the current deep link session and start a new session with the provided URL.
  @override
  void handleDeepLink(String url) {
    assert(isInitialized,
        'Call `handleDeepLink` after `FlutterBranchSdk.init()` method');
    if (url.isEmpty) {
      throw ArgumentError('url is required');
    }
    messageChannel.invokeMethod('handleDeepLink', {'url': url});
  }

  /// Add a Partner Parameter for Facebook.
  /// Once set, this parameter is attached to installs, opens and events until cleared or the app restarts.
  /// See Facebook's documentation for details on valid parameters
  @override
  void addFacebookPartnerParameter(
      {required String key, required String value}) {
    messageChannel.invokeMethod(
        'addFacebookPartnerParameter', {'key': key, 'value': value});
  }

  /// Clears all Partner Parameters
  @override
  void clearPartnerParameters() {
    messageChannel.invokeMethod('clearPartnerParameters');
  }

  /// Add the pre-install campaign analytics
  @override
  void setPreinstallCampaign(String value) {
    messageChannel.invokeMethod('setPreinstallCampaign', {'value': value});
  }

  /// Add the pre-install campaign analytics
  @override
  void setPreinstallPartner(String value) {
    messageChannel.invokeMethod('setPreinstallPartner', {'value': value});
  }

  ///Add a Partner Parameter for Snap.
  ///Once set, this parameter is attached to installs, opens and events until cleared or the app restarts.
  @override
  void addSnapPartnerParameter({required String key, required String value}) {
    messageChannel
        .invokeMethod('addSnapPartnerParameter', {'key': key, 'value': value});
  }

  /// Sets the value of parameters required by Google Conversion APIs for DMA Compliance in EEA region.
  /// [eeaRegion] `true` If European regulations, including the DMA, apply to this user and conversion.
  /// [adPersonalizationConsent] `true` If End user has granted/denied ads personalization consent.
  /// [adUserDataUsageConsent] `true If User has granted/denied consent for 3P transmission of user level data for ads.
  @override
  void setDMAParamsForEEA(
      {required bool eeaRegion,
      required bool adPersonalizationConsent,
      required bool adUserDataUsageConsent}) {
    messageChannel.invokeMethod('setDMAParamsForEEA', {
      'eeaRegion': eeaRegion,
      'adPersonalizationConsent': adPersonalizationConsent,
      'adUserDataUsageConsent': adUserDataUsageConsent
    });
  }

  /// Sets the consumer protection attribution level.
  @override
  void setConsumerProtectionAttributionLevel(
      BranchAttributionLevel branchAttributionLevel) {
    messageChannel.invokeMethod('setConsumerProtectionAttributionLevel', {
      'branchAttributionLevel':
          getBranchAttributionLevelString(branchAttributionLevel)
    });
  }
}
