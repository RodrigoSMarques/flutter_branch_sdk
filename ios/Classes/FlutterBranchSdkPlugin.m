#import "FlutterBranchSdkPlugin.h"
#import <flutter_branch_sdk/flutter_branch_sdk-Swift.h>

@implementation FlutterBranchSdkPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterBranchSdkPlugin registerWithRegistrar:registrar];
}
@end
