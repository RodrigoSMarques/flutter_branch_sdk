package br.com.rsmarques.flutter_branch_sdk;

import android.util.Log;

import io.flutter.BuildConfig;

public class LogUtils {
    public static void debug(final String tag, String message) {
        if (BuildConfig.DEBUG) {
            Log.d(tag, message);
        }
    }
}
