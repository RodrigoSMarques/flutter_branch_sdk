package br.com.rsmarques.flutter_branch_sdk;

import android.content.Context;
import android.util.Log;

import io.branch.referral.Branch;

public class FlutterBranchSdkInit {
    private static final String DEBUG_NAME = "FlutterBranchSDK";

    public static void init(Context context) {
        ApplicationInfoHelper applicationInfoHelper = new ApplicationInfoHelper(context);

        if (applicationInfoHelper.getEnableLog()) {
            LogUtils.debug(DEBUG_NAME, "Branch SDK with log enable");
            Branch.enableLogging();
        } else  {
            Log.i(DEBUG_NAME, "Branch SDK with out log");
        }

        if (applicationInfoHelper.getEnableFacebookAds()) {
            Branch.getAutoInstance(context).enableFacebookAppLinkCheck();
        }

        // Branch object initialization
        Branch.getAutoInstance(context);
    }
}
