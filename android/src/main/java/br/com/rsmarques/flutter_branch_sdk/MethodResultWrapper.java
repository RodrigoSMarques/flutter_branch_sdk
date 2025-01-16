package br.com.rsmarques.flutter_branch_sdk;

import android.os.Handler;
import android.os.Looper;

import io.flutter.plugin.common.MethodChannel;

// MethodChannel.Result wrapper that responds on the platform thread.
public class MethodResultWrapper implements MethodChannel.Result {
    private final MethodChannel.Result methodResult;
    private final Handler handler;
    private boolean called;

    MethodResultWrapper(MethodChannel.Result result) {
        methodResult = result;
        handler = new Handler(Looper.getMainLooper());
    }

    private synchronized boolean checkNotCalled() {
        if (called) {
            return false;
        }
        called = true;
        return true;
    }

    @Override
    public void success(final Object result) {
        if (!checkNotCalled()) {
            return;
        }
        handler.post(
                new Runnable() {
                    @Override
                    public void run() {
                        try {
                            methodResult.success(result);
                        } catch (Exception e) {
                            e.printStackTrace();
                        }
                    }
                });
    }

    @Override
    public void error(
            final String errorCode, final String errorMessage, final Object errorDetails) {
        if (!checkNotCalled()) {
            return;
        }
        handler.post(
                new Runnable() {
                    @Override
                    public void run() {
                        try {
                            methodResult.error(errorCode, errorMessage, errorDetails);
                        } catch (Exception e) {
                            e.printStackTrace();
                        }
                    }
                });
    }

    @Override
    public void notImplemented() {
        if (!checkNotCalled()) {
            return;
        }
        handler.post(
                new Runnable() {
                    @Override
                    public void run() {
                        try {
                            methodResult.notImplemented();
                        } catch (Exception e) {
                            e.printStackTrace();
                        }
                    }
                });
    }
}
