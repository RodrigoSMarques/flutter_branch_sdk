import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'flutter_branch_sdk_platform_interface.dart';
import 'objects/app_tracking_transparency.dart';
import 'objects/branch_universal_object.dart';

/// An implementation of [FlutterBranchSdkPlatform] that uses method channels.
class FlutterBranchSdkMethodChannel implements FlutterBranchSdkPlatform {
  static const MESSAGE_CHANNEL = 'flutter_branch_sdk/message';
  static const EVENT_CHANNEL = 'flutter_branch_sdk/event';

  /// The method channel used to interact with the native platform.
  final messageChannel = const MethodChannel(MESSAGE_CHANNEL);
  final eventChannel = const EventChannel(EVENT_CHANNEL);

  static Stream<Map<dynamic, dynamic>>? _initSessionStream;

  ///Identifies the current user to the Branch API by supplying a unique identifier as a userId value
  @override
  void setIdentity(String userId) {
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
    messageChannel.invokeMethod('logout');
  }

  ///Returns the last parameters associated with the link that referred the user
  @override
  Future<Map<dynamic, dynamic>> getLatestReferringParams() async {
    return await messageChannel.invokeMethod('getLatestReferringParams');
  }

  ///Returns the first parameters associated with the link that referred the user
  @override
  Future<Map<dynamic, dynamic>> getFirstReferringParams() async {
    return await messageChannel.invokeMethod('getFirstReferringParams');
  }

  ///Method to change the Tracking state. If disabled SDK will not track any user data or state.
  ///SDK will not send any network calls except for deep linking when tracking is disabled
  @override
  void disableTracking(bool value) async {
    messageChannel.invokeMethod('setTrackingDisabled', {'disable': value});
  }

  ///Initialises a session with the Branch API
  ///Listen click em Branch Deeplinks
  @override
  Stream<Map<dynamic, dynamic>> initSession() {
    _initSessionStream ??=
        eventChannel.receiveBroadcastStream().cast<Map<dynamic, dynamic>>();

    return _initSessionStream!;
  }

  ///Use the SDK integration validator to check that you've added the Branch SDK and
  ///handle deep links correctly when you first integrate Branch into your app.
  @override
  void validateSDKIntegration() {
    messageChannel.invokeMethod('validateSDKIntegration');
  }

  ///Creates a short url for the BUO
  @override
  Future<BranchResponse> getShortUrl(
      {required BranchUniversalObject buo,
      required BranchLinkProperties linkProperties}) async {
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
    if (branchEvent.toMap().isEmpty) {
      throw ArgumentError('branchEvent is required');
    }
    messageChannel
        .invokeMethod('trackContentWithoutBuo', {'event': branchEvent.toMap()});
  }

  ///Mark the content referred by this object as viewed. This increment the view count of the contents referred by this object.
  @override
  void registerView({required BranchUniversalObject buo}) {
    messageChannel.invokeMethod('registerView', {'buo': buo.toMap()});
  }

  ///For Android: Publish this BUO with Google app indexing so that the contents will be available with google search
  ///For iOS:     List items on Spotlight
  @override
  Future<bool> listOnSearch(
      {required BranchUniversalObject buo,
      BranchLinkProperties? linkProperties}) async {
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
    Map<String, dynamic> params = {};
    params['buo'] = buo.toMap();
    if (linkProperties != null && linkProperties.toMap().isNotEmpty) {
      params['lp'] = linkProperties.toMap();
    }
    return await messageChannel.invokeMethod('removeFromSearch', params);
  }

  ///Set time window for SKAdNetwork callouts in Hours (Only iOS)
  ///By default, Branch limits calls to SKAdNetwork to within 72 hours after first install.
  @override
  void setIOSSKAdNetworkMaxTime(int hours) {
    if (!Platform.isIOS) {
      return;
    }
    messageChannel
        .invokeMethod('setSKAdNetworkMaxTime', {'maxTimeInterval': hours});
  }

  ///Indicates whether or not this user has a custom identity specified for them. Note that this is independent of installs.
  ///If you call setIdentity, this device will have that identity associated with this user until logout is called.
  ///This includes persisting through uninstalls, as we track device id.
  @override
  Future<bool> isUserIdentified() async {
    return await messageChannel.invokeMethod('isUserIdentified');
  }

  /// request AppTracking Autorization and return AppTrackingStatus
  /// on Android returns notSupported
  @override
  Future<AppTrackingStatus> requestTrackingAuthorization() async {
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
    if (!Platform.isIOS) {
      return "";
    }
    final String uuid = (await messageChannel
        .invokeMethod<String>('getAdvertisingIdentifier'))!;
    return uuid;
  }

  @override
  void setConnectTimeout(int connectTimeout) {
    messageChannel
        .invokeMethod('setConnectTimeout', {'connectTimeout': connectTimeout});
  }

  @override
  void setRetryCount(int retryCount) {
    messageChannel.invokeMethod('setRetryCount', {'retryCount': retryCount});
  }

  @override
  void setRetryInterval(int retryInterval) {
    messageChannel
        .invokeMethod('setRetryInterval', {'retryInterval': retryInterval});
  }

  @override
  void setTimeout(int timeout) {
    messageChannel.invokeMethod('setTimeout', {'timeout': timeout});
  }

  @override
  Future<BranchResponse> getLastAttributedTouchData(
      {int? attributionWindow}) async {
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
    Map<String, dynamic> params = {};
    params['buo'] = buo.toMap();
    params['lp'] = linkProperties.toMap();
    params['messageText'] = title;
    params['iconData'] = icon;

    if (Platform.isIOS) {
      messageChannel.invokeMethod('shareWithLPLinkMetadata', params);
    } else {
      messageChannel.invokeMethod('showShareSheet', {params});
    }
  }
}
