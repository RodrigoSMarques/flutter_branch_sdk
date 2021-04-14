import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'app_tracking_transparency.dart';
import 'branch_universal_object.dart';
import 'flutter_branch_sdk_mobile.dart';

export 'branch_universal_object.dart';

/// The interface that all implementations of flutter_branch_sdk must
/// implement.
abstract class FlutterBranchSdkPlatform extends PlatformInterface {
  /// Constructs an instance of [FlutterBranchSdkPlatform].
  FlutterBranchSdkPlatform() : super(token: _token);

  static FlutterBranchSdkPlatform _instance = FlutterBranchSdkMobile();

  static final Object _token = Object();

  /// The default instance of [FlutterLocalNotificationsPlatform] to use.
  static FlutterBranchSdkPlatform get instance => _instance;

  /// Platform-specific plugins should set this with their own platform-specific
  /// class that extends [FlutterBranchSdkPlatform] when they register
  /// themselves.
  static set instance(FlutterBranchSdkPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  void initWeb({required String branchKey}) {
    throw UnimplementedError('initWeb has not been implemented');
  }

  ///Identifies the current user to the Branch API by supplying a unique identifier as a userId value
  void setIdentity(String userId) {
    throw UnimplementedError('setIdentity has not been implemented');
  }

  ///Add key value pairs to all requests
  void setRequestMetadata(String key, String value) {
    throw UnimplementedError('setRequestMetadata has not been implemented');
  }

  ///This method should be called if you know that a different person is about to use the app
  void logout() {
    throw UnimplementedError('logout has not been implemented');
  }

  ///Returns the last parameters associated with the link that referred the user
  Future<Map<dynamic, dynamic>> getLatestReferringParams() async {
    throw UnimplementedError(
        'getLatestReferringParams has not been implemented');
  }

  ///Returns the first parameters associated with the link that referred the user
  Future<Map<dynamic, dynamic>> getFirstReferringParams() async {
    throw UnimplementedError(
        'getFirstReferringParams has not been implemented');
  }

  ///Method to change the Tracking state. If disabled SDK will not track any user data or state.
  ///SDK will not send any network calls except for deep linking when tracking is disabled
  void disableTracking(bool value) async {
    throw UnimplementedError('disableTracking has not been implemented');
  }

  ///Initialises a session with the Branch API
  ///Listen click em Branch Deeplinks
  Stream<Map<dynamic, dynamic>> initSession() {
    throw UnimplementedError('initSession has not been implemented');
  }

  ///Use the SDK integration validator to check that you've added the Branch SDK and
  ///handle deep links correctly when you first integrate Branch into your app.
  void validateSDKIntegration() {
    throw UnimplementedError('validateSDKIntegration has not been implemented');
  }

  ///Creates a short url for the BUO
  Future<BranchResponse> getShortUrl(
      {required BranchUniversalObject buo,
      required BranchLinkProperties linkProperties}) async {
    throw UnimplementedError('getShortUrl has not been implemented');
  }

  ///Showing a Share Sheet
  Future<BranchResponse> showShareSheet(
      {required BranchUniversalObject buo,
      required BranchLinkProperties linkProperties,
      required String messageText,
      String androidMessageTitle = '',
      String androidSharingTitle = ''}) async {
    throw UnimplementedError('showShareSheet has not been implemented');
  }

  ///Logs this BranchEvent to Branch for tracking and analytics
  void trackContent(
      {required BranchUniversalObject buo, required BranchEvent branchEvent}) {
    throw UnimplementedError('trackContent has not been implemented');
  }

  ///Logs this BranchEvent to Branch for tracking and analytics
  void trackContentWithoutBuo({required BranchEvent branchEvent}) {
    throw UnimplementedError('trackContentWithoutBuo has not been implemented');
  }

  ///Mark the content referred by this object as viewed. This increment the view count of the contents referred by this object.
  void registerView({required BranchUniversalObject buo}) {
    throw UnimplementedError('registerView has not been implemented');
  }

  ///For Android: Publish this BUO with Google app indexing so that the contents will be available with google search
  ///For iOS:     List items on Spotlight
  Future<bool> listOnSearch(
      {required BranchUniversalObject buo,
      BranchLinkProperties? linkProperties}) async {
    throw UnimplementedError('listOnSearch has not been implemented');
  }

  ///For Android: Remove the BUO from the local indexing if it is added to the local indexing already
  ///             This will remove the content from Google(Firebase) and other supported Indexing services
  ///For iOS:     Remove Branch Universal Object from Spotlight if privately indexed
  Future<bool> removeFromSearch(
      {required BranchUniversalObject buo,
      BranchLinkProperties? linkProperties}) async {
    throw UnimplementedError('removeFromSearch has not been implemented');
  }

  ///Retrieves rewards for the current user/session
  Future<BranchResponse> loadRewards({String bucket = 'default'}) async {
    throw UnimplementedError('loadRewards has not been implemented');
  }

  ///Redeems the specified number of credits. if there are sufficient credits within it.
  ///If the number to redeem exceeds the number available in the bucket, all of the
  ///available credits will be redeemed instead.
  Future<BranchResponse> redeemRewards(
      {required int count, String bucket = 'default'}) async {
    throw UnimplementedError('redeemRewards has not been implemented');
  }

  ///Gets the credit history
  Future<BranchResponse> getCreditHistory({String bucket = 'default'}) async {
    throw UnimplementedError('getCreditHistory has not been implemented');
  }

  ///Set time window for SKAdNetwork callouts in Hours (Only iOS)
  ///By default, Branch limits calls to SKAdNetwork to within 72 hours after first install.
  void setIOSSKAdNetworkMaxTime(int hours) {
    throw UnimplementedError(
        'setIOSSKAdNetworkMaxTime has not been implemented');
  }

  ///Indicates whether or not this user has a custom identity specified for them. Note that this is independent of installs.
  ///If you call setIdentity, this device will have that identity associated with this user until logout is called.
  ///This includes persisting through uninstalls, as we track device id.
  Future<bool> isUserIdentified() async {
    throw UnimplementedError('isUserIdentified has not been implemented');
  }

  /// request AppTracking Autorization and return AppTrackingStatus
  /// on Android returns notSupported
  Future<AppTrackingStatus> requestTrackingAuthorization() async {
    throw UnimplementedError(
        'requestTrackingAuthorization has not been implemented');
  }

  /// return AppTrackingStatus
  /// on Android returns notSupported
  Future<AppTrackingStatus> getTrackingAuthorizationStatus() async {
    throw UnimplementedError(
        'getTrackingAuthorizationStatus has not been implemented');
  }

  /// return advertising identifier (ie tracking data).
  /// on Android returns empty string
  Future<String> getAdvertisingIdentifier() async {
    throw UnimplementedError(
        'getAdvertisingIdentifier has not been implemented');
  }
}
