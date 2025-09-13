package br.com.rsmarques.flutter_branch_sdk;

import android.os.Handler;
import android.os.Looper;

import io.flutter.plugin.common.EventChannel;

public class MainThreadEventSink implements EventChannel.EventSink {
    private final EventChannel.EventSink eventSink;
    private final Handler handler;
    private final String DEBUG_NAME = "FlutterBranchSDK";

    MainThreadEventSink(EventChannel.EventSink eventSink) {
        this.eventSink = eventSink;
        handler = new Handler(Looper.getMainLooper());
    }

    @Override
    public void success(final Object o) {
        handler.post(() -> {
            try {
                if (eventSink != null) {
                    eventSink.success(o);
                }
            } catch (Exception e) {
                LogUtils.debug(DEBUG_NAME, e.getLocalizedMessage());
            }
        });
    }

    @Override
    public void error(final String s, final String s1, final Object o) {
        handler.post(() -> {
            try {
                if (eventSink != null) {
                    eventSink.error(s, s1, o);
                }
            } catch (Exception e) {
                LogUtils.debug(DEBUG_NAME, e.getLocalizedMessage());
            }
        });
    }

    @Override
    public void endOfStream() {
        handler.post(() -> {
            try {
                if (eventSink != null) {
                    eventSink.endOfStream();
                }
            } catch (Exception e) {
                LogUtils.debug(DEBUG_NAME, e.getLocalizedMessage());
            }
        });
    }
}
