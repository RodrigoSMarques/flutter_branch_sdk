part of '../flutter_branch_sdk.dart';

class FlutterBranchSdk {
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
  static Future<void> init(
      {bool enableLogging = false,
      @Deprecated('use branchAttributionLevel') bool disableTracking = false,
      BranchAttributionLevel? branchAttributionLevel}) async {
    await FlutterBranchSdkPlatform.instance.init(
        enableLogging: enableLogging,
        disableTracking: disableTracking,
        branchAttributionLevel: branchAttributionLevel);
  }

  ///Identifies the current user to the Branch API by supplying a unique identifier as a userId value
  static void setIdentity(String userId) {
    FlutterBranchSdkPlatform.instance.setIdentity(userId);
  }

  ///Add key value pairs to all requests
  static void setRequestMetadata(String key, String value) {
    FlutterBranchSdkPlatform.instance.setRequestMetadata(key, value);
  }

  ///This method should be called if you know that a different person is about to use the app
  static void logout() {
    FlutterBranchSdkPlatform.instance.logout();
  }

  ///Returns the last parameters associated with the link that referred the user
  static Future<Map<dynamic, dynamic>> getLatestReferringParams() async {
    return await FlutterBranchSdkPlatform.instance.getLatestReferringParams();
  }

  ///Returns the first parameters associated with the link that referred the user
  static Future<Map<dynamic, dynamic>> getFirstReferringParams() async {
    return await FlutterBranchSdkPlatform.instance.getFirstReferringParams();
  }

  ///Method to change the Tracking state. If disabled SDK will not track any user data or state.
  ///SDK will not send any network calls except for deep linking when tracking is disabled
  static void disableTracking(bool value) async {
    return FlutterBranchSdkPlatform.instance.disableTracking(value);
  }

  ///Listen click em Branch Deeplinks
  static Stream<Map<dynamic, dynamic>> listSession() {
    return FlutterBranchSdkPlatform.instance.listSession();
  }

  ///Use the SDK integration validator to check that you've added the Branch SDK and
  ///handle deep links correctly when you first integrate Branch into your app.
  static void validateSDKIntegration() {
    FlutterBranchSdkPlatform.instance.validateSDKIntegration();
  }

  ///Creates a short url for the BUO
  static Future<BranchResponse> getShortUrl(
      {required BranchUniversalObject buo,
      required BranchLinkProperties linkProperties}) async {
    return FlutterBranchSdkPlatform.instance
        .getShortUrl(buo: buo, linkProperties: linkProperties);
  }

  ///Showing a Share Sheet
  static Future<BranchResponse> showShareSheet(
      {required BranchUniversalObject buo,
      required BranchLinkProperties linkProperties,
      required String messageText,
      String androidMessageTitle = '',
      String androidSharingTitle = ''}) async {
    return FlutterBranchSdkPlatform.instance.showShareSheet(
        buo: buo,
        linkProperties: linkProperties,
        messageText: messageText,
        androidMessageTitle: androidMessageTitle,
        androidSharingTitle: androidSharingTitle);
  }

  ///Logs this BranchEvent to Branch for tracking and analytics
  static void trackContent(
      {required List<BranchUniversalObject> buo,
      required BranchEvent branchEvent}) {
    return FlutterBranchSdkPlatform.instance
        .trackContent(buo: buo, branchEvent: branchEvent);
  }

  ///Logs this BranchEvent to Branch for tracking and analytics
  static void trackContentWithoutBuo({required BranchEvent branchEvent}) {
    return FlutterBranchSdkPlatform.instance
        .trackContentWithoutBuo(branchEvent: branchEvent);
  }

  ///Mark the content referred by this object as viewed. This increment the view count of the contents referred by this object.
  static void registerView({required BranchUniversalObject buo}) {
    return FlutterBranchSdkPlatform.instance.registerView(buo: buo);
  }

  ///For Android: Publish this BUO with Google app indexing so that the contents will be available with google search
  ///For iOS:     List items on Spotlight
  static Future<bool> listOnSearch(
      {required BranchUniversalObject buo,
      BranchLinkProperties? linkProperties}) async {
    return FlutterBranchSdkPlatform.instance
        .listOnSearch(buo: buo, linkProperties: linkProperties);
  }

  ///For Android: Remove the BUO from the local indexing if it is added to the local indexing already
  ///             This will remove the content from Google(Firebase) and other supported Indexing services
  ///For iOS:     Remove Branch Universal Object from Spotlight if privately indexed
  static Future<bool> removeFromSearch(
      {required BranchUniversalObject buo,
      BranchLinkProperties? linkProperties}) async {
    return FlutterBranchSdkPlatform.instance
        .removeFromSearch(buo: buo, linkProperties: linkProperties);
  }

  ///Indicates whether or not this user has a custom identity specified for them. Note that this is independent of installs.
  ///If you call setIdentity, this device will have that identity associated with this user until logout is called.
  ///This includes persisting through uninstalls, as we track device id.
  static Future<bool> isUserIdentified() async {
    return FlutterBranchSdkPlatform.instance.isUserIdentified();
  }

  /// request AppTracking Autorization and return AppTrackingStatus
  /// on Android returns notSupported
  static Future<AppTrackingStatus> requestTrackingAuthorization() async {
    return FlutterBranchSdkPlatform.instance.requestTrackingAuthorization();
  }

  /// return AppTrackingStatus
  /// on Android returns notSupported
  static Future<AppTrackingStatus> getTrackingAuthorizationStatus() async {
    return FlutterBranchSdkPlatform.instance.getTrackingAuthorizationStatus();
  }

  /// return advertising identifier (ie tracking data).
  /// on Android returns empty string
  static Future<String> getAdvertisingIdentifier() async {
    return FlutterBranchSdkPlatform.instance.getAdvertisingIdentifier();
  }

  ///Sets the duration in milliseconds that the system should wait for initializing
  ///a network * request.
  static void setConnectTimeout(int connectTimeout) {
    return FlutterBranchSdkPlatform.instance.setConnectTimeout(connectTimeout);
  }

  ///Sets the duration in milliseconds that the system should wait for a response
  ///before timing out any Branch API.
  ///Default 5500 ms. Note that this is the total time allocated for all request
  ///retries as set in setRetryCount(int).
  static void setTimeout(int timeout) {
    return FlutterBranchSdkPlatform.instance.setTimeout(timeout);
  }

  ///Sets the max number of times to re-attempt a timed-out request to the Branch API, before
  /// considering the request to have failed entirely. Default to 3.
  /// Note that the the network timeout, as set in setNetworkTimeout(int),
  /// together with the retry interval value from setRetryInterval(int) will
  /// determine if the max retry count will be attempted.
  static void setRetryCount(int retryCount) {
    return FlutterBranchSdkPlatform.instance.setRetryCount(retryCount);
  }

  ///Sets the amount of time in milliseconds to wait before re-attempting a
  ///timed-out request to the Branch API. Default 1000 ms.
  static void setRetryInterval(int retryInterval) {
    return FlutterBranchSdkPlatform.instance.setRetryInterval(retryInterval);
  }

  ///Gets the available last attributed touch data with a custom set attribution window.
  static Future<BranchResponse> getLastAttributedTouchData(
      {int? attributionWindow}) async {
    return FlutterBranchSdkPlatform.instance
        .getLastAttributedTouchData(attributionWindow: attributionWindow);
  }

  ///Creates a Branch QR Code image. Returns the QR code as Uint8List.
  static Future<BranchResponse> getQRCodeAsData(
      {required BranchUniversalObject buo,
      required BranchLinkProperties linkProperties,
      required BranchQrCode qrCode}) async {
    return FlutterBranchSdkPlatform.instance.getQRCodeAsData(
        buo: buo, linkProperties: linkProperties, qrCodeSettings: qrCode);
  }

  ///Creates a Branch QR Code image. Returns the QR code as a Image.
  static Future<BranchResponse> getQRCodeAsImage(
      {required BranchUniversalObject buo,
      required BranchLinkProperties linkProperties,
      required BranchQrCode qrCode}) async {
    return FlutterBranchSdkPlatform.instance.getQRCodeAsImage(
        buo: buo, linkProperties: linkProperties, qrCodeSettings: qrCode);
  }

  ///Share with LPLinkMetadata on iOS
  static void shareWithLPLinkMetadata(
      {required BranchUniversalObject buo,
      required BranchLinkProperties linkProperties,
      required Uint8List icon,
      required String title}) {
    Map<String, dynamic> params = {};
    params['buo'] = buo.toMap();
    params['lp'] = linkProperties.toMap();
    params['title'] = title;

    FlutterBranchSdkPlatform.instance.shareWithLPLinkMetadata(
        buo: buo, linkProperties: linkProperties, icon: icon, title: title);
  }

  ///Have Branch end the current deep link session and start a new session with the provided URL.
  static void handleDeepLink(String url) {
    FlutterBranchSdkPlatform.instance.handleDeepLink(url);
  }

  /// Add a Partner Parameter for Facebook.
  /// Once set, this parameter is attached to installs, opens and events until cleared or the app restarts.
  /// See Facebook's documentation for details on valid parameters
  static void addFacebookPartnerParameter(
      {required String key, required String value}) {
    FlutterBranchSdkPlatform.instance
        .addFacebookPartnerParameter(key: key, value: value);
  }

  /// Clears all Partner Parameters
  static void clearPartnerParameters() {
    FlutterBranchSdkPlatform.instance.clearPartnerParameters();
  }

  /// Add the pre-install campaign analytics
  static void setPreinstallCampaign(String value) {
    FlutterBranchSdkPlatform.instance.setPreinstallCampaign(value);
  }

  /// Add the pre-install campaign analytics
  static void setPreinstallPartner(String value) {
    FlutterBranchSdkPlatform.instance.setPreinstallPartner(value);
  }

  ///Add a Partner Parameter for Snap.
  ///Once set, this parameter is attached to installs, opens and events until cleared or the app restarts.
  static void addSnapPartnerParameter(
      {required String key, required String value}) {
    FlutterBranchSdkPlatform.instance
        .addSnapPartnerParameter(key: key, value: value);
  }

  /// Sets the value of parameters required by Google Conversion APIs for DMA Compliance in EEA region.
  /// [eeaRegion] `true` If European regulations, including the DMA, apply to this user and conversion.
  /// [adPersonalizationConsent] `true` If End user has granted/denied ads personalization consent.
  /// [adUserDataUsageConsent] `true If User has granted/denied consent for 3P transmission of user level data for ads.
  static void setDMAParamsForEEA(
      {required bool eeaRegion,
      required bool adPersonalizationConsent,
      required bool adUserDataUsageConsent}) {
    FlutterBranchSdkPlatform.instance.setDMAParamsForEEA(
        eeaRegion: eeaRegion,
        adPersonalizationConsent: adPersonalizationConsent,
        adUserDataUsageConsent: adUserDataUsageConsent);
  }

  /// Sets the consumer protection attribution level.
  static void setConsumerProtectionAttributionLevel(
      BranchAttributionLevel branchAttributionLevel) {
    FlutterBranchSdkPlatform.instance
        .setConsumerProtectionAttributionLevel(branchAttributionLevel);
  }
}
