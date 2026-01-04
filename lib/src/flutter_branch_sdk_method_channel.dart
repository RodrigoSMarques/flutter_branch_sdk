import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_branch_sdk/src/constants.dart';

import 'flutter_branch_sdk_platform_interface.dart';
import 'objects/app_tracking_transparency.dart';
import 'objects/branch_attribution_level.dart';
import 'objects/branch_log_level.dart';
import 'objects/branch_universal_object.dart';

/// An implementation of [FlutterBranchSdkPlatform] that uses method channels.
class FlutterBranchSdkMethodChannel implements FlutterBranchSdkPlatform {
  /// The method/event channels used to interact with the native platform.
  static const MethodChannel _messageChannel = MethodChannel(AppConstants.MESSAGE_CHANNEL);
  static const EventChannel _eventChannel = EventChannel(AppConstants.EVENT_CHANNEL);
  static const EventChannel _logEventChannel = EventChannel(AppConstants.LOG_CHANNEL);

  static Stream<Map<dynamic, dynamic>>? _initSessionStream;
  static var isInitialized = false;

  void _ensureInitialized(String methodName) {
    if (!isInitialized) {
      throw StateError('Call `FlutterBranchSdk.init()` before $methodName');
    }
  }
  /// Initializes the Branch SDK.
  ///
  /// This function initializes the Branch SDK with the specified configuration options.
  ///
  /// **Parameters:**
  ///
  /// - [enableLogging]: Whether to enable detailed logging. Defaults to `false`.
  /// - [logLevel]: The log level for Branch SDK logs. Defaults to `BranchLogLevel.VERBOSE`.
  /// - [branchAttributionLevel]: The level of attribution data to collect.
  ///   - `BranchAttributionLevel.FULL`: Full Attribution (Default)
  ///   - `BranchAttributionLevel.REDUCE`: Reduced Attribution (Non-Ads + Privacy Frameworks)
  ///   - `BranchAttributionLevel.MINIMAL`: Minimal Attribution - Analytics Only
  ///   - `BranchAttributionLevel.NONE`: No Attribution - No Analytics (GDPR, CCPA)
  ///
  @override
  Future<void> init({bool enableLogging = false, BranchLogLevel logLevel = BranchLogLevel.VERBOSE, BranchAttributionLevel? branchAttributionLevel}) async {
    if (isInitialized) {
      return;
    }
    var branchAttributionLevelString = '';

    if (branchAttributionLevel == null) {
      branchAttributionLevelString = '';
    } else {
      branchAttributionLevelString = getBranchAttributionLevelString(branchAttributionLevel);
    }
    await _messageChannel.invokeMethod('init', {
      'enableLogging': enableLogging,
      'logLevel': logLevel.value,
      'branchAttributionLevel': branchAttributionLevelString
    });
    isInitialized = true;
  }

  ///Identifies the current user to the Branch API by supplying a unique identifier as a userId value
  @override
  void setIdentity(String userId) {
    _ensureInitialized('setIdentity');
    _messageChannel.invokeMethod('setIdentity', {'userId': userId});
  }

  ///Add key value pairs to all requests
  @override
  void setRequestMetadata(String key, String value) {
    _messageChannel.invokeMethod('setRequestMetadata', {'key': key, 'value': value});
  }

  ///This method should be called if you know that a different person is about to use the app
  @override
  void logout() {
    _ensureInitialized('logout');
    _messageChannel.invokeMethod('logout');
  }

  ///Returns the last parameters associated with the link that referred the user
  @override
  Future<Map<dynamic, dynamic>> getLatestReferringParams() async {
    _ensureInitialized('getLatestReferringParams');
    return await _messageChannel.invokeMethod('getLatestReferringParams');
  }

  ///Returns the first parameters associated with the link that referred the user
  @override
  Future<Map<dynamic, dynamic>> getFirstReferringParams() async {
    _ensureInitialized('getFirstReferringParams');
    return await _messageChannel.invokeMethod('getFirstReferringParams');
  }

  ///Listen click em Branch DeepLinks
  @override
  Stream<Map<dynamic, dynamic>> listSession() {
    _ensureInitialized('listSession');
    _initSessionStream ??= _eventChannel.receiveBroadcastStream().cast<Map<dynamic, dynamic>>();

    return _initSessionStream!;
  }

  ///Use the SDK integration validator to check that you've added the Branch SDK and
  ///handle deep links correctly when you first integrate Branch into your app.
  @override
  void validateSDKIntegration() {
    _ensureInitialized('validateSDKIntegration');
    _messageChannel.invokeMethod('validateSDKIntegration');
  }

  ///Creates a short url for the BUO
  @override
  Future<BranchResponse> getShortUrl(
      {required BranchUniversalObject buo, required BranchLinkProperties linkProperties}) async {
    _ensureInitialized('getShortUrl');
    final Map<dynamic, dynamic> response =
      await _messageChannel.invokeMethod('getShortUrl', {'buo': buo.toMap(), 'lp': linkProperties.toMap()});

    if (response['success']) {
      return BranchResponse.success(result: response['url']);
    } else {
      return BranchResponse.error(errorCode: response['errorCode'], errorMessage: response['errorMessage']);
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
    _ensureInitialized('showShareSheet');
    final Map<dynamic, dynamic> response = await _messageChannel.invokeMethod('showShareSheet', {
      'buo': buo.toMap(),
      'lp': linkProperties.toMap(),
      'messageText': messageText,
      'messageTitle': androidMessageTitle,
      'sharingTitle': androidSharingTitle
    });

    if (response['success']) {
      return BranchResponse.success(result: response['url']);
    } else {
      return BranchResponse.error(errorCode: response['errorCode'], errorMessage: response['errorMessage']);
    }
  }

  ///Logs this BranchEvent to Branch for tracking and analytics
  @override
  void trackContent({required List<BranchUniversalObject> buo, required BranchEvent branchEvent}) {
    _ensureInitialized('trackContent');
    final Map<String, dynamic> params = {};
    params['buo'] = buo.map((b) => b.toMap()).toList();
    if (branchEvent.toMap().isNotEmpty) {
      params['event'] = branchEvent.toMap();
    }
    _messageChannel.invokeMethod('trackContent', params);
  }

  ///Logs this BranchEvent to Branch for tracking and analytics
  @override
  void trackContentWithoutBuo({required BranchEvent branchEvent}) {
    _ensureInitialized('trackContentWithoutBuo');
    if (branchEvent.toMap().isEmpty) {
      throw ArgumentError('branchEvent is required');
    }
    _messageChannel.invokeMethod('trackContentWithoutBuo', {'event': branchEvent.toMap()});
  }

  ///Mark the content referred by this object as viewed. This increment the view count of the contents referred by this object.
  @override
  void registerView({required BranchUniversalObject buo}) {
    _ensureInitialized('registerView');
    _messageChannel.invokeMethod('registerView', {'buo': buo.toMap()});
  }

  ///For Android: Publish this BUO with Google app indexing so that the contents will be available with google search
  ///For iOS:     List items on Spotlight
  @override
  Future<bool> listOnSearch({required BranchUniversalObject buo, BranchLinkProperties? linkProperties}) async {
    _ensureInitialized('listOnSearch');
    final Map<String, dynamic> params = {};
    params['buo'] = buo.toMap();
    if (linkProperties != null && linkProperties.toMap().isNotEmpty) {
      params['lp'] = linkProperties.toMap();
    }
    return await _messageChannel.invokeMethod('listOnSearch', params);
  }

  ///For Android: Remove the BUO from the local indexing if it is added to the local indexing already
  ///             This will remove the content from Google(Firebase) and other supported Indexing services
  ///For iOS:     Remove Branch Universal Object from Spotlight if privately indexed
  @override
  Future<bool> removeFromSearch({required BranchUniversalObject buo, BranchLinkProperties? linkProperties}) async {
    _ensureInitialized('removeFromSearch');
    final Map<String, dynamic> params = {};
    params['buo'] = buo.toMap();
    if (linkProperties != null && linkProperties.toMap().isNotEmpty) {
      params['lp'] = linkProperties.toMap();
    }
    return await _messageChannel.invokeMethod('removeFromSearch', params);
  }

  ///Indicates whether or not this user has a custom identity specified for them. Note that this is independent of installs.
  ///If you call setIdentity, this device will have that identity associated with this user until logout is called.
  ///This includes persisting through uninstalls, as we track device id.
  @override
  Future<bool> isUserIdentified() async {
    _ensureInitialized('isUserIdentified');
    return await _messageChannel.invokeMethod('isUserIdentified');
  }

  /// request AppTracking Autorization and return AppTrackingStatus
  /// on Android returns notSupported
  @override
  Future<AppTrackingStatus> requestTrackingAuthorization() async {
    _ensureInitialized('requestTrackingAuthorization');
    if (!Platform.isIOS) {
      return AppTrackingStatus.notSupported;
    }
    final int status = (await _messageChannel.invokeMethod<int>('requestTrackingAuthorization'))!;
    return AppTrackingStatus.values[status];
  }

  /// return AppTrackingStatus
  /// on Android returns notSupported
  @override
  Future<AppTrackingStatus> getTrackingAuthorizationStatus() async {
    _ensureInitialized('getTrackingAuthorizationStatus');
    if (!Platform.isIOS) {
      return AppTrackingStatus.notSupported;
    }
    final int status = (await _messageChannel.invokeMethod<int>('getTrackingAuthorizationStatus'))!;
    return AppTrackingStatus.values[status];
  }

  /// return advertising identifier (ie tracking data).
  /// on Android returns empty string
  @override
  Future<String> getAdvertisingIdentifier() async {
    _ensureInitialized('getAdvertisingIdentifier');
    if (!Platform.isIOS) {
      return '';
    }
    final String uuid = (await _messageChannel.invokeMethod<String>('getAdvertisingIdentifier'))!;
    return uuid;
  }

  @override
  void setConnectTimeout(int connectTimeout) {
    _ensureInitialized('setConnectTimeout');
    _messageChannel.invokeMethod('setConnectTimeout', {'connectTimeout': connectTimeout});
  }

  @override
  void setRetryCount(int retryCount) {
    _ensureInitialized('setRetryCount');
    _messageChannel.invokeMethod('setRetryCount', {'retryCount': retryCount});
  }

  @override
  void setRetryInterval(int retryInterval) {
    _ensureInitialized('setRetryInterval');
    _messageChannel.invokeMethod('setRetryInterval', {'retryInterval': retryInterval});
  }

  @override
  void setTimeout(int timeout) {
    _ensureInitialized('setTimeout');
    _messageChannel.invokeMethod('setTimeout', {'timeout': timeout});
  }

  @override
  Future<BranchResponse> getLastAttributedTouchData({int? attributionWindow}) async {
    _ensureInitialized('getLastAttributedTouchData');
    final Map<String, dynamic> params = {};
    if (attributionWindow != null) {
      params['attributionWindow'] = attributionWindow;
    }
    final Map<dynamic, dynamic> response = await _messageChannel.invokeMethod('getLastAttributedTouchData', params);
    if (response['success']) {
      final Map<dynamic, dynamic>? data = response['data'] as Map<dynamic, dynamic>?;
      final Map<dynamic, dynamic>? latd = data?['latd'] as Map<dynamic, dynamic>?;

      if (latd != null) {
        return BranchResponse.success(result: latd);
      } else {
        return BranchResponse.error(
          errorCode: '-1',
          errorMessage: 'Incomplete or null data',
        );
      }
    } else {
      return BranchResponse.error(errorCode: response['errorCode'], errorMessage: response['errorMessage']);
    }
  }

  ///Creates a Branch QR Code image. Returns the QR code as Uint8List.
  @override
  Future<BranchResponse> getQRCodeAsData(
      {required BranchUniversalObject buo,
      required BranchLinkProperties linkProperties,
      required BranchQrCode qrCodeSettings}) async {
    _ensureInitialized('getQRCodeAsData');
    final Map<dynamic, dynamic> response = await _messageChannel.invokeMethod(
      'getQRCode', {'buo': buo.toMap(), 'lp': linkProperties.toMap(), 'qrCodeSettings': qrCodeSettings.toMap()});

    if (response['success']) {
      return BranchResponse.success(result: response['result']);
    } else {
      return BranchResponse.error(errorCode: response['errorCode'], errorMessage: response['errorMessage']);
    }
  }

  ///Creates a Branch QR Code image. Returns the QR code as a Image.
  @override
  Future<BranchResponse> getQRCodeAsImage(
      {required BranchUniversalObject buo,
      required BranchLinkProperties linkProperties,
      required BranchQrCode qrCodeSettings}) async {
    _ensureInitialized('getQRCodeAsImage');
    final Map<dynamic, dynamic> response = await _messageChannel.invokeMethod(
      'getQRCode', {'buo': buo.toMap(), 'lp': linkProperties.toMap(), 'qrCodeSettings': qrCodeSettings.toMap()});

    if (response['success']) {
      return BranchResponse.success(result: Image.memory(response['result']));
    } else {
      return BranchResponse.error(errorCode: response['errorCode'], errorMessage: response['errorMessage']);
    }
  }

  ///Share with LPLinkMetadata on iOS
  @override
  Future<void> shareWithLPLinkMetadata(
      {required BranchUniversalObject buo,
      required BranchLinkProperties linkProperties,
      required Uint8List icon,
      required String title}) async {
    _ensureInitialized('shareWithLPLinkMetadata');
    final Map<String, dynamic> params = {};
    params['buo'] = buo.toMap();
    params['lp'] = linkProperties.toMap();
    params['messageText'] = title;
    params['iconData'] = icon;

    _messageChannel.invokeMethod('shareWithLPLinkMetadata', params);
  }

  ///Have Branch end the current deep link session and start a new session with the provided URL.
  @override
  Future<void> handleDeepLink(String url) async {
    _ensureInitialized('handleDeepLink');
    if (url.isEmpty) {
      throw ArgumentError('url is required');
    }
    _messageChannel.invokeMethod('handleDeepLink', {'url': url});
  }

  /// Add a Partner Parameter for Facebook.
  /// Once set, this parameter is attached to installs, opens and events until cleared or the app restarts.
  /// See Facebook's documentation for details on valid parameters
  @override
  void addFacebookPartnerParameter({required String key, required String value}) {
    _messageChannel.invokeMethod('addFacebookPartnerParameter', {'key': key, 'value': value});
  }

  /// Clears all Partner Parameters
  @override
  void clearPartnerParameters() {
    _messageChannel.invokeMethod('clearPartnerParameters');
  }

  /// Add the pre-install campaign analytics
  @override
  void setPreinstallCampaign(String value) {
    _messageChannel.invokeMethod('setPreinstallCampaign', {'value': value});
  }

  /// Add the pre-install campaign analytics
  @override
  void setPreinstallPartner(String value) {
    _messageChannel.invokeMethod('setPreinstallPartner', {'value': value});
  }

  ///Add a Partner Parameter for Snap.
  ///Once set, this parameter is attached to installs, opens and events until cleared or the app restarts.
  @override
  void addSnapPartnerParameter({required String key, required String value}) {
    _messageChannel.invokeMethod('addSnapPartnerParameter', {'key': key, 'value': value});
  }

  /// Sets the value of parameters required by Google Conversion APIs for DMA Compliance in EEA region.
  /// [eeaRegion] `true` If European regulations, including the DMA, apply to this user and conversion.
  /// [adPersonalizationConsent] `true` If End user has granted/denied ads personalization consent.
  /// [adUserDataUsageConsent] `true If User has granted/denied consent for 3P transmission of user level data for ads.
  @override
  void setDMAParamsForEEA(
      {required bool eeaRegion, required bool adPersonalizationConsent, required bool adUserDataUsageConsent}) {
    _messageChannel.invokeMethod('setDMAParamsForEEA', {
      'eeaRegion': eeaRegion,
      'adPersonalizationConsent': adPersonalizationConsent,
      'adUserDataUsageConsent': adUserDataUsageConsent
    });
  }

  /// Sets the consumer protection attribution level.
  @override
  void setConsumerProtectionAttributionLevel(BranchAttributionLevel branchAttributionLevel) {
    _messageChannel.invokeMethod('setConsumerProtectionAttributionLevel',
      {'branchAttributionLevel': getBranchAttributionLevelString(branchAttributionLevel)});
  }

  /// Sets a custom Meta Anon ID for the current user.
  /// [anonID] The custom Meta Anon ID to be used by Branch.
  /// Only for iOS.
  @override
  void setAnonID(String anonId) {
    if (!Platform.isIOS) {
      return;
    }
    _messageChannel.invokeMethod('setAnonID', {'anonId': anonId});
  }

  /// Set the SDK wait time for third party APIs (for fetching ODM info and Apple Attribution Token) to finish
  /// This timeout should be > 0 and <= 10 seconds.
  /// [waitTime] Number of seconds before third party API calls are considered timed out. Default is 0.5 seconds (500ms).
  /// Only for iOS.
  @override
  void setSDKWaitTimeForThirdPartyAPIs(double waitTime) {
    if (!Platform.isIOS) {
      return;
    }
    _messageChannel.invokeMethod('setSDKWaitTimeForThirdPartyAPIs', {'waitTime': waitTime});
  }

  /// A broadcast [Stream] that provides log messages emitted by the host platform (iOS/Android).
  /// It subscribes to the [EventChannel] and transforms raw platform data into
  /// [String] format for unified visibility in the Flutter debug console.  @override
  @override
  Stream<String> get platformLogs {
    return _logEventChannel.receiveBroadcastStream().map((logData) => logData.toString());
  }
}
