import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:flutter_branch_sdk/src/constants.dart';

void main() {
  test('channel constants are defined', () {
    expect(AppConstants.MESSAGE_CHANNEL, isNotEmpty);
    expect(AppConstants.EVENT_CHANNEL, isNotEmpty);
    expect(AppConstants.LOG_CHANNEL, isNotEmpty);
  });

  test('handleDeepLink throws StateError when SDK not initialized', () {
    expect(() => FlutterBranchSdk.handleDeepLink('https://example.com'), throwsA(isA<StateError>()));
  });
}
