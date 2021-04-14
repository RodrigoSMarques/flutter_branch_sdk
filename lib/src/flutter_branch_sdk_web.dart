import 'dart:async';
import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter
import 'dart:js';
// ignore: avoid_web_libraries_in_flutter
import 'dart:js_util';

import 'package:flutter_web_plugins/flutter_web_plugins.dart';

import 'app_tracking_transparency.dart';
import 'flutter_branch_sdk_platform_interface.dart';
import 'web/branch_js.dart';

/// A workaround to deep-converting an object from JS to a Dart Object.
dynamic _jsObjectToDartObject(data) => json.decode(jsonStringify(data));
dynamic _dartObjectToJsObject(data) => jsonParse(json.encode(data));
Map<String, String> _metaData = {};

/// A web implementation of the FlutterBranchSdk plugin.
class FlutterBranchSdk extends FlutterBranchSdkPlatform {
  static FlutterBranchSdk? _singleton;

  /// Constructs a singleton instance of [MethodChannelFlutterBranchSdk].
  factory FlutterBranchSdk() {
    if (_singleton == null) {
      _singleton = FlutterBranchSdk._();
    }
    return _singleton!;
  }

  FlutterBranchSdk._();

  /*
  static FlutterBranchSdkPlatform? __platform;

  static FlutterBranchSdkPlatform get _platform {
    __platform ??= FlutterBranchSdkPlatform.instance;
    return __platform!;
  }
   */

  /// Registers this class as the default instance of [SharePlatform].
  static void registerWith(Registrar registrar) {
    FlutterBranchSdkPlatform.instance = FlutterBranchSdk();
  }

  static final StreamController<Map<String, dynamic>> _initSessionStream =
      StreamController<Map<String, dynamic>>();

  static bool _userIdentified = false;

  static String _branchKey = '';
  //static bool _sessionInitialized = false;

  @override
  void initWeb({required String branchKey}) {
    _branchKey = branchKey;
  }

  ///Identifies the current user to the Branch API by supplying a unique identifier as a userId value
  @override
  void setIdentity(String userId) {
    /*
    if (_sessionInitialized == false) {
      throw AssertionError(
          'in Web call initSession() before call setIdentity()');
    }
     */
    try {
      BranchJS.setIdentity(userId, allowInterop((error, data) {
        if (error == null) {
          _userIdentified = true;
        }
      }));
    } catch (e) {
      print('setIdentity() error: $e');
    }
  }

  ///Add key value pairs to all requests
  @override
  void setRequestMetadata(String key, String value) {
    _metaData[key] = value;
  }

  ///This method should be called if you know that a different person is about to use the app
  @override
  void logout() {
    try {
      BranchJS.logout(allowInterop((error) {
        if (error == null) {
          _userIdentified = false;
        }
      }));
    } catch (e) {
      print('logout() error: $e');
    }
  }

  ///Returns the last parameters associated with the link that referred the user, not really applicaple for web though
  @override
  Future<Map<dynamic, dynamic>> getLatestReferringParams() {
    final Completer<Map<dynamic, dynamic>> response = Completer();

    try {
      BranchJS.data(allowInterop((err, data) {
        if (err == null) {
          if (data != null) {
            var responseData =
                Map<dynamic, dynamic>.from(_jsObjectToDartObject(data));
            response.complete(responseData);
          } else {
            response.complete({});
          }
        } else {
          response.completeError(err);
        }
      }));
    } catch (e) {
      print('getLatestReferringParams() error: $e');
      response.completeError(e);
    }
    return response.future;
  }

  ///Returns the first parameters associated with the link that referred the user
  @override
  Future<Map<dynamic, dynamic>> getFirstReferringParams() {
    final Completer<Map<dynamic, dynamic>> response =
        Completer<Map<dynamic, dynamic>>();

    try {
      BranchJS.first(allowInterop((err, data) {
        if (err == null) {
          if (data != null) {
            var responseData =
                Map<dynamic, dynamic>.from(_jsObjectToDartObject(data));
            response.complete(responseData);
          } else {
            response.complete({});
          }
        } else {
          response.completeError(err);
        }
      }));
    } catch (e) {
      print('getFirstReferringParams() error: $e');
      response.completeError(e);
    }
    return response.future;
  }

  ///Method to change the Tracking state. If disabled SDK will not track any user data or state.
  ///SDK will not send any network calls except for deep linking when tracking is disabled
  @override
  void disableTracking(bool value) {
    try {
      BranchJS.disableTracking(value);
    } catch (e) {
      print('disableTracking() error: $e');
    }
  }

  ///Initialises a session with the Branch API
  ///Listen click em Branch Deeplinks
  @override
  Stream<Map<dynamic, dynamic>> initSession() {
    if (_branchKey.isEmpty) {
      throw AssertionError('call initWeb() before initSession');
    }

    BranchJS.init(_branchKey, null, allowInterop((err, data) {
      //_sessionInitialized = true;
      if (err == null) {
        if (data != null) {
          var parsedData = _jsObjectToDartObject(data);
          if (parsedData is Map && parsedData.containsKey("data_parsed")) {
            parsedData = parsedData["data_parsed"];
          }
          if (parsedData is String) {
            try {
              parsedData = json.decode(parsedData);
            } catch (e) {
              print('Failed to try to parse JSON: $e - $parsedData');
            }
          }
          _initSessionStream.sink.add(parsedData);
        } else {
          _initSessionStream.sink.add({});
        }
      } else {
        print('initSession() error: $err');
        _initSessionStream.addError(Exception(err));
      }
    }));

    return _initSessionStream.stream;
  }

  ///Use the SDK integration validator to check that you've added the Branch SDK and
  ///handle deep links correctly when you first integrate Branch into your app.
  @override
  void validateSDKIntegration() {
    throw UnsupportedError(
        'validateSDKIntegration() not available in Branch JS SDK');
  }

  ///Creates a short url for the BUO
  @override
  Future<BranchResponse> getShortUrl(
      {required BranchUniversalObject buo,
      required BranchLinkProperties linkProperties}) async {
    Map<String, dynamic> contentMetadata = {
      if (buo.contentMetadata != null) ...buo.contentMetadata!.toMap()
    };

    if (contentMetadata.containsKey('customMetadata')) {
      var customMetadata = contentMetadata['customMetadata'];
      contentMetadata.remove('customMetadata');
      contentMetadata.addAll(customMetadata);
    }

    Map<String, dynamic> linkData = {
      "\$canonical_identifier": buo.canonicalIdentifier,
      "\$publicly_indexable": buo.publiclyIndex,
      "\$locally_indexable": buo.locallyIndex,
      "\$og_title": buo.title,
      "\$og_description": buo.contentDescription,
      "\$og_image_url": buo.imageUrl,
      if (contentMetadata.keys.length > 0) ...contentMetadata
    };

    Map<String, dynamic> data = {...linkProperties.toMap(), 'data': linkData};

    Completer<BranchResponse> responseCompleter = Completer();

    try {
      BranchJS.link(_dartObjectToJsObject(data), allowInterop((err, url) {
        if (err == null) {
          responseCompleter.complete(BranchResponse.success(result: url));
        } else {
          responseCompleter.completeError(
              BranchResponse.error(errorCode: '-1', errorMessage: err));
        }
      }));
    } catch (e) {
      print('getShortUrl() error: $e');
      responseCompleter.completeError(BranchResponse.error(
          errorCode: '-1', errorMessage: 'getShortUrl() error'));
    }
    return responseCompleter.future;
  }

  ///Showing a Share Sheet - Implemented via navigator share if available, otherwise browser prompt.
  @override
  Future<BranchResponse> showShareSheet(
      {required BranchUniversalObject buo,
      required BranchLinkProperties linkProperties,
      required String messageText,
      String androidMessageTitle = '',
      String androidSharingTitle = ''}) async {
    BranchResponse response =
        await getShortUrl(buo: buo, linkProperties: linkProperties);
    if (response.success) {
      try {
        await promiseToFuture(navigatorShare(_dartObjectToJsObject({
          "title": messageText,
          "text": buo.title,
          "url": response.result
        })));
      } catch (e) {
        browserPrompt(messageText, response.result);
      }
    }
    return response;
  }

  ///Logs this BranchEvent to Branch for tracking and analytics
  @override
  void trackContent(
      {required BranchUniversalObject buo, required BranchEvent branchEvent}) {
    Map<String, dynamic> contentMetadata = {
      if (buo.contentMetadata != null) ...buo.contentMetadata!.toMap()
    };

    try {
      BranchJS.logEvent(branchEvent.eventName,
          _dartObjectToJsObject({...branchEvent.toMap(), ...contentMetadata}));
    } catch (e) {
      print('trackContent() error: $e');
    }
  }

  ///Logs this BranchEvent to Branch for tracking and analytics
  @override
  void trackContentWithoutBuo({required BranchEvent branchEvent}) {
    try {
      BranchJS.logEvent(
          branchEvent.eventName, _dartObjectToJsObject(branchEvent.toMap()));
    } catch (e) {
      print('trackContentWithoutBuo() error: $e');
    }
  }

  ///Mark the content referred by this object as viewed. This increment the view count of the contents referred by this object.
  @override
  void registerView({required BranchUniversalObject buo}) {
    BranchEvent branchEvent =
        BranchEvent.standardEvent(BranchStandardEvent.VIEW_ITEM);

    // This might not be exactly the same thing as BUO.registerView, but there's no clear implementation for web sdk
    trackContent(buo: buo, branchEvent: branchEvent);
  }

  ///For Android: Publish this BUO with Google app indexing so that the contents will be available with google search
  ///For iOS:     List items on Spotlight
  @override
  Future<bool> listOnSearch(
      {required BranchUniversalObject buo,
      BranchLinkProperties? linkProperties}) async {
    throw UnsupportedError('listOnSearch() Not supported by Branch JS SDK');
  }

  ///For Android: Remove the BUO from the local indexing if it is added to the local indexing already
  ///             This will remove the content from Google(Firebase) and other supported Indexing services
  ///For iOS:     Remove Branch Universal Object from Spotlight if privately indexed
  @override
  Future<bool> removeFromSearch(
      {required BranchUniversalObject buo,
      BranchLinkProperties? linkProperties}) async {
    throw UnsupportedError('removeFromSearch() Not supported by Branch JS SDK');
  }

  ///Retrieves rewards for the current user/session
  @override
  Future<BranchResponse> loadRewards({String bucket = 'default'}) async {
    Completer<BranchResponse> responseCompleter = Completer();

    try {
      BranchJS.credits(allowInterop((err, data) {
        if (err == null) {
          var parsedData = Map<String, int>.from(_jsObjectToDartObject(data));
          if (parsedData.isNotEmpty) {
            responseCompleter.complete(BranchResponse.success(
                result: parsedData.containsKey(bucket)
                    ? parsedData[bucket]
                    : parsedData['default']));
          } else {
            responseCompleter.complete(BranchResponse.success(result: 0));
          }
        } else {
          responseCompleter.complete(
              BranchResponse.error(errorCode: '999', errorMessage: err));
        }
      }));
    } catch (e) {
      print('loadRewards() error: $e');
      responseCompleter.complete(BranchResponse.error(
          errorCode: '-1', errorMessage: 'loadRewards() error'));
    }

    return responseCompleter.future;
  }

  ///Redeems the specified number of credits. if there are sufficient credits within it.
  ///If the number to redeem exceeds the number available in the bucket, all of the
  ///available credits will be redeemed instead.
  @override
  Future<BranchResponse> redeemRewards(
      {required int count, String bucket = 'default'}) async {
    Completer<BranchResponse> responseCompleter = Completer();

    try {
      BranchJS.redeem(count, bucket, allowInterop((err) {
        if (err == null) {
          responseCompleter.complete(BranchResponse.success(result: true));
        } else {
          responseCompleter.complete(BranchResponse.error(
              errorCode: '999', errorMessage: err.toString()));
        }
      }));
    } catch (e) {
      print('redeemRewards() error: $e');
      responseCompleter.complete(BranchResponse.error(
          errorCode: '-1', errorMessage: 'redeemRewards() error'));
    }

    return responseCompleter.future;
  }

  ///Gets the credit history
  @override
  Future<BranchResponse> getCreditHistory({String bucket = 'default'}) async {
    Completer<BranchResponse> responseCompleter = Completer();

    try {
      BranchJS.creditHistory(_dartObjectToJsObject({'bucket': bucket}),
          allowInterop((err, data) {
        if (err == null) {
          if (data != null) {
            responseCompleter.complete(
                BranchResponse.success(result: _jsObjectToDartObject(data)));
          } else {
            responseCompleter.complete(BranchResponse.success(result: {}));
          }
        } else {
          responseCompleter.complete(BranchResponse.error(
              errorCode: '999', errorMessage: err.toString()));
        }
      }));
    } catch (e) {
      print('getCreditHistory() error: $e');
      responseCompleter.complete(BranchResponse.error(
          errorCode: '-1', errorMessage: 'getCreditHistory() error'));
    }

    return responseCompleter.future;
  }

  ///Set time window for SKAdNetwork callouts in Hours (Only iOS)
  ///By default, Branch limits calls to SKAdNetwork to within 72 hours after first install.
  @override
  void setIOSSKAdNetworkMaxTime(int hours) {
    throw UnsupportedError(
        'setIOSSKAdNetworkMaxTime() Not available in Branch JS SDK');
  }

  ///Indicates whether or not this user has a custom identity specified for them. Note that this is independent of installs.
  ///If you call setIdentity, this device will have that identity associated with this user until logout is called.
  ///This includes persisting through uninstalls, as we track device id.
  // NOTE: This is not really accurate for persistent checks...
  @override
  Future<bool> isUserIdentified() async {
    return Future.value(_userIdentified);
  }

  /// request AppTracking Autorization and return AppTrackingStatus
  /// on Android returns notSupported
  @override
  Future<AppTrackingStatus> requestTrackingAuthorization() async {
    throw UnsupportedError(
        'requestTrackingAuthorization() Not available in Branch JS SDK');
  }

  /// return AppTrackingStatus
  /// on Android returns notSupported
  @override
  Future<AppTrackingStatus> getTrackingAuthorizationStatus() async {
    throw UnsupportedError(
        'getTrackingAuthorizationStatus() Not available in Branch JS SDK');
  }

  /// return advertising identifier (ie tracking data).
  /// on Android returns empty string
  @override
  Future<String> getAdvertisingIdentifier() async {
    throw UnsupportedError(
        'getAdvertisingIdentifier() Not available in Branch JS SDK');
  }
}
