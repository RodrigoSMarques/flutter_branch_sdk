package br.com.rsmarques.flutter_branch_sdk;

import android.content.Context;

import io.branch.referral.Branch;

public class FlutterBranchSdkInit {
    private static final String DEBUG_NAME = "FlutterBranchSDK";
    private static final String PLUGIN_NAME = "Flutter";
    private static final String PLUGIN_VERSION = "8.0.0";

    public static void init(Context context) {
        LogUtils.debug(DEBUG_NAME, "SDK Init");
        Branch.expectDelayedSessionInitialization(true);
        Branch.registerPlugin(PLUGIN_NAME, br.com.rsmarques.flutter_branch_sdk.BuildConfig.FBRANCH_VERSION);
        Branch.getAutoInstance(context);
    }
}
