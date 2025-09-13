import 'package:flutter/foundation.dart' show PlatformDispatcher;
import 'package:flutter/material.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';

import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrintStack(stackTrace: stack);
    return true;
  };

  //FlutterBranchSdk.setPreinstallCampaign('My Campaign Name');
  //FlutterBranchSdk.setPreinstallPartner('Branch \$3p Parameter Value');
  /*
  FlutterBranchSdk.addFacebookPartnerParameter(
      key: 'em',
      value:
          '11234e56af071e9c79927651156bd7a10bca8ac34672aba121056e2698ee7088');
  FlutterBranchSdk.addSnapPartnerParameter(
      key: 'hashed_email_address',
      value:
          '11234e56af071e9c79927651156bd7a10bca8ac34672aba121056e2698ee7088');
  FlutterBranchSdk.setRequestMetadata('key1', 'value1');
  FlutterBranchSdk.setRequestMetadata('key2', 'value2');
  */

  FlutterBranchSdk.setAPIUrl('https://api2.branch.io');
  FlutterBranchSdk.setAnonID('1234556');
  FlutterBranchSdk.setSDKWaitTimeForThirdPartyAPIs(2.5);

  await FlutterBranchSdk.init(enableLogging: true, branchAttributionLevel: BranchAttributionLevel.FULL);
  FlutterBranchSdk.setConsumerProtectionAttributionLevel(BranchAttributionLevel.FULL);

  /*
  AppTrackingStatus status = await FlutterBranchSdk.requestTrackingAuthorization();
  if (status == AppTrackingStatus.notSupported) {
    debugPrint('not supported');
  }
  FlutterBranchSdk.disableTracking(true);
   */
  runApp(const MyApp());
}
