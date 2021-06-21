package br.com.rsmarques.flutter_branch_sdk;

import android.app.Activity;
import android.app.Application;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.UiThread;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.HashMap;
import java.util.Map;

import io.branch.indexing.BranchUniversalObject;
import io.branch.referral.Branch;
import io.branch.referral.BranchError;
import io.branch.referral.util.BranchEvent;
import io.branch.referral.util.LinkProperties;
import io.branch.referral.util.ShareSheetStyle;
import io.branch.referral.validators.IntegrationValidator;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.android.FlutterFragmentActivity;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.EventChannel.StreamHandler;
import io.flutter.plugin.common.EventChannel.EventSink;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.NewIntentListener;
import io.flutter.plugin.common.PluginRegistry.Registrar;

public class FlutterBranchSdkPlugin implements FlutterPlugin, MethodCallHandler, StreamHandler, NewIntentListener, ActivityAware,
        Application.ActivityLifecycleCallbacks {
    private static final String DEBUG_NAME = "FlutterBranchSDK";
    private Activity activity;
    private Context context;
    private ActivityPluginBinding activityPluginBinding;

    private MethodChannel methodChannel;
    private EventChannel eventChannel;

    private static final String MESSAGE_CHANNEL = "flutter_branch_sdk/message";
    private static final String EVENT_CHANNEL = "flutter_branch_sdk/event";
    private EventSink eventSink = null;
    private Map<String, Object> initialParams = null;
    private BranchError initialError = null;

    private FlutterBranchSdkHelper branchSdkHelper = new FlutterBranchSdkHelper();

    /**---------------------------------------------------------------------------------------------
     Plugin registry
     --------------------------------------------------------------------------------------------**/
    public static void registerWith(Registrar registrar) {
        LogUtils.debug(DEBUG_NAME, "registerWith call");
        if (registrar.activity() == null) {
            // When a background flutter view tries to register the plugin, the registrar has no activity.
            // We stop the registration process as this plugin is foreground only.
            return;
        }
        FlutterBranchSdkPlugin plugin = new FlutterBranchSdkPlugin();
        plugin.setupChannels(registrar.messenger(), registrar.activity().getApplicationContext());
        plugin.setActivity(registrar.activity());
        registrar.addNewIntentListener(plugin);
    }

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
        LogUtils.debug(DEBUG_NAME, "onAttachedToEngine call");
        setupChannels(binding.getBinaryMessenger(), binding.getApplicationContext());
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        LogUtils.debug(DEBUG_NAME, "onDetachedFromEngine call");
        teardownChannels();
    }

    private void setupChannels(BinaryMessenger messenger, Context context) {
        LogUtils.debug(DEBUG_NAME, "setupChannels call");
        this.context = context;

        methodChannel = new MethodChannel(messenger, MESSAGE_CHANNEL);
        eventChannel = new EventChannel(messenger, EVENT_CHANNEL);

        methodChannel.setMethodCallHandler(this);
        eventChannel.setStreamHandler(this);

        FlutterBranchSdkInit.init(context);
    }

    private void setActivity(Activity activity) {
        LogUtils.debug(DEBUG_NAME, "setActivity call");
        this.activity = activity;
        activity.getApplication().registerActivityLifecycleCallbacks(this);

        if (this.activity != null && FlutterFragmentActivity.class.isAssignableFrom(activity.getClass())) {
                Branch.sessionBuilder(activity).withCallback(branchReferralInitListener).withData(activity.getIntent() != null ? activity.getIntent().getData() : null).init();
        }
    }

    private void teardownChannels() {
        LogUtils.debug(DEBUG_NAME, "teardownChannels call");
        this.activityPluginBinding = null;
        this.activity = null;
        this.context = null;
    }

    /**---------------------------------------------------------------------------------------------
     ActivityAware Interface Methods
     --------------------------------------------------------------------------------------------**/
    @Override
    public void onAttachedToActivity(ActivityPluginBinding activityPluginBinding) {
        LogUtils.debug(DEBUG_NAME, "onAttachedToActivity call");
        this.activityPluginBinding = activityPluginBinding;
        setActivity(activityPluginBinding.getActivity());
        activityPluginBinding.addOnNewIntentListener(this);
    }

    @Override
    public void onDetachedFromActivity() {
        LogUtils.debug(DEBUG_NAME, "onDetachedFromActivity call");
        activityPluginBinding.removeOnNewIntentListener(this);
        this.activity = null;
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {
        LogUtils.debug(DEBUG_NAME, "onDetachedFromActivityForConfigChanges call");
        onDetachedFromActivity();
    }

    @Override
    public void onReattachedToActivityForConfigChanges(ActivityPluginBinding activityPluginBinding) {
        LogUtils.debug(DEBUG_NAME, "onReattachedToActivityForConfigChanges call");
        onAttachedToActivity(activityPluginBinding);
    }

    /**---------------------------------------------------------------------------------------------
     StreamHandler Interface Methods
     --------------------------------------------------------------------------------------------**/
    @Override
    public void onListen(Object o, EventChannel.EventSink eventSink) {
        LogUtils.debug(DEBUG_NAME, "onListen call");
        this.eventSink = new MainThreadEventSink(eventSink);
        if (initialParams != null) {
            eventSink.success(initialParams);
            initialParams = null;
            initialError = null;
        } else if (initialError != null) {
            eventSink.error(String.valueOf(initialError.getErrorCode()), initialError.getMessage(),null);
            initialParams = null;
            initialError = null;
        }
    }

    @Override
    public void onCancel(Object o) {
        LogUtils.debug(DEBUG_NAME, "onCancel call");
        this.eventSink = new MainThreadEventSink(null);
        initialError = null;
        initialParams = null;
    }

    /**---------------------------------------------------------------------------------------------
     ActivityLifecycleCallbacks Interface Methods
     --------------------------------------------------------------------------------------------**/
    @Override
    public void onActivityCreated(Activity activity, Bundle bundle) {}

    @Override
    public void onActivityStarted(Activity activity) {
        LogUtils.debug(DEBUG_NAME, "onActivityStarted call");
        Branch.sessionBuilder(activity).withCallback(branchReferralInitListener).withData(activity.getIntent() != null ? activity.getIntent().getData() : null).init();
    }

    @Override
    public void onActivityResumed(Activity activity) {}

    @Override
    public void onActivityPaused(Activity activity) {}

    @Override
    public void onActivityStopped(Activity activity) {
        LogUtils.debug(DEBUG_NAME, "onActivityStopped call");
    }

    @Override
    public void onActivitySaveInstanceState(Activity activity, Bundle bundle) {}

    @Override
    public void onActivityDestroyed(Activity activity) {
        LogUtils.debug(DEBUG_NAME, "onActivityDestroyed call");
        if (this.activity == activity) {
            activity.getApplication().unregisterActivityLifecycleCallbacks(this);
        }
    }

    /**---------------------------------------------------------------------------------------------
     NewIntentListener Interface Methods
     --------------------------------------------------------------------------------------------**/
    @Override
    public boolean onNewIntent(Intent intent) {
        LogUtils.debug(DEBUG_NAME, "onNewIntent call");
        if (this.activity != null) {
            this.activity.setIntent(intent);
            Branch.sessionBuilder(this.activity).withCallback(branchReferralInitListener).reInit();
        }
        return false;
    }

    /**---------------------------------------------------------------------------------------------
     MethodCallHandler Interface Methods
     --------------------------------------------------------------------------------------------**/
    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result rawResult) {
        Result result = new MethodResultWrapper(rawResult);
        switch (call.method) {
            case "getShortUrl":
                getShortUrl(call, result);
                break;
            case "showShareSheet":
                showShareSheet(call, result);
                break;
            case "registerView":
                registerView(call);
                break;
            case "listOnSearch":
                listOnSearch(call, result);
                break;
            case "removeFromSearch":
                removeFromSearch(call, result);
                break;
            case "trackContent":
                trackContent(call);
                break;
            case "trackContentWithoutBuo":
                trackContentWithoutBuo(call);
                break;
            case "setIdentity":
                setIdentity(call);
                break;
            case "setRequestMetadata":
                setRequestMetadata(call);
                break;
            case "logout":
                logout();
                break;
            case "getLatestReferringParams":
                getLatestReferringParams(result);
                break;
            case "getFirstReferringParams":
                getFirstReferringParams(result);
                break;
            case "setTrackingDisabled":
                setTrackingDisabled(call);
                break;
            case "validateSDKIntegration":
                validateSDKIntegration();
                break;
            case "loadRewards":
                loadRewards(call, result);
                break;
            case "redeemRewards":
                redeemRewards(call, result);
                break;
            case "getCreditHistory":
                getCreditHistory(call, result);
                break;
            case "isUserIdentified":
                isUserIdentified(result);
                break;
            default:
                result.notImplemented();
        }
    }

    /**---------------------------------------------------------------------------------------------
     Branch SDK Call Methods
     --------------------------------------------------------------------------------------------**/
    private Branch.BranchReferralInitListener branchReferralInitListener = new
            Branch.BranchReferralInitListener() {
                @Override
                public void onInitFinished(JSONObject params, BranchError error) {
                    if (error == null) {
                        LogUtils.debug(DEBUG_NAME, "BranchReferralInitListener - params: " + params.toString());
                        try {
                            initialParams = branchSdkHelper.paramsToMap(params);
                        } catch (JSONException e) {
                            LogUtils.debug(DEBUG_NAME, "BranchReferralInitListener - error to Map: " + e.getLocalizedMessage());
                            return;
                        }
                        if (eventSink != null) {
                            eventSink.success(initialParams);
                            initialParams = null;
                        }
                    } else {
                        if (error.getErrorCode() == BranchError.ERR_BRANCH_ALREADY_INITIALIZED || error.getErrorCode() == BranchError.ERR_IMPROPER_REINITIALIZATION) {
                            return;
                        }
                        LogUtils.debug(DEBUG_NAME, "BranchReferralInitListener - error: " + error.toString());
                        if (eventSink != null) {
                            eventSink.error(String.valueOf(error.getErrorCode()), error.getMessage(),null);
                            initialError = null;
                        } else {
                            initialError = error;
                        }
                    }
                }
            };

    private void validateSDKIntegration() {
        IntegrationValidator.validate(activity);
    }

    private void getShortUrl(MethodCall call, final Result result) {
        if (!(call.arguments instanceof Map)) {
            throw new IllegalArgumentException("Map argument expected");
        }

        HashMap<String, Object> argsMap = (HashMap<String, Object>) call.arguments;
        BranchUniversalObject buo = branchSdkHelper.convertToBUO((HashMap<String, Object>) argsMap.get("buo"));

        LinkProperties linkProperties = branchSdkHelper.convertToLinkProperties((HashMap<String, Object>) argsMap.get("lp"));

        final Map<String, Object> response = new HashMap<>();

        buo.generateShortUrl(activity, linkProperties, new Branch.BranchLinkCreateListener() {
            @Override
            public void onLinkCreate(String url, BranchError error) {

                if (error == null) {
                    LogUtils.debug(DEBUG_NAME, "Branch link to share: " + url);
                    response.put("success", true);
                    response.put("url", url);
                } else {
                    response.put("success", false);
                    response.put("errorCode", String.valueOf(error.getErrorCode()));
                    response.put("errorMessage", error.getMessage());
                }
                result.success(response);
            }
        });
    }

    private void showShareSheet(MethodCall call, final Result result) {
        if (!(call.arguments instanceof Map)) {
            throw new IllegalArgumentException("Map argument expected");
        }
        HashMap<String, Object> argsMap = (HashMap<String, Object>) call.arguments;
        BranchUniversalObject buo = branchSdkHelper.convertToBUO((HashMap<String, Object>) argsMap.get("buo"));

        LinkProperties linkProperties = branchSdkHelper.convertToLinkProperties((HashMap<String, Object>) argsMap.get("lp"));
        String messageText = (String) argsMap.get("messageText");
        String messageTitle = (String) argsMap.get("messageTitle");
        String sharingTitle = (String) argsMap.get("sharingTitle");

        final Map<String, Object> response = new HashMap<>();

        ShareSheetStyle shareSheetStyle = new ShareSheetStyle(activity, messageTitle, messageText)
                .setAsFullWidthStyle(true)
                .setSharingTitle(sharingTitle);

        buo.showShareSheet(activity,
                linkProperties,
                shareSheetStyle,
                new Branch.ExtendedBranchLinkShareListener() {
                    @Override
                    public void onShareLinkDialogLaunched() {
                    }

                    @Override
                    public void onShareLinkDialogDismissed() {
                    }

                    @Override
                    public void onLinkShareResponse(String sharedLink, String sharedChannel, BranchError error) {
                        if (error == null) {
                            LogUtils.debug(DEBUG_NAME, "Branch link share: " + sharedLink);
                            response.put("success", Boolean.valueOf(true));
                            response.put("url", sharedLink);
                        } else {
                            response.put("success", Boolean.valueOf(false));
                            response.put("errorCode", String.valueOf(error.getErrorCode()));
                            response.put("errorMessage", error.getMessage());
                        }
                        result.success(response);
                    }

                    @Override
                    public void onChannelSelected(String channelName) {

                    }

                    @Override
                    public boolean onChannelSelected(String channelName, BranchUniversalObject buo, LinkProperties linkProperties) {
                        return false;
                    }
                });
    }

    private void registerView(MethodCall call) {
        LogUtils.debug(DEBUG_NAME, "registerView call");
        if (!(call.arguments instanceof Map)) {
            throw new IllegalArgumentException("Map argument expected");
        }
        HashMap<String, Object> argsMap = (HashMap<String, Object>) call.arguments;
        final BranchUniversalObject buo = branchSdkHelper.convertToBUO((HashMap<String, Object>) argsMap.get("buo"));

        new Handler(Looper.getMainLooper()).post(new Runnable() {
            @Override
            public void run() {
                buo.registerView();
            }
        });
    }

    private void listOnSearch(MethodCall call, Result result) {
        LogUtils.debug(DEBUG_NAME, "listOnSearch call");
        if (!(call.arguments instanceof Map)) {
            throw new IllegalArgumentException("Map argument expected");
        }
        HashMap<String, Object> argsMap = (HashMap<String, Object>) call.arguments;
        BranchUniversalObject buo = branchSdkHelper.convertToBUO((HashMap<String, Object>) argsMap.get("buo"));
        if (argsMap.containsKey("lp")) {
            LinkProperties linkProperties = branchSdkHelper.convertToLinkProperties((HashMap<String, Object>) argsMap.get("lp"));
            buo.listOnGoogleSearch(context, linkProperties);
        } else {
            buo.listOnGoogleSearch(context);
        }
        result.success(Boolean.valueOf(true));
    }

    private void removeFromSearch(MethodCall call, Result result) {
        LogUtils.debug(DEBUG_NAME, "removeFromSearch call");
        if (!(call.arguments instanceof Map)) {
            throw new IllegalArgumentException("Map argument expected");
        }
        HashMap<String, Object> argsMap = (HashMap<String, Object>) call.arguments;
        BranchUniversalObject buo = branchSdkHelper.convertToBUO((HashMap<String, Object>) argsMap.get("buo"));
        if (argsMap.containsKey("lp")) {
            LinkProperties linkProperties = branchSdkHelper.convertToLinkProperties((HashMap<String, Object>) argsMap.get("lp"));
            buo.removeFromLocalIndexing(context, linkProperties);
        } else {
            buo.removeFromLocalIndexing(context);
        }
        result.success(Boolean.valueOf(true));
    }

    private void trackContent(MethodCall call) {
        LogUtils.debug(DEBUG_NAME, "trackContent call");
        if (!(call.arguments instanceof Map)) {
            throw new IllegalArgumentException("Map argument expected");
        }
        HashMap<String, Object> argsMap = (HashMap<String, Object>) call.arguments;
        final BranchUniversalObject buo = branchSdkHelper.convertToBUO((HashMap<String, Object>) argsMap.get("buo"));
        final BranchEvent event = branchSdkHelper.convertToEvent((HashMap<String, Object>) argsMap.get("event"));

        new Handler(Looper.getMainLooper()).post(new Runnable() {
            @Override
            public void run() {
                event.addContentItems(buo).logEvent(context);
            }
        });
    }

    private void trackContentWithoutBuo(MethodCall call) {
        LogUtils.debug(DEBUG_NAME, "trackContentWithoutBuo call");
        if (!(call.arguments instanceof Map)) {
            throw new IllegalArgumentException("Map argument expected");
        }
        HashMap<String, Object> argsMap = (HashMap<String, Object>) call.arguments;
        final BranchEvent event = branchSdkHelper.convertToEvent((HashMap<String, Object>) argsMap.get("event"));

        new Handler(Looper.getMainLooper()).post(new Runnable() {
            @Override
            public void run() {
                event.logEvent(context);
            }
        });
    }

    private void setIdentity(MethodCall call) {
        LogUtils.debug(DEBUG_NAME, "setIdentity call");
        if (!(call.arguments instanceof Map)) {
            throw new IllegalArgumentException("Map argument expected");
        }
        final String userId = call.argument("userId");

        new Handler(Looper.getMainLooper()).post(new Runnable() {
            @Override
            public void run() {
                Branch.getAutoInstance(context).setIdentity(userId);
            }
        });
    }

    private void setRequestMetadata(MethodCall call) {
        LogUtils.debug(DEBUG_NAME, "setRequestMetadata call");
        if (!(call.arguments instanceof Map)) {
            throw new IllegalArgumentException("Map argument expected");
        }
        final String key = call.argument("key");
        final String value = call.argument("value");

        new Handler(Looper.getMainLooper()).post(new Runnable() {
            @Override
            public void run() {
                Branch.getAutoInstance(context).setRequestMetadata(key, value);
            }
        });
    }

    private void logout() {
        LogUtils.debug(DEBUG_NAME, "logout call");

        new Handler(Looper.getMainLooper()).post(new Runnable() {
            @Override
            public void run() {
                Branch.getAutoInstance(context).logout();
            }
        });
    }

    private void getLatestReferringParams(Result result) {
        LogUtils.debug(DEBUG_NAME, "getLatestReferringParams call");
        JSONObject sessionParams = Branch.getAutoInstance(context).getLatestReferringParams();
        try {
            result.success(branchSdkHelper.paramsToMap(sessionParams));
        } catch (JSONException e) {
            e.printStackTrace();
            result.error(DEBUG_NAME, e.getMessage(), null);
        }
    }

    private void getFirstReferringParams(Result result) {
        LogUtils.debug(DEBUG_NAME, "getFirstReferringParams call");
        JSONObject sessionParams = Branch.getAutoInstance(context).getFirstReferringParams();
        try {
            result.success(branchSdkHelper.paramsToMap(sessionParams));
        } catch (JSONException e) {
            e.printStackTrace();
            result.error(DEBUG_NAME, e.getMessage(), null);
        }
    }

    private void setTrackingDisabled(MethodCall call) {
        LogUtils.debug(DEBUG_NAME, "setTrackingDisabled call");
        if (!(call.arguments instanceof Map)) {
            throw new IllegalArgumentException("Map argument expected");
        }
        final boolean value = call.argument("disable");

        new Handler(Looper.getMainLooper()).post(new Runnable() {
            @Override
            public void run() {
                Branch.getAutoInstance(context).disableTracking(value);
            }
        });
    }

    private void loadRewards(final MethodCall call, final Result result) {
        LogUtils.debug(DEBUG_NAME, "loadRewards call");
        final Map<String, Object> response = new HashMap<>();
        Branch.getAutoInstance(context).loadRewards(new Branch.BranchReferralStateChangedListener() {
            @Override
            public void onStateChanged(boolean changed, @Nullable BranchError error) {
                int credits;
                if (error == null) {
                    if (!call.hasArgument("bucket")) {
                        credits = Branch.getAutoInstance(context).getCredits();
                    } else {
                        credits = Branch.getAutoInstance(context).getCreditsForBucket(call.argument("bucket").toString());
                    }
                    response.put("success", Boolean.valueOf(true));
                    response.put("credits", credits);
                } else {
                    response.put("success", Boolean.valueOf(false));
                    response.put("errorCode", String.valueOf(error.getErrorCode()));
                    response.put("errorMessage", error.getMessage());
                }
                result.success(response);
            }
        });
    }

    private void redeemRewards(final MethodCall call, final Result result) {
        LogUtils.debug(DEBUG_NAME, "redeemRewards call");
        if (!(call.arguments instanceof Map)) {
            throw new IllegalArgumentException("Map argument expected");
        }

        final int count = call.argument("count");
        final Map<String, Object> response = new HashMap<>();

        if (!call.hasArgument("bucket")) {
            Branch.getAutoInstance(context).redeemRewards(count, new Branch.BranchReferralStateChangedListener() {
                @Override
                public void onStateChanged(boolean changed, @Nullable BranchError error) {
                    if (error == null)  {
                        response.put("success", Boolean.valueOf(true));
                    } else {
                        response.put("success", Boolean.valueOf(false));
                        response.put("errorCode", String.valueOf(error.getErrorCode()));
                        response.put("errorMessage", error.getMessage());
                    }
                    result.success(response);
                }
            });
        } else {
            Branch.getAutoInstance(context).redeemRewards(call.argument("bucket").toString(), count, new Branch.BranchReferralStateChangedListener() {
                @Override
                public void onStateChanged(boolean changed, @Nullable BranchError error) {
                    if (error == null)  {
                        response.put("success", Boolean.valueOf(true));
                    } else {
                        response.put("success", Boolean.valueOf(false));
                        response.put("errorCode", String.valueOf(error.getErrorCode()));
                        response.put("errorMessage", error.getMessage());
                    }
                    result.success(response);
                }
            });
        }
    }

    private void getCreditHistory(final MethodCall call, final Result result) {
        LogUtils.debug(DEBUG_NAME, "getCreditHistory call");
        if (!(call.arguments instanceof Map)) {
            throw new IllegalArgumentException("Map argument expected");
        }
        final Map<String, Object> response = new HashMap<>();

        if (!call.hasArgument("bucket")) {
            Branch.getAutoInstance(context).getCreditHistory(new Branch.BranchListResponseListener() {
                @Override
                public void onReceivingResponse(JSONArray list, BranchError error) {
                    if (error == null)  {
                        response.put("success", Boolean.valueOf(true));
                        JSONObject jo = new JSONObject();
                        try {
                            jo.put("history", list);
                            response.put("data", branchSdkHelper.paramsToMap(jo));
                        } catch (JSONException e) {
                            e.printStackTrace();
                        }
                    } else {
                        response.put("success", Boolean.valueOf(false));
                        response.put("errorCode", String.valueOf(error.getErrorCode()));
                        response.put("errorMessage", error.getMessage());
                    }
                    result.success(response);
                }
            });
        } else {
            Branch.getAutoInstance(context).getCreditHistory(call.argument("bucket").toString(), new Branch.BranchListResponseListener() {
                @Override
                public void onReceivingResponse(JSONArray list, BranchError error) {
                    if (error == null)  {
                        response.put("success", Boolean.valueOf(true));
                        JSONObject jo = new JSONObject();
                        try {
                            jo.put("history", list);
                            response.put("data", branchSdkHelper.paramsToMap(jo));
                        } catch (JSONException e) {
                            e.printStackTrace();
                        }

                    } else {
                        response.put("success", Boolean.valueOf(false));
                        response.put("errorCode", String.valueOf(error.getErrorCode()));
                        response.put("errorMessage", error.getMessage());
                    }
                    result.success(response);
                }
            });
        }
    }

    private void isUserIdentified(Result result) {
        LogUtils.debug(DEBUG_NAME, "isUserIdentified call");
        result.success(Branch.getAutoInstance(context).isUserIdentified());
    }

    // MethodChannel.Result wrapper that responds on the platform thread.
    private static class MethodResultWrapper implements Result {
        private Result methodResult;
        private Handler handler;

        MethodResultWrapper(Result result) {
            methodResult = result;
            handler = new Handler(Looper.getMainLooper());
        }

        @Override
        public void success(final Object result) {
            handler.post(
                    new Runnable() {
                        @Override
                        public void run() {
                            methodResult.success(result);
                        }
                    });
        }

        @Override
        public void error(
                final String errorCode, final String errorMessage, final Object errorDetails) {
            handler.post(
                    new Runnable() {
                        @Override
                        public void run() {
                            methodResult.error(errorCode, errorMessage, errorDetails);
                        }
                    });
        }

        @Override
        public void notImplemented() {
            handler.post(
                    new Runnable() {
                        @Override
                        public void run() {
                            methodResult.notImplemented();
                        }
                    });
        }
    }

    private static class MainThreadEventSink implements EventChannel.EventSink {
        private EventChannel.EventSink eventSink;
        private Handler handler;

        MainThreadEventSink(EventChannel.EventSink eventSink) {
            this.eventSink = eventSink;
            handler = new Handler(Looper.getMainLooper());
        }

        @Override
        public void success(final Object o) {
            handler.post(new Runnable() {
                @Override
                public void run() {
                    if (eventSink != null) {
                        eventSink.success(o);
                    }
                }
            });
        }

        @Override
        public void error(final String s, final String s1, final Object o) {
            handler.post(new Runnable() {
                @Override
                public void run() {
                    if (eventSink != null) {
                        eventSink.error(s, s1, o);
                    }
                }
            });
        }

        @Override
        public void endOfStream() {
            handler.post(new Runnable() {
                @Override
                public void run() {
                    if (eventSink != null) {
                        eventSink.endOfStream();
                    }
                }
            });
        }
    }
}


