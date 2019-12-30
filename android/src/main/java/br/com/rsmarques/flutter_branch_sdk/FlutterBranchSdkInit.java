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
        Log.i(DEBUG_NAME, " FlutterBranchSdkInit");
        if (BuildConfig.DEBUG) {
            Log.i(DEBUG_NAME, " DebugMode");
            Branch.enableDebugMode();
        }
        // Branch object initialization
        Branch.getAutoInstance(context);
    }
}
