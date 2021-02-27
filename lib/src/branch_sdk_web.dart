import 'dart:async';
import 'dart:convert';
import 'dart:js';
import 'dart:js_util';

import '../branch_universal_object.dart';
import 'branch_sdk_platform_interface.dart';
import 'web/branch_js.dart';

/// A workaround to deep-converting an object from JS to a Dart Object.
dynamic _jsObjectToDartObject(data) => json.decode(jsonStringify(data));
dynamic _dartObjectToJsObject(data) => jsonParse(json.encode(data));
Map<String, String> _metaData = {};

/// A web implementation of the FlutterBranchSdk plugin.
class FlutterBranchSdk extends FlutterBranchSdkPlatform {
  FlutterBranchSdkPlatform getManager() => FlutterBranchSdk();

  /// Constructs a singleton instance of [FlutterBranchSdk].
  static FlutterBranchSdk? _singleton;
  factory FlutterBranchSdk() {
    if (_singleton == null) {
      _singleton = FlutterBranchSdk._();
    }
    return _singleton!;
  }

  // ignore: close_sinks
  static final StreamController<Map<String, dynamic>> _eventChannel =
      StreamController<Map<String, dynamic>>();

  FlutterBranchSdk._();

  static bool _userIdentified = false;

  String _branchKey = '';

  @override
  void initWeb(String branchKey) {
    _branchKey = branchKey;
  }

  ///Identifies the current user to the Branch API by supplying a unique identifier as a userId value
  @override
  void setIdentity(String userId) {
    BranchJS.setIdentity(userId, allowInterop((error, data) {
      if (error == null) {
        _userIdentified = true;
      }
    }));
  }

  ///Add key value pairs to all requests
  @override
  void setRequestMetadata(String key, String value) {
    _metaData[key] = value;
  }

  ///This method should be called if you know that a different person is about to use the app
  @override
  void logout() {
    BranchJS.logout(allowInterop((error) {
      if (error == null) {
        _userIdentified = false;
      }
    }));
  }

  ///Returns the last parameters associated with the link that referred the user, not really applicaple for web though
  @override
  Future<Map<dynamic, dynamic>> getLatestReferringParams() {
    final Completer<Map<dynamic, dynamic>> response = Completer();

    BranchJS.data(allowInterop((err, data) {
      if (err == null) {
        var responseData =
            Map<dynamic, dynamic>.from(_jsObjectToDartObject(data));
        response.complete(responseData);
      } else {
        response.completeError(err);
      }
    }));

    return response.future;
  }

  ///Returns the first parameters associated with the link that referred the user
  @override
  Future<Map<dynamic, dynamic>> getFirstReferringParams() {
    final Completer<Map<dynamic, dynamic>> response =
        Completer<Map<dynamic, dynamic>>();

    BranchJS.first(allowInterop((err, data) {
      if (err == null) {
        var responseData =
            Map<dynamic, dynamic>.from(_jsObjectToDartObject(data));
        response.complete(responseData);
      } else {
        response.completeError(err);
      }
    }));

    return response.future;
  }

  ///Method to change the Tracking state. If disabled SDK will not track any user data or state.
  ///SDK will not send any network calls except for deep linking when tracking is disabled
  @override
  void disableTracking(bool value) {
    BranchJS.disableTracking(value);
  }

  ///Initialises a session with the Branch API
  ///Listen click em Branch Deeplinks
  @override
  Stream<Map<dynamic, dynamic>> initSession() {
    if (_branchKey.isEmpty) {
      throw UnsupportedError('call initWeb before');
    }

    BranchJS.init(_branchKey, null, allowInterop((err, data) {
      if (err == null) {
        var parsedData = _jsObjectToDartObject(data);
        if (parsedData is Map && parsedData.containsKey("data")) {
          parsedData = parsedData["data"];
        }
        if (parsedData is String) {
          try {
            parsedData = json.decode(parsedData);
          } catch (e) {
            print('Failed to try to parse JSON: $e');
          }
        }
        _eventChannel.sink.add(parsedData);
      } else {
        _eventChannel.addError(Exception(err));
      }
    }));

    // BranchJS.addListener(listener: (String event, Object data) {

    // });

    return _eventChannel.stream;
    // throw UnsupportedError('Not implemented');
  }

  ///Use the SDK integration validator to check that you've added the Branch SDK and
  ///handle deep links correctly when you first integrate Branch into your app.
  @override
  void validateSDKIntegration() {
    throw UnsupportedError('Not available in Branch JS SDK');
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

    BranchJS.link(_dartObjectToJsObject(data), allowInterop((err, url) {
      if (err == null) {
        responseCompleter.complete(BranchResponse.success(result: url));
      } else {
        responseCompleter.completeError(BranchResponse.error(
            errorCode: err is String ? err : err.code,
            errorMessage: err.message));
      }
    }));

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

    BranchJS.logEvent(branchEvent.eventName,
        _dartObjectToJsObject({...branchEvent.toMap(), ...contentMetadata}));
  }

  ///Logs this BranchEvent to Branch for tracking and analytics
  @override
  void trackContentWithoutBuo({required BranchEvent branchEvent}) {
    BranchJS.logEvent(
        branchEvent.eventName, _dartObjectToJsObject(branchEvent.toMap()));
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
    throw UnsupportedError('Not supported by Branch JS SDK');
  }

  ///For Android: Remove the BUO from the local indexing if it is added to the local indexing already
  ///             This will remove the content from Google(Firebase) and other supported Indexing services
  ///For iOS:     Remove Branch Universal Object from Spotlight if privately indexed
  @override
  Future<bool> removeFromSearch(
      {required BranchUniversalObject buo,
      BranchLinkProperties? linkProperties}) async {
    throw UnsupportedError('Not supported by Branch JS SDK');
  }

  ///Retrieves rewards for the current user/session
  @override
  Future<BranchResponse> loadRewards({String bucket = 'default'}) async {
    Completer<BranchResponse> responseCompleter = Completer();

    BranchJS.credits(allowInterop((err, data) {
      if (err == null) {
        var parsedData = Map<String, int>.from(_jsObjectToDartObject(data));
        responseCompleter.complete(BranchResponse.success(
            result: parsedData.containsKey(bucket)
                ? parsedData[bucket]
                : parsedData["default"]));
      } else {
        responseCompleter.completeError(BranchResponse.error(
            errorCode: err is String ? err : err.code,
            errorMessage: err.message));
      }
    }));

    return responseCompleter.future;
  }

  ///Redeems the specified number of credits. if there are sufficient credits within it.
  ///If the number to redeem exceeds the number available in the bucket, all of the
  ///available credits will be redeemed instead.
  @override
  Future<BranchResponse> redeemRewards(
      {required int count, String bucket = 'default'}) async {
    Completer<BranchResponse> responseCompleter = Completer();

    BranchJS.redeem(count, bucket, allowInterop((err) {
      if (err == null) {
        responseCompleter.complete(BranchResponse.success(result: true));
      } else {
        responseCompleter.completeError(BranchResponse.error(
            errorCode: err is String ? err : err.code,
            errorMessage: err.message));
      }
    }));

    return responseCompleter.future;
  }

  ///Gets the credit history
  @override
  Future<BranchResponse> getCreditHistory({String bucket = 'default'}) async {
    Completer<BranchResponse> responseCompleter = Completer();

    BranchJS.creditHistory(_dartObjectToJsObject({"bucket": bucket}),
        allowInterop((err, data) {
      if (err == null) {
        responseCompleter.complete(
            BranchResponse.success(result: _jsObjectToDartObject(data)));
      } else {
        responseCompleter.completeError(BranchResponse.error(
            errorCode: err is String ? err : err.code,
            errorMessage: err.message));
      }
    }));

    return responseCompleter.future;
  }

  ///Set time window for SKAdNetwork callouts in Hours (Only iOS)
  ///By default, Branch limits calls to SKAdNetwork to within 72 hours after first install.
  @override
  void setIOSSKAdNetworkMaxTime(int hours) {
    throw UnsupportedError('Not available in Branch JS SDK');
  }

  ///Indicates whether or not this user has a custom identity specified for them. Note that this is independent of installs.
  ///If you call setIdentity, this device will have that identity associated with this user until logout is called.
  ///This includes persisting through uninstalls, as we track device id.
  // NOTE: This is not really accurate for persistent checks...
  @override
  Future<bool> isUserIdentified() async {
    return Future.value(_userIdentified);
  }
}
