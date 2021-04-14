import 'dart:io';

import 'package:flutter/services.dart';

import 'app_tracking_transparency.dart';
import 'flutter_branch_sdk_platform_interface.dart';

class FlutterBranchSdkMobile implements FlutterBranchSdkPlatform {
  static const _MESSAGE_CHANNEL = 'flutter_branch_sdk/message';
  static const _EVENT_CHANNEL = 'flutter_branch_sdk/event';

  static const MethodChannel _messageChannel =
      const MethodChannel(_MESSAGE_CHANNEL);

  static const EventChannel _eventChannel = const EventChannel(_EVENT_CHANNEL);

  static Stream<Map>? _initSessionStream;

  static FlutterBranchSdkMobile? _singleton;

  /// Constructs a singleton instance of [FlutterBranchSdkMobile].
  factory FlutterBranchSdkMobile() {
    if (_singleton == null) {
      _singleton = FlutterBranchSdkMobile._();
    }
    return _singleton!;
  }

  FlutterBranchSdkMobile._();

  ///Identifies the current user to the Branch API by supplying a unique identifier as a userId value

  @override
  void initWeb({required String branchKey}) {
    //nothing
  }

  ///Identifies the current user to the Branch API by supplying a unique identifier as a userId value
  @override
  void setIdentity(String userId) {
    Map<String, dynamic> _params = {};
    _params['userId'] = userId;
    _messageChannel.invokeMethod('setIdentity', _params);
  }

  ///Add key value pairs to all requests
  @override
  void setRequestMetadata(String key, String value) {
    Map<String, dynamic> _params = {};
    _params['key'] = key;
    _params['value'] = value;

    _messageChannel.invokeMethod('setRequestMetadata', _params);
  }

  ///This method should be called if you know that a different person is about to use the app
  @override
  void logout() {
    _messageChannel.invokeMethod('logout');
  }

  ///Returns the last parameters associated with the link that referred the user
  @override
  Future<Map<dynamic, dynamic>> getLatestReferringParams() async {
    return await _messageChannel.invokeMethod('getLatestReferringParams');
  }

  ///Returns the first parameters associated with the link that referred the user
  @override
  Future<Map<dynamic, dynamic>> getFirstReferringParams() async {
    return await _messageChannel.invokeMethod('getFirstReferringParams');
  }

  ///Method to change the Tracking state. If disabled SDK will not track any user data or state.
  ///SDK will not send any network calls except for deep linking when tracking is disabled
  @override
  void disableTracking(bool value) async {
    Map<String, dynamic> _params = {};
    _params['disable'] = value;
    _messageChannel.invokeMethod('setTrackingDisabled', _params);
  }

  ///Initialises a session with the Branch API
  ///Listen click em Branch Deeplinks
  @override
  Stream<Map<dynamic, dynamic>> initSession() {
    if (_initSessionStream == null)
      _initSessionStream =
          _eventChannel.receiveBroadcastStream().cast<Map<dynamic, dynamic>>();

    return _initSessionStream!;
  }

  ///Use the SDK integration validator to check that you've added the Branch SDK and
  ///handle deep links correctly when you first integrate Branch into your app.
  @override
  void validateSDKIntegration() {
    _messageChannel.invokeMethod('validateSDKIntegration');
  }

  ///Creates a short url for the BUO
  @override
  Future<BranchResponse> getShortUrl(
      {required BranchUniversalObject buo,
      required BranchLinkProperties linkProperties}) async {
    Map<String, dynamic> _params = {};
    _params['buo'] = buo.toMap();
    _params['lp'] = linkProperties.toMap();

    Map<dynamic, dynamic> response =
        await _messageChannel.invokeMethod('getShortUrl', _params);

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
    Map<String, dynamic> _params = {};
    _params['buo'] = buo.toMap();
    _params['lp'] = linkProperties.toMap();
    _params['messageText'] = messageText;
    _params['messageTitle'] = androidMessageTitle;
    _params['sharingTitle'] = androidSharingTitle;

    Map<dynamic, dynamic> response =
        await _messageChannel.invokeMethod('showShareSheet', _params);

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
      {required BranchUniversalObject buo, required BranchEvent branchEvent}) {
    Map<String, dynamic> _params = {};

    _params['buo'] = buo.toMap();
    if (branchEvent.toMap().isNotEmpty) {
      _params['event'] = branchEvent.toMap();
    }
    _messageChannel.invokeMethod('trackContent', _params);
  }

  ///Logs this BranchEvent to Branch for tracking and analytics
  @override
  void trackContentWithoutBuo({required BranchEvent branchEvent}) {
    Map<String, dynamic> _params = {};

    if (branchEvent.toMap().isEmpty) {
      throw ArgumentError('branchEvent is required');
    }
    _params['event'] = branchEvent.toMap();

    _messageChannel.invokeMethod('trackContentWithoutBuo', _params);
  }

  ///Mark the content referred by this object as viewed. This increment the view count of the contents referred by this object.
  @override
  void registerView({required BranchUniversalObject buo}) {
    Map<String, dynamic> _params = {};

    _params['buo'] = buo.toMap();

    _messageChannel.invokeMethod('registerView', _params);
  }

  ///For Android: Publish this BUO with Google app indexing so that the contents will be available with google search
  ///For iOS:     List items on Spotlight
  @override
  Future<bool> listOnSearch(
      {required BranchUniversalObject buo,
      BranchLinkProperties? linkProperties}) async {
    Map<String, dynamic> _params = {};

    _params['buo'] = buo.toMap();
    if (linkProperties != null && linkProperties.toMap().isNotEmpty) {
      _params['lp'] = linkProperties.toMap();
    }

    return await _messageChannel.invokeMethod('listOnSearch', _params);
  }

  ///For Android: Remove the BUO from the local indexing if it is added to the local indexing already
  ///             This will remove the content from Google(Firebase) and other supported Indexing services
  ///For iOS:     Remove Branch Universal Object from Spotlight if privately indexed
  @override
  Future<bool> removeFromSearch(
      {required BranchUniversalObject buo,
      BranchLinkProperties? linkProperties}) async {
    Map<String, dynamic> _params = {};
    _params['buo'] = buo.toMap();
    if (linkProperties != null && linkProperties.toMap().isNotEmpty) {
      _params['lp'] = linkProperties.toMap();
    }
    return await _messageChannel.invokeMethod('removeFromSearch', _params);
  }

  ///Retrieves rewards for the current user/session
  @override
  Future<BranchResponse> loadRewards({String bucket = 'default'}) async {
    Map<String, dynamic> _params = {};
    _params['bucket'] = bucket;

    Map<dynamic, dynamic> response =
        await _messageChannel.invokeMethod('loadRewards', _params);

    if (response['success']) {
      return BranchResponse.success(result: response['credits']);
    } else {
      return BranchResponse.error(
          errorCode: response['errorCode'],
          errorMessage: response['errorMessage']);
    }
  }

  ///Redeems the specified number of credits. if there are sufficient credits within it.
  ///If the number to redeem exceeds the number available in the bucket, all of the
  ///available credits will be redeemed instead.
  @override
  Future<BranchResponse> redeemRewards(
      {required int count, String bucket = 'default'}) async {
    Map<String, dynamic> _params = {};
    _params['count'] = count;
    _params['bucket'] = bucket;

    Map<dynamic, dynamic> response =
        await _messageChannel.invokeMethod('redeemRewards', _params);

    if (response['success']) {
      return BranchResponse.success(result: true);
    } else {
      return BranchResponse.error(
          errorCode: response['errorCode'],
          errorMessage: response['errorMessage']);
    }
  }

  ///Gets the credit history
  @override
  Future<BranchResponse> getCreditHistory({String bucket = 'default'}) async {
    Map<String, dynamic> _params = {};
    _params['bucket'] = bucket;

    Map<dynamic, dynamic> response =
        await _messageChannel.invokeMethod('getCreditHistory', _params);

    print('GetCreditHistory ${response.toString()}');

    if (response['success']) {
      return BranchResponse.success(result: response['data']['history']);
    } else {
      return BranchResponse.error(
          errorCode: response['errorCode'],
          errorMessage: response['errorMessage']);
    }
  }

  ///Set time window for SKAdNetwork callouts in Hours (Only iOS)
  ///By default, Branch limits calls to SKAdNetwork to within 72 hours after first install.
  @override
  void setIOSSKAdNetworkMaxTime(int hours) {
    if (!Platform.isIOS) {
      return;
    }

    Map<String, dynamic> _params = {};
    _params['maxTimeInterval'] = hours;
    _messageChannel.invokeMethod('setSKAdNetworkMaxTime', _params);
  }

  ///Indicates whether or not this user has a custom identity specified for them. Note that this is independent of installs.
  ///If you call setIdentity, this device will have that identity associated with this user until logout is called.
  ///This includes persisting through uninstalls, as we track device id.
  @override
  Future<bool> isUserIdentified() async {
    return await _messageChannel.invokeMethod('isUserIdentified');
  }

  /// request AppTracking Autorization and return AppTrackingStatus
  /// on Android returns notSupported
  @override
  Future<AppTrackingStatus> requestTrackingAuthorization() async {
    if (!Platform.isIOS) {
      return AppTrackingStatus.notSupported;
    }
    final int status = (await _messageChannel
        .invokeMethod<int>('requestTrackingAuthorization'))!;
    return AppTrackingStatus.values[status];
  }

  /// return AppTrackingStatus
  /// on Android returns notSupported
  @override
  Future<AppTrackingStatus> getTrackingAuthorizationStatus() async {
    if (!Platform.isIOS) {
      return AppTrackingStatus.notSupported;
    }
    final int status = (await _messageChannel
        .invokeMethod<int>('getTrackingAuthorizationStatus'))!;
    return AppTrackingStatus.values[status];
  }

  /// return advertising identifier (ie tracking data).
  /// on Android returns empty string
  @override
  Future<String> getAdvertisingIdentifier() async {
    if (!Platform.isIOS) {
      return "";
    }

    final String uuid = (await _messageChannel
        .invokeMethod<String>('getAdvertisingIdentifier'))!;
    return uuid;
  }
}
