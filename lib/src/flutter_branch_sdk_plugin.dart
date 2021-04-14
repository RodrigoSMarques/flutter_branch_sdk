part of flutter_branch_sdk;

class FlutterBranchSdk {
  static FlutterBranchSdkPlatform? __platform;

  static FlutterBranchSdkPlatform get _platform {
    __platform ??= FlutterBranchSdkPlatform.instance;
    return __platform!;
  }

  static void initWeb({required String branchKey}) {
    _platform.initWeb(branchKey: branchKey);
  }

  ///Identifies the current user to the Branch API by supplying a unique identifier as a userId value
  static void setIdentity(String userId) {
    _platform.setIdentity(userId);
  }

  ///Add key value pairs to all requests
  static void setRequestMetadata(String key, String value) {
    _platform.setRequestMetadata(key, value);
  }

  ///This method should be called if you know that a different person is about to use the app
  static void logout() {
    _platform.logout();
  }

  ///Returns the last parameters associated with the link that referred the user
  static Future<Map<dynamic, dynamic>> getLatestReferringParams() async {
    return await _platform.getLatestReferringParams();
  }

  ///Returns the first parameters associated with the link that referred the user
  static Future<Map<dynamic, dynamic>> getFirstReferringParams() async {
    return await _platform.getFirstReferringParams();
  }

  ///Method to change the Tracking state. If disabled SDK will not track any user data or state.
  ///SDK will not send any network calls except for deep linking when tracking is disabled
  static void disableTracking(bool value) async {
    return _platform.disableTracking(value);
  }

  ///Initialises a session with the Branch API
  ///Listen click em Branch Deeplinks
  static Stream<Map<dynamic, dynamic>> initSession() {
    return _platform.initSession();
  }

  ///Use the SDK integration validator to check that you've added the Branch SDK and
  ///handle deep links correctly when you first integrate Branch into your app.
  static void validateSDKIntegration() {
    _platform.validateSDKIntegration();
  }

  ///Creates a short url for the BUO
  static Future<BranchResponse> getShortUrl(
      {required BranchUniversalObject buo,
      required BranchLinkProperties linkProperties}) async {
    return _platform.getShortUrl(buo: buo, linkProperties: linkProperties);
  }

  ///Showing a Share Sheet
  static Future<BranchResponse> showShareSheet(
      {required BranchUniversalObject buo,
      required BranchLinkProperties linkProperties,
      required String messageText,
      String androidMessageTitle = '',
      String androidSharingTitle = ''}) async {
    return _platform.showShareSheet(
        buo: buo,
        linkProperties: linkProperties,
        messageText: messageText,
        androidMessageTitle: androidMessageTitle,
        androidSharingTitle: androidSharingTitle);
  }

  ///Logs this BranchEvent to Branch for tracking and analytics
  static void trackContent(
      {required BranchUniversalObject buo, required BranchEvent branchEvent}) {
    return _platform.trackContent(buo: buo, branchEvent: branchEvent);
  }

  ///Logs this BranchEvent to Branch for tracking and analytics
  static void trackContentWithoutBuo({required BranchEvent branchEvent}) {
    return _platform.trackContentWithoutBuo(branchEvent: branchEvent);
  }

  ///Mark the content referred by this object as viewed. This increment the view count of the contents referred by this object.
  static void registerView({required BranchUniversalObject buo}) {
    return _platform.registerView(buo: buo);
  }

  ///For Android: Publish this BUO with Google app indexing so that the contents will be available with google search
  ///For iOS:     List items on Spotlight
  static Future<bool> listOnSearch(
      {required BranchUniversalObject buo,
      BranchLinkProperties? linkProperties}) async {
    return _platform.listOnSearch(buo: buo, linkProperties: linkProperties);
  }

  ///For Android: Remove the BUO from the local indexing if it is added to the local indexing already
  ///             This will remove the content from Google(Firebase) and other supported Indexing services
  ///For iOS:     Remove Branch Universal Object from Spotlight if privately indexed
  static Future<bool> removeFromSearch(
      {required BranchUniversalObject buo,
      BranchLinkProperties? linkProperties}) async {
    return _platform.removeFromSearch(buo: buo, linkProperties: linkProperties);
  }

  ///Retrieves rewards for the current user/session
  static Future<BranchResponse> loadRewards({String bucket = 'default'}) async {
    return _platform.loadRewards(bucket: bucket);
  }

  ///Redeems the specified number of credits. if there are sufficient credits within it.
  ///If the number to redeem exceeds the number available in the bucket, all of the
  ///available credits will be redeemed instead.
  static Future<BranchResponse> redeemRewards(
      {required int count, String bucket = 'default'}) async {
    return _platform.redeemRewards(count: count, bucket: bucket);
  }

  ///Gets the credit history
  static Future<BranchResponse> getCreditHistory(
      {String bucket = 'default'}) async {
    return _platform.getCreditHistory(bucket: bucket);
  }

  ///Set time window for SKAdNetwork callouts in Hours (Only iOS)
  ///By default, Branch limits calls to SKAdNetwork to within 72 hours after first install.
  static void setIOSSKAdNetworkMaxTime(int hours) {
    return _platform.setIOSSKAdNetworkMaxTime(hours);
  }

  ///Indicates whether or not this user has a custom identity specified for them. Note that this is independent of installs.
  ///If you call setIdentity, this device will have that identity associated with this user until logout is called.
  ///This includes persisting through uninstalls, as we track device id.
  static Future<bool> isUserIdentified() async {
    return _platform.isUserIdentified();
  }

  /// request AppTracking Autorization and return AppTrackingStatus
  /// on Android returns notSupported
  static Future<AppTrackingStatus> requestTrackingAuthorization() async {
    return _platform.requestTrackingAuthorization();
  }

  /// return AppTrackingStatus
  /// on Android returns notSupported
  static Future<AppTrackingStatus> getTrackingAuthorizationStatus() async {
    return _platform.getTrackingAuthorizationStatus();
  }

  /// return advertising identifier (ie tracking data).
  /// on Android returns empty string
  static Future<String> getAdvertisingIdentifier() async {
    return _platform.getAdvertisingIdentifier();
  }
}
