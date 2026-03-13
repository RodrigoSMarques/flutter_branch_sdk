import 'package:flutter_branch_sdk/src/flutter_branch_sdk_method_channel.dart';
import 'package:flutter_branch_sdk/src/constants.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(() {
    FlutterBranchSdkMethodChannel.isInitialized = false;
  });

  test('channel constants are correct', () {
    expect(AppConstants.MESSAGE_CHANNEL, 'flutter_branch_sdk/message');
    expect(AppConstants.EVENT_CHANNEL, 'flutter_branch_sdk/event');
    expect(AppConstants.LOG_CHANNEL, 'flutter_branch_sdk/logStream');
  });

  test('handleDeepLink throws StateError when not initialized', () {
    final impl = FlutterBranchSdkMethodChannel();
    expect(impl.handleDeepLink('https://example.com'), throwsA(isA<StateError>()));
  });

  test('handleDeepLink validates URL when initialized', () async {
    FlutterBranchSdkMethodChannel.isInitialized = true;
    final impl = FlutterBranchSdkMethodChannel();

    // Empty URL
    expect(impl.handleDeepLink(''), throwsA(isA<ArgumentError>()));

    // Unsupported scheme
    expect(impl.handleDeepLink('ftp://example.com'), throwsA(isA<ArgumentError>()));

    FlutterBranchSdkMethodChannel.isInitialized = false;
  });
}
