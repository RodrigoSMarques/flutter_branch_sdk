/// This is a Flutter plugin that implemented Branch SDK - https://branch.io/
/// Branch.io helps mobile apps grow with deep links that power referral systems,
/// sharing links and invites with full attribution and analytics.
/// Supports Android, iOS and Web.

library flutter_branch_sdk;

import 'dart:typed_data';

import 'src/flutter_branch_sdk_platform_interface.dart';
import 'src/objects/app_tracking_transparency.dart';
import 'src/objects/branch_universal_object.dart';

export 'src/flutter_branch_sdk_platform_interface.dart';
export 'src/objects/app_tracking_transparency.dart';
export 'src/objects/branch_universal_object.dart';

part 'src/flutter_branch_sdk.dart';
