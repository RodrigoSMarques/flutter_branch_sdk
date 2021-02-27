import '../branch_universal_object.dart';
import '../flutter_branch_sdk.dart';

abstract class FlutterBranchSdkPlatform {
  void initWeb(String branchKey) {
    throw UnsupportedError('initWeb has not been implemented');
  }

  ///Identifies the current user to the Branch API by supplying a unique identifier as a userId value
  void setIdentity(String userId) {
    throw UnsupportedError('setIdentity has not been implemented');
  }

  ///Add key value pairs to all requests
  void setRequestMetadata(String key, String value) {
    throw UnsupportedError('Not implemented');
  }

  ///This method should be called if you know that a different person is about to use the app
  void logout() {
    throw UnsupportedError('Not implemented');
  }

  ///Returns the last parameters associated with the link that referred the user
  Future<Map<dynamic, dynamic>> getLatestReferringParams() async {
    throw UnsupportedError('Not implemented');
  }

  ///Returns the first parameters associated with the link that referred the user
  Future<Map<dynamic, dynamic>> getFirstReferringParams() async {
    throw UnsupportedError('Not implemented');
  }

  ///Method to change the Tracking state. If disabled SDK will not track any user data or state.
  ///SDK will not send any network calls except for deep linking when tracking is disabled
  void disableTracking(bool value) async {
    throw UnsupportedError('Not implemented');
  }

  ///Initialises a session with the Branch API
  ///Listen click em Branch Deeplinks
  Stream<Map<dynamic, dynamic>> initSession() {
    throw UnsupportedError('Not implemented');
  }

  ///Use the SDK integration validator to check that you've added the Branch SDK and
  ///handle deep links correctly when you first integrate Branch into your app.
  void validateSDKIntegration() {
    throw UnsupportedError('Not implemented');
  }

  ///Creates a short url for the BUO
  Future<BranchResponse> getShortUrl(
      {required BranchUniversalObject buo,
      required BranchLinkProperties linkProperties}) async {
    throw UnsupportedError('Not implemented');
  }

  ///Showing a Share Sheet
  Future<BranchResponse> showShareSheet(
      {required BranchUniversalObject buo,
      required BranchLinkProperties linkProperties,
      required String messageText,
      String androidMessageTitle = '',
      String androidSharingTitle = ''}) async {
    throw UnsupportedError('Not implemented');
  }

  ///Logs this BranchEvent to Branch for tracking and analytics
  void trackContent(
      {required BranchUniversalObject buo, required BranchEvent branchEvent}) {
    throw UnsupportedError('Not implemented');
  }

  ///Logs this BranchEvent to Branch for tracking and analytics
  void trackContentWithoutBuo({required BranchEvent branchEvent}) {
    throw UnsupportedError('Not implemented');
  }

  ///Mark the content referred by this object as viewed. This increment the view count of the contents referred by this object.
  void registerView({required BranchUniversalObject buo}) {
    throw UnsupportedError('Not implemented');
  }

  ///For Android: Publish this BUO with Google app indexing so that the contents will be available with google search
  ///For iOS:     List items on Spotlight
  Future<bool> listOnSearch(
      {required BranchUniversalObject buo,
      BranchLinkProperties? linkProperties}) async {
    throw UnsupportedError('Not implemented');
  }

  ///For Android: Remove the BUO from the local indexing if it is added to the local indexing already
  ///             This will remove the content from Google(Firebase) and other supported Indexing services
  ///For iOS:     Remove Branch Universal Object from Spotlight if privately indexed
  Future<bool> removeFromSearch(
      {required BranchUniversalObject buo,
      BranchLinkProperties? linkProperties}) async {
    throw UnsupportedError('Not implemented');
  }

  ///Retrieves rewards for the current user/session
  Future<BranchResponse> loadRewards({String bucket = 'default'}) async {
    throw UnsupportedError('Not implemented');
  }

  ///Redeems the specified number of credits. if there are sufficient credits within it.
  ///If the number to redeem exceeds the number available in the bucket, all of the
  ///available credits will be redeemed instead.
  Future<BranchResponse> redeemRewards(
      {required int count, String bucket = 'default'}) async {
    throw UnsupportedError('Not implemented');
  }

  ///Gets the credit history
  Future<BranchResponse> getCreditHistory({String bucket = 'default'}) async {
    throw UnsupportedError('Not implemented');
  }

  ///Set time window for SKAdNetwork callouts in Hours (Only iOS)
  ///By default, Branch limits calls to SKAdNetwork to within 72 hours after first install.
  void setIOSSKAdNetworkMaxTime(int hours) {
    throw UnsupportedError('Not implemented');
  }

  ///Indicates whether or not this user has a custom identity specified for them. Note that this is independent of installs.
  ///If you call setIdentity, this device will have that identity associated with this user until logout is called.
  ///This includes persisting through uninstalls, as we track device id.
  Future<bool> isUserIdentified() async {
    throw UnsupportedError('Not implemented');
  }
}
