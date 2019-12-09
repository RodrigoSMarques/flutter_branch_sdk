part of flutter_branch_sdk;

class FlutterBranchSdk {
  static const _MESSAGE_CHANNEL = 'flutter_branch_sdk/message';
  static const _EVENT_CHANNEL = 'flutter_branch_sdk/event';

  static const MethodChannel _messageChannel =
      const MethodChannel(_MESSAGE_CHANNEL);
  static const EventChannel _eventChannel = const EventChannel(_EVENT_CHANNEL);

  static Stream<Map> initSessionStream;

  ///Identifies the current user to the Branch API by supplying a unique identifier as a userId value
  static void setIdentity(String userId) {
    if (userId == null) {
      throw ArgumentError('userId is required');
    }

    Map<String, dynamic> _params = {};
    _params['userId'] = userId;
    _messageChannel.invokeMethod('setIdentity', _params);
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
    if (value == null) {
      throw ArgumentError('value is required');
    }

    Map<String, dynamic> _params = {};
    _params['disable'] = value;
    _messageChannel.invokeMethod('setTrackingDisabled', _params);
  }

  ///Initialises a session with the Branch API
  ///Listen click em Branch Deeplinks
  static Stream<Map<dynamic, dynamic>> initSession() {
    if (initSessionStream == null)
      initSessionStream =
          _eventChannel.receiveBroadcastStream().cast<Map<dynamic, dynamic>>();

    return initSessionStream;
  }

  ///Use the SDK integration validator to check that you've added the Branch SDK and
  ///handle deep links correctly when you first integrate Branch into your app.
  static void validateSDKIntegration() {
    _messageChannel.invokeMethod('validateSDKIntegration');
  }

  ///Creates a short url for the BUO
  static Future<BranchResponse> getShortUrl(
      {@required BranchUniversalObject buo,
      @required BranchLinkProperties linkProperties}) async {
    if (buo == null) {
      throw ArgumentError('Branch Universal Object is required');
    }

    if (linkProperties == null) {
      throw ArgumentError('linkProperties is required');
    }

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
          errorDescription: response['errorDescription']);
    }
  }

  ///Showing a Share Sheet
  static Future<BranchResponse> showShareSheet(
      {@required BranchUniversalObject buo,
      @required BranchLinkProperties linkProperties,
      @required String messageText,
      String androidMessageTitle = '',
      String androidSharingTitle = ''}) async {
    if (buo == null) {
      throw ArgumentError('Branch Universal Object is required');
    }

    if (linkProperties == null) {
      throw ArgumentError('linkProperties is required');
    }

    if (messageText == null) {
      throw ArgumentError('shareText is required');
    }

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
          errorDescription: response['errorDescription']);
    }
  }

  static void trackContent(
      {@required BranchUniversalObject buo, BranchEvent branchEvent}) {
    if (buo == null) {
      throw ArgumentError('Branch Universal Object is required');
    }

    if (branchEvent == null) {
      throw ArgumentError('eventType is required');
    }

    Map<String, dynamic> _params = {};

    _params['buo'] = buo.toMap();
    if (branchEvent != null && branchEvent.toMap().isNotEmpty) {
      _params['event'] = branchEvent.toMap();
    }
    _messageChannel.invokeMethod('trackContent', _params);
  }

  ///Mark the content referred by this object as viewed. This increment the view count of the contents referred by this object.
  static void registerView({@required BranchUniversalObject buo}) {
    if (buo == null) {
      throw ArgumentError('Branch Universal Object is required');
    }

    Map<String, dynamic> _params = {};

    _params['buo'] = buo.toMap();

    _messageChannel.invokeMethod('registerView', _params);
  }

  ///For Android: Publish this BUO with Google app indexing so that the contents will be available with google search
  ///For iOS:     List items on Spotlight
  static Future<bool> listOnSearch(
      {@required BranchUniversalObject buo,
      BranchLinkProperties linkProperties}) async {
    if (buo == null) {
      throw ArgumentError('Branch Universal Object is required');
    }

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
      {@required BranchUniversalObject buo,
      BranchLinkProperties linkProperties}) async {
    if (buo == null) {
      throw ArgumentError('Branch Universal Object is required');
    }

    Map<String, dynamic> _params = {};
    _params['buo'] = buo.toMap();
    if (linkProperties != null && linkProperties.toMap().isNotEmpty) {
      _params['lp'] = linkProperties.toMap();
    }
    return await _messageChannel.invokeMethod('removeFromSearch', _params);
  }
}
