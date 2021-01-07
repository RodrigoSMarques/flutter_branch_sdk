part of flutter_branch_sdk;

class FlutterBranchSdk implements FlutterBranchSdkAbstract {
  /// Constructs a singleton instance of [FlutterBranchSdk].
  static FlutterBranchSdk _singleton;
  factory FlutterBranchSdk() {
    if (_singleton == null) {
      _singleton = FlutterBranchSdk._();
    }
    return _singleton;
  }

  FlutterBranchSdk._();

  ///Identifies the current user to the Branch API by supplying a unique identifier as a userId value
  static void setIdentity(String userId) {
    if (kIsWeb) {
      return FlutterBranchSdkWeb.setIdentity(userId);
    } else {
      return FlutterBranchSdkNative.setIdentity(userId);
    }
  }

  ///Add key value pairs to all requests
  static void setRequestMetadata(String key, String value) {
    if (kIsWeb) {
      return FlutterBranchSdkWeb.setRequestMetadata(key, value);
    } else {
      return FlutterBranchSdkNative.setRequestMetadata(key, value);
    }
  }

  ///This method should be called if you know that a different person is about to use the app
  static void logout() {
    if (kIsWeb) {
      return FlutterBranchSdkWeb.logout();
    } else {
      return FlutterBranchSdkNative.logout();
    }
  }

  ///Returns the last parameters associated with the link that referred the user
  static Future<Map<dynamic, dynamic>> getLatestReferringParams() async {
    if (kIsWeb) {
      return await FlutterBranchSdkWeb.getLatestReferringParams();
    } else {
      return await FlutterBranchSdkNative.getLatestReferringParams();
    }
  }

  ///Returns the first parameters associated with the link that referred the user
  static Future<Map<dynamic, dynamic>> getFirstReferringParams() async {
    if (kIsWeb) {
      return await FlutterBranchSdkWeb.getFirstReferringParams();
    } else {
      return await FlutterBranchSdkNative.getFirstReferringParams();
    }
  }

  ///Method to change the Tracking state. If disabled SDK will not track any user data or state.
  ///SDK will not send any network calls except for deep linking when tracking is disabled
  static void disableTracking(bool value) async {
    if (kIsWeb) {
      return FlutterBranchSdkWeb.disableTracking(value);
    } else {
      return FlutterBranchSdkNative.disableTracking(value);
    }
  }

  ///Initialises a session with the Branch API
  ///Listen click em Branch Deeplinks
  static Stream<Map<dynamic, dynamic>> initSession({String branchKey}) {
    if (kIsWeb) {
      if (branchKey == null) {
        throw UnsupportedError(
            "Branch web SDK implementation requires branchKey to be set in initialization");
      }
      return FlutterBranchSdkWeb.initSession(branchKey);
    } else {
      return FlutterBranchSdkNative.initSession();
    }
  }

  ///Use the SDK integration validator to check that you've added the Branch SDK and
  ///handle deep links correctly when you first integrate Branch into your app.
  static void validateSDKIntegration() {
    if (kIsWeb) {
      return FlutterBranchSdkWeb.validateSDKIntegration();
    } else {
      return FlutterBranchSdkNative.validateSDKIntegration();
    }
  }

  ///Creates a short url for the BUO
  static Future<BranchResponse> getShortUrl(
      {@required BranchUniversalObject buo,
      @required BranchLinkProperties linkProperties}) async {
    if (kIsWeb) {
      return FlutterBranchSdkWeb.getShortUrl(
          buo: buo, linkProperties: linkProperties);
    } else {
      return FlutterBranchSdkNative.getShortUrl(
          buo: buo, linkProperties: linkProperties);
    }
  }

  ///Showing a Share Sheet
  static Future<BranchResponse> showShareSheet(
      {@required BranchUniversalObject buo,
      @required BranchLinkProperties linkProperties,
      @required String messageText,
      String androidMessageTitle = '',
      String androidSharingTitle = ''}) async {
    if (kIsWeb) {
      return FlutterBranchSdkWeb.showShareSheet(
          buo: buo,
          linkProperties: linkProperties,
          messageText: messageText,
          androidMessageTitle: androidMessageTitle,
          androidSharingTitle: androidSharingTitle);
    } else {
      return FlutterBranchSdkNative.showShareSheet(
          buo: buo,
          linkProperties: linkProperties,
          messageText: messageText,
          androidMessageTitle: androidMessageTitle,
          androidSharingTitle: androidSharingTitle);
    }
  }

  ///Logs this BranchEvent to Branch for tracking and analytics
  static void trackContent(
      {@required BranchUniversalObject buo, BranchEvent branchEvent}) {
    if (kIsWeb) {
      return FlutterBranchSdkWeb.trackContent(
          buo: buo, branchEvent: branchEvent);
    } else {
      return FlutterBranchSdkNative.trackContent(
          buo: buo, branchEvent: branchEvent);
    }
  }

  ///Logs this BranchEvent to Branch for tracking and analytics
  static void trackContentWithoutBuo({BranchEvent branchEvent}) {
    if (kIsWeb) {
      return FlutterBranchSdkWeb.trackContentWithoutBuo(
          branchEvent: branchEvent);
    } else {
      return FlutterBranchSdkNative.trackContentWithoutBuo(
          branchEvent: branchEvent);
    }
  }

  ///Mark the content referred by this object as viewed. This increment the view count of the contents referred by this object.
  static void registerView({@required BranchUniversalObject buo}) {
    if (kIsWeb) {
      return FlutterBranchSdkWeb.registerView(buo: buo);
    } else {
      return FlutterBranchSdkNative.registerView(buo: buo);
    }
  }

  ///For Android: Publish this BUO with Google app indexing so that the contents will be available with google search
  ///For iOS:     List items on Spotlight
  static Future<bool> listOnSearch(
      {@required BranchUniversalObject buo,
      BranchLinkProperties linkProperties}) async {
    if (kIsWeb) {
      return FlutterBranchSdkWeb.listOnSearch(
          buo: buo, linkProperties: linkProperties);
    } else {
      return FlutterBranchSdkNative.listOnSearch(
          buo: buo, linkProperties: linkProperties);
    }
  }

  ///For Android: Remove the BUO from the local indexing if it is added to the local indexing already
  ///             This will remove the content from Google(Firebase) and other supported Indexing services
  ///For iOS:     Remove Branch Universal Object from Spotlight if privately indexed
  static Future<bool> removeFromSearch(
      {@required BranchUniversalObject buo,
      BranchLinkProperties linkProperties}) async {
    if (kIsWeb) {
      return FlutterBranchSdkWeb.removeFromSearch(
          buo: buo, linkProperties: linkProperties);
    } else {
      return FlutterBranchSdkNative.removeFromSearch(
          buo: buo, linkProperties: linkProperties);
    }
  }

  ///Retrieves rewards for the current user/session
  static Future<BranchResponse> loadRewards({String bucket}) async {
    if (kIsWeb) {
      return FlutterBranchSdkWeb.loadRewards(bucket: bucket);
    } else {
      return FlutterBranchSdkNative.loadRewards(bucket: bucket);
    }
  }

  ///Redeems the specified number of credits. if there are sufficient credits within it.
  ///If the number to redeem exceeds the number available in the bucket, all of the
  ///available credits will be redeemed instead.
  static Future<BranchResponse> redeemRewards(
      {@required int count, String bucket}) async {
    if (kIsWeb) {
      return FlutterBranchSdkWeb.redeemRewards(count: count, bucket: bucket);
    } else {
      return FlutterBranchSdkNative.redeemRewards(count: count, bucket: bucket);
    }
  }

  ///Gets the credit history
  static Future<BranchResponse> getCreditHistory({String bucket}) async {
    if (kIsWeb) {
      return FlutterBranchSdkWeb.getCreditHistory(bucket: bucket);
    } else {
      return FlutterBranchSdkNative.getCreditHistory(bucket: bucket);
    }
  }

  ///Set time window for SKAdNetwork callouts in Hours (Only iOS)
  ///By default, Branch limits calls to SKAdNetwork to within 72 hours after first install.
  static void setIOSSKAdNetworkMaxTime(int hours) {
    if (kIsWeb) {
      return FlutterBranchSdkWeb.setIOSSKAdNetworkMaxTime(hours);
    } else {
      return FlutterBranchSdkNative.setIOSSKAdNetworkMaxTime(hours);
    }
  }

  ///Indicates whether or not this user has a custom identity specified for them. Note that this is independent of installs.
  ///If you call setIdentity, this device will have that identity associated with this user until logout is called.
  ///This includes persisting through uninstalls, as we track device id.
  static Future<bool> isUserIdentified() async {
    if (kIsWeb) {
      return FlutterBranchSdkWeb.isUserIdentified();
    } else {
      return FlutterBranchSdkNative.isUserIdentified();
    }
  }
}
