package br.com.rsmarques.flutter_branch_sdk.src;

import android.util.Log;
import br.com.rsmarques.flutter_branch_sdk.BuildConfig;
import io.branch.referral.Branch;
import io.flutter.plugin.common.PluginRegistry;

public class FlutterBranchSdkInit{
    private static final String DEBUG_NAME = "FlutterBranchSDK";

    public static void init(PluginRegistry.Registrar registrar) {
        Log.i(DEBUG_NAME, " FlutterBranchSdkInit");

        if (BuildConfig.DEBUG) {
            Log.i(DEBUG_NAME, " DebugMode");
            Branch.enableDebugMode();
        }

        // Branch object initialization
        Branch.getAutoInstance(registrar.activity().getApplicationContext());
    }
}
