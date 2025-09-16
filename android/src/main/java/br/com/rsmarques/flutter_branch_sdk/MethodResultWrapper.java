package br.com.rsmarques.flutter_branch_sdk;

import android.os.Handler;
import android.os.Looper;

import androidx.annotation.NonNull;

import io.flutter.plugin.common.MethodChannel;

// MethodChannel.Result wrapper that responds on the platform thread.
public class MethodResultWrapper implements MethodChannel.Result {
    private final MethodChannel.Result methodResult;
    private final Handler handler;
    private boolean called = false;
    private static final String DEBUG_NAME = "FlutterBranchSDK";

    MethodResultWrapper(MethodChannel.Result result) {
        methodResult = result;
        handler = new Handler(Looper.getMainLooper());
    }

    /**
     * Checks if this is the first time the method is being called.
     * This method is synchronized to prevent race conditions in a multi-threaded environment.
     *
     * @return true if it's the first call, false otherwise.
     */
    private synchronized boolean isFirstCall() {
        if (called) {
            return false;
        }
        called = true;
        return true;
    }

    @Override
    public void success(final Object result) {
        if (!isFirstCall()) {
            return;
        }
        handler.post(
                () -> {
                    try {
                        methodResult.success(result);
                    } catch (Exception e) {
                        LogUtils.debug(DEBUG_NAME, e.getLocalizedMessage());
                    }
                });
    }

    @Override
    public void error(
            @NonNull final String errorCode, final String errorMessage, final Object errorDetails) {
        if (!isFirstCall()) {
            return;
        }
        handler.post(
                () -> {
                    try {
                        methodResult.error(errorCode, errorMessage, errorDetails);
                    } catch (Exception e) {
                        LogUtils.debug(DEBUG_NAME, e.getLocalizedMessage());
                    }
                });
    }

    @Override
    public void notImplemented() {
        if (!isFirstCall()) {
            return;
        }
        handler.post(
                () -> {
                    try {
                        methodResult.notImplemented();
                    } catch (Exception e) {
                        LogUtils.debug(DEBUG_NAME, e.getLocalizedMessage());
                    }
                });
    }
}
