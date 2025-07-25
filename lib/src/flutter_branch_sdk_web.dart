// In order to *not* need this ignore, consider extracting the "web" version
// of your plugin as a separate package, instead of inlining it in the same
// package as the core of your plugin.
// ignore: avoid_web_libraries_in_flutter
import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';
import 'dart:js_interop_unsafe' as js;
import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

import 'flutter_branch_sdk_platform_interface.dart';
import 'objects/app_tracking_transparency.dart';
import 'objects/branch_attribution_level.dart';
import 'objects/branch_universal_object.dart';
import 'web/branch_js.dart';

/// A workaround to deep-converting an object from JS to a Dart Object.
dynamic _jsObjectToDartObject(data) => json.decode(jsonStringify(data));

JSAny _dartObjectToJsObject(data) => jsonParse(json.encode(data));

/// A web implementation of the FlutterBranchSdkPlatform of the FlutterBranchSdk plugin.
class FlutterBranchSdkWeb extends FlutterBranchSdkPlatform {
  /// Constructs a FlutterBranchSdkWeb
  FlutterBranchSdkWeb();

  static void registerWith(Registrar registrar) {
    FlutterBranchSdkPlatform.instance = FlutterBranchSdkWeb();
  }

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

  @override
  Future<void> init({bool enableLogging = false, BranchAttributionLevel? branchAttributionLevel}) async {
    debugPrint('For web, start the SDK in index.html');
  }

  static final StreamController<Map<String, dynamic>> _initSessionStream = StreamController<Map<String, dynamic>>();
  static bool _userIdentified = false;
  static bool isInitialized = false;

  ///Listen click em Branch Deeplinks
  @override
  Stream<Map<dynamic, dynamic>> listSession() {
    getLatestReferringParams().then((data) {
      if (data.isNotEmpty) {
        _initSessionStream.sink.add(data.map((key, value) => MapEntry('$key', value)));
      } else {
        _initSessionStream.sink.add({});
      }
    });
    return _initSessionStream.stream;
  }

  ///Returns the last parameters associated with the link that referred the user, not really applicaple for web though
  @override
  Future<Map<dynamic, dynamic>> getLatestReferringParams() {
    final Completer<Map<dynamic, dynamic>> response = Completer();

    try {
      BranchJS.data((JSAny? err, JSAny? data) {
        if (err == null) {
          if (data != null) {
            var responseData = Map<dynamic, dynamic>.from(_jsObjectToDartObject(data));
            response.complete(responseData['data_parsed'] ?? {});
          } else {
            response.complete({});
          }
        } else {
          response.completeError(err);
        }
      }.toJS);
    } catch (e) {
      debugPrint('getLatestReferringParams() error: ${e.toString()}');
      response.completeError(e);
    }
    return response.future;
  }

  ///Returns the first parameters associated with the link that referred the user
  @override
  Future<Map<dynamic, dynamic>> getFirstReferringParams() {
    final Completer<Map<dynamic, dynamic>> response = Completer<Map<dynamic, dynamic>>();

    try {
      BranchJS.first((JSAny? err, JSAny? data) {
        if (err == null) {
          if (data != null) {
            var responseData = Map<dynamic, dynamic>.from(_jsObjectToDartObject(data));
            response.complete(responseData['data_parsed'] ?? {});
          } else {
            response.complete({});
          }
        } else {
          response.completeError(err);
        }
      }.toJS);
    } catch (e) {
      debugPrint('getFirstReferringParams() error: ${e.toString()}');
      response.completeError(e);
    }
    return response.future;
  }

  ///Identifies the current user to the Branch API by supplying a unique identifier as a userId value
  @override
  void setIdentity(String userId) {
    try {
      BranchJS.setIdentity(
          userId,
          (JSAny? error, JSAny? data) {
            if (error == null) {
              _userIdentified = true;
            }
          }.toJS);
    } catch (e) {
      debugPrint('setIdentity() error: ${e.toString()}');
    }
  }

  ///This method should be called if you know that a different person is about to use the app
  @override
  void logout() {
    try {
      BranchJS.logout((JSAny? error) {
        if (error == null) {
          _userIdentified = false;
        }
      }.toJS);
    } catch (e) {
      debugPrint('logout() error: ${e.toString()}');
    }
  }

  ///Creates a short url for the BUO
  @override
  Future<BranchResponse> getShortUrl(
      {required BranchUniversalObject buo, required BranchLinkProperties linkProperties}) async {
    Map<String, dynamic> data = buo.toMap();
    linkProperties.getControlParams().forEach((key, value) {
      data[key] = value;
    });

    Map<String, dynamic> linkData = {...linkProperties.toMap(), 'data': data};
    Completer<BranchResponse> responseCompleter = Completer();

    try {
      BranchJS.link(
          _dartObjectToJsObject(linkData),
          (JSAny? err, String url) {
            if (err == null) {
              responseCompleter.complete(BranchResponse.success(result: url));
            } else {
              dynamic jsError = err;
              String errorMessage;
              if (jsError is String) {
                errorMessage = jsError;
              } else {
                errorMessage = jsError.toString(); // Como fallback, converte para string
              }
              responseCompleter.complete(BranchResponse.error(errorCode: '-1', errorMessage: errorMessage));
            }
          }.toJS);
    } catch (e) {
      debugPrint('getShortUrl() error: ${e.toString()}');
      responseCompleter.completeError(BranchResponse.error(errorCode: '-1', errorMessage: 'getShortUrl() error'));
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
    BranchResponse response = await getShortUrl(buo: buo, linkProperties: linkProperties);
    if (response.success) {
      try {
        await navigatorShare(_dartObjectToJsObject({'title': messageText, "text": buo.title, "url": response.result}))
            .toDart;
      } catch (e) {
        browserPrompt(messageText, response.result);
      }
    }
    return response;
  }

  ///Logs this BranchEvent to Branch for tracking and analytics
  @override
  void trackContent({required List<BranchUniversalObject> buo, required BranchEvent branchEvent}) {
    List<JSAny> contentItems = [];
    for (var element in buo) {
      contentItems.add(_dartObjectToJsObject(element.toMap()));
    }

    try {
      if (branchEvent.alias.isNotEmpty) {
        BranchJS.logEvent(
            branchEvent.eventName, _dartObjectToJsObject(branchEvent.toMap()), contentItems.toJS, branchEvent.alias);
      } else {
        BranchJS.logEvent(branchEvent.eventName, _dartObjectToJsObject(branchEvent.toMap()), contentItems.toJS);
      }
    } catch (e) {
      debugPrint('trackContent() error: ${e.toString()}');
    }
  }

  ///Logs this BranchEvent to Branch for tracking and analytics
  @override
  void trackContentWithoutBuo({required BranchEvent branchEvent}) {
    try {
      BranchJS.logEvent(branchEvent.eventName, _dartObjectToJsObject(branchEvent.toMap()));
    } catch (e) {
      debugPrint('trackContentWithoutBuo() error: ${e.toString()}');
    }
  }

  ///Mark the content referred by this object as viewed. This increment the view count of the contents referred by this object.
  @override
  void registerView({required BranchUniversalObject buo}) {
    try {
      BranchEvent branchEvent = BranchEvent.standardEvent(BranchStandardEvent.VIEW_ITEM);
      // This might not be exactly the same thing as BUO.registerView, but there's no clear implementation for web sdk
      trackContent(buo: [buo], branchEvent: branchEvent);
    } catch (e) {
      debugPrint('registerView() error: ${e.toString()}');
    }
  }

  ///Add key value pairs to all requests
  @override
  void setRequestMetadata(String key, String value) {
    try {
      BranchJS.setRequestMetadata(key, value);
    } catch (e) {
      debugPrint('setRequestMetadata() error: ${e.toString()}');
    }
  }

  ///For Android: Publish this BUO with Google app indexing so that the contents will be available with google search
  ///For iOS:     List items on Spotlight
  @override
  Future<bool> listOnSearch({required BranchUniversalObject buo, BranchLinkProperties? linkProperties}) async {
    debugPrint('listOnSearch() Not supported by Branch JS SDK');
    return true;
  }

  ///For Android: Remove the BUO from the local indexing if it is added to the local indexing already
  ///             This will remove the content from Google(Firebase) and other supported Indexing services
  ///For iOS:     Remove Branch Universal Object from Spotlight if privately indexed
  @override
  Future<bool> removeFromSearch({required BranchUniversalObject buo, BranchLinkProperties? linkProperties}) async {
    debugPrint('removeFromSearch() Not supported by Branch JS SDK');
    return true;
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
    debugPrint('requestTrackingAuthorization() Not supported by Branch JS SDK');
    return AppTrackingStatus.notSupported;
  }

  /// return AppTrackingStatus
  /// on Android returns notSupported
  @override
  Future<AppTrackingStatus> getTrackingAuthorizationStatus() async {
    debugPrint('getTrackingAuthorizationStatus() Not supported by Branch JS SDK');
    return AppTrackingStatus.notSupported;
  }

  /// return advertising identifier (ie tracking data).
  /// on Android returns empty string
  @override
  Future<String> getAdvertisingIdentifier() async {
    debugPrint('getAdvertisingIdentifier() Not supported by Branch JS SDK');
    return '';
  }

  ///Use the SDK integration validator to check that you've added the Branch SDK and
  ///handle deep links correctly when you first integrate Branch into your app.
  @override
  void validateSDKIntegration() {
    throw UnsupportedError('validateSDKIntegration() not available in Branch JS SDK');
  }

  ///Sets the duration in milliseconds that the system should wait for initializing
  ///a network * request.
  @override
  void setConnectTimeout(int connectTimeout) {
    debugPrint('setConnectTimeout() Not supported by Branch JS SDK');
  }

  ///Sets the duration in milliseconds that the system should wait for a response
  ///before timing out any Branch API.
  ///Default 5500 ms. Note that this is the total time allocated for all request
  ///retries as set in setRetryCount(int).
  @override
  void setTimeout(int timeout) {
    debugPrint('setTimeout() Not supported by Branch JS SDK');
  }

  ///Sets the max number of times to re-attempt a timed-out request to the Branch API, before
  /// considering the request to have failed entirely. Default to 3.
  /// Note that the the network timeout, as set in setNetworkTimeout(int),
  /// together with the retry interval value from setRetryInterval(int) will
  /// determine if the max retry count will be attempted.
  @override
  void setRetryCount(int retryCount) {
    debugPrint('setRetryCount() Not supported by Branch JS SDK');
  }

  ///Sets the amount of time in milliseconds to wait before re-attempting a
  ///timed-out request to the Branch API. Default 1000 ms.
  @override
  void setRetryInterval(int retryInterval) {
    debugPrint('setRetryInterval() Not supported by Branch JS SDK');
  }

  ///Gets the available last attributed touch data with a custom set attribution window.
  @override
  Future<BranchResponse> getLastAttributedTouchData({int? attributionWindow}) async {
    Completer<BranchResponse> responseCompleter = Completer();

    try {
      BranchJS.lastAttributedTouchData(
          attributionWindow?.toJS,
          (JSAny? err, JSAny? data) {
            if (err == null) {
              if (data != null) {
                responseCompleter.complete(BranchResponse.success(result: _jsObjectToDartObject(data)));
              } else {
                responseCompleter.complete(BranchResponse.success(result: {}));
              }
            } else {
              responseCompleter.complete(BranchResponse.error(errorCode: '999', errorMessage: err.toString()));
            }
          }.toJS);
    } catch (e) {
      debugPrint('getLastAttributedTouchData() error: ${e.toString()}');
      responseCompleter
          .complete(BranchResponse.error(errorCode: '-1', errorMessage: 'getLastAttributedTouchData() error'));
    }
    return responseCompleter.future;
  }

  ///Creates a Branch QR Code image. Returns the QR code as Uint8List.
  @override
  Future<BranchResponse> getQRCodeAsData(
      {required BranchUniversalObject buo,
      required BranchLinkProperties linkProperties,
      required BranchQrCode qrCodeSettings}) async {
    Completer<BranchResponse> responseCompleter = Completer();

    Map<String, dynamic> data = buo.toMap();
    linkProperties.getControlParams().forEach((key, value) {
      data[key] = value;
    });

    Map<String, dynamic> linkData = {...linkProperties.toMap(), 'data': data};

    try {
      BranchJS.qrCode(
          _dartObjectToJsObject(linkData),
          _dartObjectToJsObject(qrCodeSettings.toMap()),
          (JSAny? err, QrCodeData? qrCode) {
            if (err == null) {
              if (qrCode != null) {
                responseCompleter.complete(BranchResponse.success(result: qrCode.rawBuffer.toDart.asUint8List()));
              } else {
                responseCompleter.complete(BranchResponse.error(errorCode: '-1', errorMessage: 'Qrcode generate error'));
              }
            } else {
              responseCompleter.complete(BranchResponse.error(errorCode: '-1', errorMessage: err.toString()));
            }
          }.toJS);
    } catch (e) {
      responseCompleter
          .complete(BranchResponse.error(errorCode: '-1', errorMessage: 'qrCode generate error ${e.toString()}'));
    }
    return responseCompleter.future;
  }

  ///Creates a Branch QR Code image. Returns the QR code as a Image.
  @override
  Future<BranchResponse> getQRCodeAsImage(
      {required BranchUniversalObject buo,
      required BranchLinkProperties linkProperties,
      required BranchQrCode qrCodeSettings}) async {
    try {
      BranchResponse response =
          await getQRCodeAsData(buo: buo, linkProperties: linkProperties, qrCodeSettings: qrCodeSettings);
      if (response.success) {
        return BranchResponse.success(
            result: Image.memory(
          response.result,
        ));
      } else {
        return BranchResponse.error(errorCode: response.errorCode, errorMessage: response.errorMessage);
      }
    } catch (e) {
      return BranchResponse.error(errorCode: "-1", errorMessage: 'qrCode generate error ${e.toString()}');
    }
  }

  @override
  void shareWithLPLinkMetadata(
      {required BranchUniversalObject buo,
      required BranchLinkProperties linkProperties,
      required Uint8List icon,
      required String title}) {
    try {
      showShareSheet(buo: buo, linkProperties: linkProperties, messageText: title);
    } catch (error) {
      debugPrint('shareWithLPLinkMetadata() error: ${error.toString()}');
    }
  }

  ///Have Branch end the current deep link session and start a new session with the provided URL.
  @override
  void handleDeepLink(String url) {
    try {
      globalContext.callMethodVarArgs('open'.toJS, [url.toJS, '_self'.toJS]);
    } catch (e) {
      debugPrint('handleDeepLink() error: ${e.toString()}');
    }
  }

  /// Add a Partner Parameter for Facebook.
  /// Once set, this parameter is attached to installs, opens and events until cleared or the app restarts.
  /// See Facebook's documentation for details on valid parameters
  @override
  void addFacebookPartnerParameter({required String key, required String value}) {
    debugPrint('addFacebookPartnerParameter() Not supported by Branch JS SDK');
  }

  /// Clears all Partner Parameters
  @override
  void clearPartnerParameters() {
    debugPrint('clearPartnerParameters() Not supported by Branch JS SDK');
  }

  /// Add the pre-install campaign analytics
  @override
  void setPreinstallCampaign(String value) {
    debugPrint('setPreinstallCampaign() Not supported by Branch JS SDK');
  }

  /// Add the pre-install campaign analytics
  @override
  void setPreinstallPartner(String value) {
    debugPrint('setPreinstallPartner() Not supported by Branch JS SDK');
  }

  ///Add a Partner Parameter for Snap.
  ///Once set, this parameter is attached to installs, opens and events until cleared or the app restarts.
  @override
  void addSnapPartnerParameter({required String key, required String value}) {
    debugPrint('addSnapPartnerParameter() Not supported by Branch JS SDK');
  }

  void close() {
    _initSessionStream.close();
  }

  /// Sets the value of parameters required by Google Conversion APIs for DMA Compliance in EEA region.
  /// [eeaRegion] `true` If European regulations, including the DMA, apply to this user and conversion.
  /// [adPersonalizationConsent] `true` If End user has granted/denied ads personalization consent.
  /// [adUserDataUsageConsent] `true If User has granted/denied consent for 3P transmission of user level data for ads.
  @override
  void setDMAParamsForEEA(
      {required bool eeaRegion, required bool adPersonalizationConsent, required bool adUserDataUsageConsent}) {
    try {
      BranchJS.setDMAParamsForEEA(eeaRegion, adPersonalizationConsent, adUserDataUsageConsent);
    } catch (e) {
      debugPrint('handleDeepLink() error: ${e.toString()}');
    }
  }

  /// Sets the consumer protection attribution level.
  @override
  void setConsumerProtectionAttributionLevel(BranchAttributionLevel branchAttributionLevel) {
    debugPrint('setConsumerProtectionAttributionLevel() Not supported by Branch JS SDK');
  }
}
