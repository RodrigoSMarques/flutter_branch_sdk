import 'package:flutter/material.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';

import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //FlutterBranchSdk.setPreinstallCampaign('My Campaign Name');
  //FlutterBranchSdk.setPreinstallPartner('Branch \$3p Parameter Value');
  //FlutterBranchSdk.clearPartnerParameters();
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
  FlqutterBranchSdk.setRequestMetadata('key2', 'value2');
  */
  //await FlutterBranchSdk.requestTrackingAuthorization();
  await FlutterBranchSdk.init(enableLogging: true, disableTracking: false);

  runApp(const MyApp());
}
