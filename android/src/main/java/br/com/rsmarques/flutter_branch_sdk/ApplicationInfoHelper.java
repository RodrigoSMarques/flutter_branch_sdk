package br.com.rsmarques.flutter_branch_sdk;

import android.content.Context;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;

import io.flutter.BuildConfig;

public class ApplicationInfoHelper {
    private static Context context;

    ApplicationInfoHelper(Context context) {
        this.context = context;
    }

    public static boolean getEnableLog() {
        try {
            final ApplicationInfo ai = context.getPackageManager().getApplicationInfo(context.getPackageName(), PackageManager.GET_META_DATA);
            if (ai.metaData != null) {
                if (BuildConfig.DEBUG) {
                    return ai.metaData.getBoolean("branch_enable_log",
                            true);
                } else {
                    return ai.metaData.getBoolean("branch_enable_log",
                            false);
                }
            } else {
                return BuildConfig.DEBUG;
            }
        } catch (Exception e) {
            LogUtils.debug("FlutterBranchSDK", "ApplicationInfoHelper error: " + e.getLocalizedMessage());
        }
        return false;
    }

    public static  boolean getEnableFacebookAds() {
        try {
            final ApplicationInfo ai = context.getPackageManager().getApplicationInfo(context.getPackageName(), PackageManager.GET_META_DATA);
            if (ai.metaData != null) {
                return ai.metaData.getBoolean("branch_enable_facebook_ads",
                        false);
            } else {
                return false;
            }
        } catch (Exception e) {
            LogUtils.debug("FlutterBranchSDK", "ApplicationInfoHelper error: " + e.getLocalizedMessage());
        }
        return false;
    }
}
