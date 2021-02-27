library flutter_branch_sdk;

export 'branch_universal_object.dart';
export 'src/branch_sdk_platform_interface.dart'
    if (dart.library.io) 'src/branch_sdk_mobile.dart'
    if (dart.library.html) 'src/branch_sdk_web.dart';
