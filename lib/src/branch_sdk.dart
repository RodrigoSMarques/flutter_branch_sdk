part of flutter_branch_sdk;

class FlutterBranchSdk {
  static const _MESSAGE_CHANNEL = 'flutter_branch_sdk/message';
  static const _EVENT_CHANNEL = 'flutter_branch_sdk/event';

  static const MethodChannel _messageChannel =
      const MethodChannel(_MESSAGE_CHANNEL);
  static const EventChannel _eventChannel = const EventChannel(_EVENT_CHANNEL);

  static Stream<Map>? _initSessionStream;

  static FlutterBranchSdk? _singleton;

  /// Constructs a singleton instance of [FlutterBranchSdk].
  factory FlutterBranchSdk() {
    if (_singleton == null) {
      _singleton = FlutterBranchSdk._();
    }
    return _singleton!;
  }

  FlutterBranchSdk._();

  ///Identifies the current user to the Branch API by supplying a unique identifier as a userId value
  static void setIdentity(String userId) {
    Map<String, dynamic> _params = {};
    _params['userId'] = userId;
    _messageChannel.invokeMethod('setIdentity', _params);
  }

  ///Add key value pairs to all requests
  static void setRequestMetadata(String key, String value) {
    Map<String, dynamic> _params = {};
    _params['key'] = key;
    _params['value'] = value;

    _messageChannel.invokeMethod('setRequestMetadata', _params);
  }

  ///This method should be called if you know that a different person is about to use the app
  static void logout() {
    _messageChannel.invokeMethod('logout');
  }

  ///Returns the last parameters associated with the link that referred the user
  static Future<Map<dynamic, dynamic>> getLatestReferringParams() async {
    return await _messageChannel.invokeMethod('getLatestReferringParams');
  }

  ///Returns the first parameters associated with the link that referred the user
  static Future<Map<dynamic, dynamic>> getFirstReferringParams() async {
    return await _messageChannel.invokeMethod('getFirstReferringParams');
  }

  ///Method to change the Tracking state. If disabled SDK will not track any user data or state.
  ///SDK will not send any network calls except for deep linking when tracking is disabled
  static void disableTracking(bool value) async {
    Map<String, dynamic> _params = {};
    _params['disable'] = value;
    _messageChannel.invokeMethod('setTrackingDisabled', _params);
  }

  ///Initialises a session with the Branch API
  ///Listen click em Branch Deeplinks
  static Stream<Map<dynamic, dynamic>> initSession() {
    if (_initSessionStream == null)
      _initSessionStream =
          _eventChannel.receiveBroadcastStream().cast<Map<dynamic, dynamic>>();

    return _initSessionStream!;
  }

  ///Use the SDK integration validator to check that you've added the Branch SDK and
  ///handle deep links correctly when you first integrate Branch into your app.
  static void validateSDKIntegration() {
    _messageChannel.invokeMethod('validateSDKIntegration');
  }

  ///Creates a short url for the BUO
  static Future<BranchResponse> getShortUrl(
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
  static Future<BranchResponse> showShareSheet(
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
  static void trackContent(
      {required BranchUniversalObject buo, required BranchEvent branchEvent}) {
    Map<String, dynamic> _params = {};

    _params['buo'] = buo.toMap();
    if (branchEvent.toMap().isNotEmpty) {
      _params['event'] = branchEvent.toMap();
    }
    _messageChannel.invokeMethod('trackContent', _params);
  }

  ///Logs this BranchEvent to Branch for tracking and analytics
  static void trackContentWithoutBuo({required BranchEvent branchEvent}) {
    Map<String, dynamic> _params = {};

    if (branchEvent.toMap().isEmpty) {
      throw ArgumentError('branchEvent is required');
    }
    _params['event'] = branchEvent.toMap();

    _messageChannel.invokeMethod('trackContentWithoutBuo', _params);
  }

  ///Mark the content referred by this object as viewed. This increment the view count of the contents referred by this object.
  static void registerView({required BranchUniversalObject buo}) {
    Map<String, dynamic> _params = {};

    _params['buo'] = buo.toMap();

    _messageChannel.invokeMethod('registerView', _params);
  }

  ///For Android: Publish this BUO with Google app indexing so that the contents will be available with google search
  ///For iOS:     List items on Spotlight
  static Future<bool> listOnSearch(
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
  static Future<bool> removeFromSearch(
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
  static Future<BranchResponse> loadRewards({String? bucket}) async {
    Map<String, dynamic> _params = {};
    if (bucket != null) _params['bucket'] = bucket;

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
  static Future<BranchResponse> redeemRewards(
      {required int count, String? bucket}) async {
    Map<String, dynamic> _params = {};
    _params['count'] = count;
    if (bucket != null) _params['bucket'] = bucket;

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
  static Future<BranchResponse> getCreditHistory({String? bucket}) async {
    Map<String, dynamic> _params = {};
    if (bucket != null) _params['bucket'] = bucket;

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
  static void setIOSSKAdNetworkMaxTime(int hours) {
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
  static Future<bool> isUserIdentified() async {
    return await _messageChannel.invokeMethod('isUserIdentified');
  }
}
