package br.com.rsmarques.flutter_branch_sdk;

import android.content.Context;
import android.util.Log;

import io.branch.referral.Branch;
import io.flutter.BuildConfig;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.PluginRegistry;

public class FlutterBranchSdkInit {
    private static final String DEBUG_NAME = "FlutterBranchSDK";

    public static void init(Context context) {
        if (BuildConfig.DEBUG) {
            LogUtils.debug(DEBUG_NAME, "Branch SDK in DebugMode");
            Branch.enableLogging();
        }
        // Branch object initialization
        Branch.getAutoInstance(context);
    }
}
