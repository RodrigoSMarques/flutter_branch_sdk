package br.com.rsmarques.flutter_branch_sdk;

import android.app.Activity;
import android.app.Application;
import android.content.Context;
import android.content.Intent;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;

import androidx.annotation.NonNull;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import io.branch.indexing.BranchUniversalObject;
import io.branch.referral.Branch;
import io.branch.referral.BranchError;
import io.branch.referral.QRCode.BranchQRCode;
import io.branch.referral.ServerRequestGetLATD;
import io.branch.referral.util.BranchEvent;
import io.branch.referral.util.LinkProperties;
import io.branch.referral.util.ShareSheetStyle;
import io.branch.referral.validators.IntegrationValidator;
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

public class FlutterBranchSdkPlugin implements FlutterPlugin, MethodCallHandler, StreamHandler, NewIntentListener, ActivityAware,
        Application.ActivityLifecycleCallbacks {
    private static final String DEBUG_NAME = "FlutterBranchSDK";
    private static final String MESSAGE_CHANNEL = "flutter_branch_sdk/message";
    private static final String EVENT_CHANNEL = "flutter_branch_sdk/event";
    private Activity activity;
    private Context context;
    private ActivityPluginBinding activityPluginBinding;
    private EventSink eventSink = null;
    private Map<String, Object> sessionParams = null;
    private BranchError initialError = null;
    private final FlutterBranchSdkHelper branchSdkHelper = new FlutterBranchSdkHelper();
    private final JSONObject requestMetadata = new JSONObject();
    private final JSONObject facebookParameters = new JSONObject();
    private final JSONObject snapParameters = new JSONObject();
    private final ArrayList<String> preInstallParameters = new ArrayList<String>();
    private final ArrayList<String> campaingParameters = new ArrayList<String>();
    private boolean isInitialized = false;

    /**
     * ---------------------------------------------------------------------------------------------
     * Plugin registry
     * --------------------------------------------------------------------------------------------
     **/
    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
        LogUtils.debug(DEBUG_NAME, "triggered onAttachedToEngine");
        setupChannels(binding.getBinaryMessenger(), binding.getApplicationContext());
    }
    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        LogUtils.debug(DEBUG_NAME, "triggered onDetachedFromEngine");
        teardownChannels();
    }

    private void setupChannels(BinaryMessenger messenger, Context context) {
        LogUtils.debug(DEBUG_NAME, "triggered setupChannels");
        this.context = context;

        MethodChannel methodChannel = new MethodChannel(messenger, MESSAGE_CHANNEL);
        EventChannel eventChannel = new EventChannel(messenger, EVENT_CHANNEL);

        methodChannel.setMethodCallHandler(this);
        eventChannel.setStreamHandler(this);

        FlutterBranchSdkInit.init(context);
    }

    private void setActivity(Activity activity) {
        LogUtils.debug(DEBUG_NAME, "triggered setActivity");

        this.activity = activity;
        activity.getApplication().registerActivityLifecycleCallbacks(this);
    }

    private void teardownChannels() {
        LogUtils.debug(DEBUG_NAME, "triggered teardownChannels");
        this.activityPluginBinding = null;
        this.activity = null;
        this.context = null;
    }

    /**
     * ---------------------------------------------------------------------------------------------
     * ActivityAware Interface Methods
     * --------------------------------------------------------------------------------------------
     **/
    @Override
    public void onAttachedToActivity(ActivityPluginBinding activityPluginBinding) {
        LogUtils.debug(DEBUG_NAME, "triggered onAttachedToActivity");
        this.activityPluginBinding = activityPluginBinding;
        setActivity(activityPluginBinding.getActivity());
        activityPluginBinding.addOnNewIntentListener(this);
    }

    @Override
    public void onDetachedFromActivity() {
        LogUtils.debug(DEBUG_NAME, "triggered onDetachedFromActivity");
        activityPluginBinding.removeOnNewIntentListener(this);
        this.activity = null;
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {
        LogUtils.debug(DEBUG_NAME, "triggered onDetachedFromActivityForConfigChanges");
        onDetachedFromActivity();
    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding activityPluginBinding) {
        LogUtils.debug(DEBUG_NAME, "triggered onReattachedToActivityForConfigChanges");
        onAttachedToActivity(activityPluginBinding);
    }

    /**
     * ---------------------------------------------------------------------------------------------
     * StreamHandler Interface Methods
     * --------------------------------------------------------------------------------------------
     **/
    @Override
    public void onListen(Object o, EventChannel.EventSink eventSink) {
        LogUtils.debug(DEBUG_NAME, "triggered onListen");
        this.eventSink = new MainThreadEventSink(eventSink);
        if (sessionParams != null) {
            eventSink.success(sessionParams);
            sessionParams = null;
            initialError = null;
        } else if (initialError != null) {
            eventSink.error(String.valueOf(initialError.getErrorCode()), initialError.getMessage(), null);
            sessionParams = null;
            initialError = null;
        }
    }

    @Override
    public void onCancel(Object o) {
        LogUtils.debug(DEBUG_NAME, "triggered onCancel");
        this.eventSink = new MainThreadEventSink(null);
        initialError = null;
        sessionParams = null;
    }

    /**
     * ---------------------------------------------------------------------------------------------
     * ActivityLifecycleCallbacks Interface Methods
     * --------------------------------------------------------------------------------------------
     **/
    @Override
    public void onActivityCreated(@NonNull Activity activity, Bundle bundle) {
        LogUtils.debug(DEBUG_NAME, "triggered onActivityCreated: " + activity.getClass().getName());
    }

    @Override
    public void onActivityStarted(@NonNull Activity activity) {
        LogUtils.debug(DEBUG_NAME, "triggered onActivityStarted: " + activity.getClass().getName());
        if (this.activity != activity) {
            return;
        }
        LogUtils.debug(DEBUG_NAME, "triggered SessionBuilder init");
        Branch.sessionBuilder(activity).withCallback(branchReferralInitListener).withData(activity.getIntent().getData()).init();
    }

    @Override
    public void onActivityResumed(@NonNull Activity activity) {
        LogUtils.debug(DEBUG_NAME, "triggered onActivityResumed: " + activity.getClass().getName());
    }

    @Override
    public void onActivityPaused(@NonNull Activity activity) {
        LogUtils.debug(DEBUG_NAME, "triggered onActivityPaused: " + activity.getClass().getName());
        // Delay session initialization
        Branch.expectDelayedSessionInitialization(true);
    }

    @Override
    public void onActivityStopped(@NonNull Activity activity) {
        LogUtils.debug(DEBUG_NAME, "triggered onActivityStopped: " + activity.getClass().getName());
    }

    @Override
    public void onActivitySaveInstanceState(@NonNull Activity activity, @NonNull Bundle bundle) {
    }

    @Override
    public void onActivityDestroyed(@NonNull Activity activity) {
        LogUtils.debug(DEBUG_NAME, "triggered onActivityDestroyed: " + activity.getClass().getName());
        if (this.activity == activity) {
            activity.getApplication().unregisterActivityLifecycleCallbacks(this);
        }
    }

    /**
     * ---------------------------------------------------------------------------------------------
     * NewIntentListener Interface Methods
     * --------------------------------------------------------------------------------------------
     **/
    @Override
    public boolean onNewIntent(@NonNull Intent intent) {
        LogUtils.debug(DEBUG_NAME, "triggered onNewIntent");
        if (this.activity == null) {
            return false;
        }
        this.activity.setIntent(intent);
        if (intent.hasExtra("branch_force_new_session") && intent.getBooleanExtra("branch_force_new_session",false)) {
            Branch.sessionBuilder(this.activity).withCallback(branchReferralInitListener).reInit();
            LogUtils.debug(DEBUG_NAME, "triggered SessionBuilder reInit");
        }
        return true;
    }

    /**
     * ---------------------------------------------------------------------------------------------
     * MethodCallHandler Interface Methods
     * --------------------------------------------------------------------------------------------
     **/
    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result rawResult) {
        Result result = new MethodResultWrapper(rawResult);
        switch (call.method) {
            case "init":
                setupBranch(call, result);
                break;
            case "getShortUrl":
                getShortUrl(call, result);
                break;
            case "shareWithLPLinkMetadata":
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
            case "isUserIdentified":
                isUserIdentified(result);
                break;
            case "setConnectTimeout":
                setConnectTimeout(call);
                break;
            case "setTimeout":
                setTimeout(call);
                break;
            case "setRetryCount":
                setRetryCount(call);
                break;
            case "setRetryInterval":
                setRetryInterval(call);
                break;
            case "getLastAttributedTouchData":
                getLastAttributedTouchData(call, result);
                break;
            case "getQRCode":
                getQRCode(call, result);
                break;
            case "handleDeepLink":
                handleDeepLink(call);
                break;
            case "addFacebookPartnerParameter":
                addFacebookPartnerParameter(call);
                break;
            case "clearPartnerParameters":
                clearPartnerParameters();
                break;
            case "setPreinstallCampaign":
                setPreinstallCampaign(call);
                break;
            case "setPreinstallPartner":
                setPreinstallPartner(call);
                break;
            case "addSnapPartnerParameter":
                addSnapPartnerParameter(call);
                break;
            case "setDMAParamsForEEA":
                setDMAParamsForEEA(call);
                break;
            default:
                result.notImplemented();
                break;
        }
    }

    /**
     * ---------------------------------------------------------------------------------------------
     * Branch SDK Call Methods
     * --------------------------------------------------------------------------------------------
     **/
    private final Branch.BranchReferralInitListener branchReferralInitListener = new
            Branch.BranchReferralInitListener() {
                @Override
                public void onInitFinished(JSONObject params, BranchError error) {
                    LogUtils.debug(DEBUG_NAME, "triggered onInitFinished");
                    if (error == null) {
                        LogUtils.debug(DEBUG_NAME, "BranchReferralInitListener - params: " + params.toString());
                        try {
                            sessionParams = branchSdkHelper.paramsToMap(params);
                        } catch (JSONException e) {
                            LogUtils.debug(DEBUG_NAME, "BranchReferralInitListener - error to Map: " + e.getLocalizedMessage());
                            return;
                        }
                        if (eventSink != null) {
                            eventSink.success(sessionParams);
                            sessionParams = null;
                        }
                    } else {
                        LogUtils.debug(DEBUG_NAME, "BranchReferralInitListener - error: " + error);
                        if (eventSink != null) {
                            eventSink.error(String.valueOf(error.getErrorCode()), error.getMessage(), null);
                            initialError = null;
                        } else {
                            initialError = error;
                        }
                    }
                }
            };

    private void setupBranch(MethodCall call, final Result result) {
        LogUtils.debug(DEBUG_NAME, "triggered setupBranch");
        if (!(call.arguments instanceof Map)) {
            throw new IllegalArgumentException("Map argument expected");
        }

        if (isInitialized) {
            result.success(Boolean.TRUE);
        }

        HashMap<String, Object> argsMap = (HashMap<String, Object>) call.arguments;

        if ((Boolean) argsMap.get("useTestKey")) {
            Branch.enableTestMode();
        } else {
            Branch.disableTestMode();
        }

        if ((Boolean) argsMap.get("enableLogging")) {
            Branch.enableLogging();
        } else {
            Branch.disableLogging();
        }

        if (requestMetadata.length() > 0) {
            Iterator keys = requestMetadata.keys();
            while (keys.hasNext()) {
                String key = (String) keys.next();
                try {
                    Branch.getInstance().setRequestMetadata(key, requestMetadata.getString(key));
                } catch (JSONException e) {
                    // no-op
                }
            }
        }
        if (facebookParameters.length() > 0) {
            Iterator keys = facebookParameters.keys();
            while (keys.hasNext()) {
                String key = (String) keys.next();
                try {
                    Branch.getInstance().addFacebookPartnerParameterWithName(key, facebookParameters.getString(key));
                } catch (JSONException e) {
                    // no-op
                }
            }
        }
        if (snapParameters.length() > 0) {
            Iterator keys = snapParameters.keys();
            while (keys.hasNext()) {
                String key = (String) keys.next();
                try {
                    Branch.getInstance().addSnapPartnerParameterWithName(key, snapParameters.getString(key));
                } catch (JSONException e) {
                    // no-op
                }
            }
        }
        if (!preInstallParameters.isEmpty()) {
            for (int i = 0; i < preInstallParameters.size(); i++) {
                Branch.getAutoInstance(context).setPreinstallPartner(preInstallParameters.get(i));
            }
        }
        if (!campaingParameters.isEmpty()) {
            for (int i = 0; i < campaingParameters.size(); i++) {
                Branch.getAutoInstance(context).setPreinstallCampaign(campaingParameters.get(i));
            }
        }
        if ((Boolean) argsMap.get("disableTracking")) {
            Branch.getInstance().disableTracking(true);
        }

        LogUtils.debug(DEBUG_NAME, "notifyNativeToInit()");
        Branch.notifyNativeToInit();
        isInitialized = true;
        result.success(Boolean.TRUE);
    }

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

                if ((error == null) || (error != null && url != null)) {
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

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP_MR1) {

            Branch.getInstance().share(activity, buo, linkProperties, new Branch.BranchNativeLinkShareListener() {
                        @Override
                        public void onLinkShareResponse(String sharedLink, BranchError error) {
                            if (error == null) {
                                LogUtils.debug(DEBUG_NAME, "Branch link share: " + sharedLink);
                                response.put("success", Boolean.TRUE);
                                response.put("url", sharedLink);
                            } else {
                                response.put("success", Boolean.FALSE);
                                response.put("errorCode", String.valueOf(error.getErrorCode()));
                                response.put("errorMessage", error.getMessage());
                            }
                            result.success(response);
                        }
                        @Override
                        public void onChannelSelected(String channelName) {
                            LogUtils.debug(DEBUG_NAME, "Branch link share channel: " + channelName);
                        }
                    },
                    messageTitle,
                    messageText);
        } else {
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
                                response.put("success", Boolean.TRUE);
                                response.put("url", sharedLink);
                            } else {
                                response.put("success", Boolean.FALSE);
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
    }

    private void registerView(MethodCall call) {
        LogUtils.debug(DEBUG_NAME, "triggered registerView");
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
        LogUtils.debug(DEBUG_NAME, "triggered listOnSearch");
        if (!(call.arguments instanceof Map)) {
            throw new IllegalArgumentException("Map argument expected");
        }
        HashMap<String, Object> argsMap = (HashMap<String, Object>) call.arguments;
        BranchUniversalObject buo = branchSdkHelper.convertToBUO((HashMap<String, Object>) argsMap.get("buo"));
        if (argsMap.containsKey("lp")) {
            LinkProperties linkProperties = branchSdkHelper.convertToLinkProperties((HashMap<String, Object>) argsMap.get("lp"));
            //buo.listOnGoogleSearch(context, linkProperties);
        } else {
            //buo.listOnGoogleSearch(context);
        }
        result.success(Boolean.TRUE);
    }

    private void removeFromSearch(MethodCall call, Result result) {
        LogUtils.debug(DEBUG_NAME, "triggered removeFromSearch");
        if (!(call.arguments instanceof Map)) {
            throw new IllegalArgumentException("Map argument expected");
        }
        HashMap<String, Object> argsMap = (HashMap<String, Object>) call.arguments;
        BranchUniversalObject buo = branchSdkHelper.convertToBUO((HashMap<String, Object>) argsMap.get("buo"));
        if (argsMap.containsKey("lp")) {
            LinkProperties linkProperties = branchSdkHelper.convertToLinkProperties((HashMap<String, Object>) argsMap.get("lp"));
            //buo.removeFromLocalIndexing(context, linkProperties);
        } else {
            //buo.removeFromLocalIndexing(context);
        }
        result.success(Boolean.TRUE);
    }

    private void trackContent(MethodCall call) {
        LogUtils.debug(DEBUG_NAME, "triggered trackContent");
        if (!(call.arguments instanceof Map)) {
            throw new IllegalArgumentException("Map argument expected");
        }
        HashMap<String, Object> argsMap = (HashMap<String, Object>) call.arguments;
        final List<BranchUniversalObject> buo = new ArrayList();
        for (HashMap<String, Object> b : (List<HashMap<String, Object>>) argsMap.get("buo")) {
            buo.add(branchSdkHelper.convertToBUO(b));
        }
        final BranchEvent event = branchSdkHelper.convertToEvent((HashMap<String, Object>) argsMap.get("event"));
        new Handler(Looper.getMainLooper()).post(new Runnable() {
            @Override
            public void run() {
                event.addContentItems(buo).logEvent(context);
            }
        });
    }

    private void trackContentWithoutBuo(MethodCall call) {
        LogUtils.debug(DEBUG_NAME, "triggered trackContentWithoutBuo");
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
        LogUtils.debug(DEBUG_NAME, "triggered setIdentity");
        if (!(call.arguments instanceof Map)) {
            throw new IllegalArgumentException("Map argument expected");
        }
        final String userId = call.argument("userId");
        new Handler(Looper.getMainLooper()).post(new Runnable() {
            @Override
            public void run() {
                Branch.getInstance().setIdentity(userId);
            }
        });
    }

    private void setRequestMetadata(MethodCall call) {
        LogUtils.debug(DEBUG_NAME, "triggered setRequestMetadata");
        if (!(call.arguments instanceof Map)) {
            throw new IllegalArgumentException("Map argument expected");
        }
        final String key = call.argument("key");
        final String value = call.argument("value");

            if (requestMetadata.has(key) && value.isEmpty()) {
                requestMetadata.remove(key);
            } else {
                try {
                    requestMetadata.put(key, value);
                } catch (JSONException error) {
                }
           return;
        }
        new Handler(Looper.getMainLooper()).post(new Runnable() {
            @Override
            public void run() {
                Branch.getInstance().setRequestMetadata(key, value);
            }
        });
    }

    private void logout() {
        LogUtils.debug(DEBUG_NAME, "triggered logout");
        new Handler(Looper.getMainLooper()).post(new Runnable() {
            @Override
            public void run() {
                Branch.getInstance().logout();
            }
        });
    }

    private void getLatestReferringParams(Result result) {
        LogUtils.debug(DEBUG_NAME, "triggered getLatestReferringParams");
        JSONObject sessionParams = Branch.getInstance().getLatestReferringParams();
        try {
            result.success(branchSdkHelper.paramsToMap(sessionParams));
        } catch (JSONException e) {
            e.printStackTrace();
            result.error(DEBUG_NAME, e.getMessage(), null);
        }
    }

    private void getFirstReferringParams(Result result) {
        LogUtils.debug(DEBUG_NAME, "triggered getFirstReferringParams");
        JSONObject sessionParams = Branch.getInstance().getFirstReferringParams();
        try {
            result.success(branchSdkHelper.paramsToMap(sessionParams));
        } catch (JSONException e) {
            e.printStackTrace();
            result.error(DEBUG_NAME, e.getMessage(), null);
        }
    }

    private void setTrackingDisabled(MethodCall call) {
        LogUtils.debug(DEBUG_NAME, "triggered setTrackingDisabled");
        if (!(call.arguments instanceof Map)) {
            throw new IllegalArgumentException("Map argument expected");
        }
        final boolean value = call.argument("disable");
        new Handler(Looper.getMainLooper()).post(new Runnable() {
            @Override
            public void run() {
                Branch.getInstance().disableTracking(value);
            }
        });
    }

    private void isUserIdentified(Result result) {
        LogUtils.debug(DEBUG_NAME, "triggered isUserIdentified");
        result.success(Branch.getInstance().isUserIdentified());
    }

    private void setConnectTimeout(final MethodCall call) {
        LogUtils.debug(DEBUG_NAME, "triggered setConnectTimeout");
        if (!(call.arguments instanceof Map)) {
            throw new IllegalArgumentException("Map argument expected");
        }
        final int value = call.argument("connectTimeout");
        new Handler(Looper.getMainLooper()).post(new Runnable() {
            @Override
            public void run() {
                Branch.getInstance().setNetworkConnectTimeout(value);
            }
        });
    }

    private void setTimeout(final MethodCall call) {
        LogUtils.debug(DEBUG_NAME, "triggered setConnectTimeout");
        if (!(call.arguments instanceof Map)) {
            throw new IllegalArgumentException("Map argument expected");
        }
        final int value = call.argument("timeout");
        new Handler(Looper.getMainLooper()).post(new Runnable() {
            @Override
            public void run() {
                Branch.getInstance().setNetworkTimeout(value);
            }
        });
    }

    private void setRetryCount(final MethodCall call) {
        LogUtils.debug(DEBUG_NAME, "triggered setRetryCount");
        if (!(call.arguments instanceof Map)) {
            throw new IllegalArgumentException("Map argument expected");
        }
        final int value = call.argument("retryCount");
        new Handler(Looper.getMainLooper()).post(new Runnable() {
            @Override
            public void run() {
                Branch.getInstance().setRetryCount(value);
            }
        });
    }

    private void setRetryInterval(final MethodCall call) {
        LogUtils.debug(DEBUG_NAME, "triggered setRetryInterval");
        if (!(call.arguments instanceof Map)) {
            throw new IllegalArgumentException("Map argument expected");
        }
        final int value = call.argument("retryInterval");
        new Handler(Looper.getMainLooper()).post(new Runnable() {
            @Override
            public void run() {
                Branch.getInstance().setRetryInterval(value);
            }
        });
    }

    private void getLastAttributedTouchData(final MethodCall call, final Result result) {
        LogUtils.debug(DEBUG_NAME, "triggered getLastAttributedTouchData");
        final Map<String, Object> response = new HashMap<>();
        if (call.hasArgument("attributionWindow")) {
            final int attributionWindow = call.argument("attributionWindow");
            Branch.getInstance().getLastAttributedTouchData(
                    new ServerRequestGetLATD.BranchLastAttributedTouchDataListener() {
                        @Override
                        public void onDataFetched(JSONObject jsonObject, BranchError error) {
                            if (error == null) {
                                response.put("success", Boolean.TRUE);
                                JSONObject jo = new JSONObject();
                                try {
                                    jo.put("latd", jsonObject);
                                    response.put("data", branchSdkHelper.paramsToMap(jo));
                                } catch (JSONException e) {
                                    e.printStackTrace();
                                }
                            } else {
                                response.put("success", Boolean.FALSE);
                                response.put("errorCode", String.valueOf(error.getErrorCode()));
                                response.put("errorMessage", error.getMessage());
                            }
                            result.success(response);
                        }
                    }, attributionWindow);

        } else {
            Branch.getInstance().getLastAttributedTouchData(
                    new ServerRequestGetLATD.BranchLastAttributedTouchDataListener() {
                        @Override
                        public void onDataFetched(JSONObject jsonObject, BranchError error) {
                            if (error == null) {
                                response.put("success", Boolean.TRUE);
                                JSONObject jo = new JSONObject();
                                try {
                                    jo.put("latd", jsonObject);
                                    response.put("data", branchSdkHelper.paramsToMap(jo));
                                } catch (JSONException e) {
                                    e.printStackTrace();
                                }
                            } else {
                                response.put("success", Boolean.FALSE);
                                response.put("errorCode", String.valueOf(error.getErrorCode()));
                                response.put("errorMessage", error.getMessage());
                            }
                            result.success(response);
                        }
                    });
        }
    }

    private void getQRCode(final MethodCall call, final Result result) {
        LogUtils.debug(DEBUG_NAME, "triggered getQRCodeAsData");
        if (!(call.arguments instanceof Map)) {
            throw new IllegalArgumentException("Map argument expected");
        }
        HashMap<String, Object> argsMap = (HashMap<String, Object>) call.arguments;
        final BranchUniversalObject buo = branchSdkHelper.convertToBUO((HashMap<String, Object>) argsMap.get("buo"));
        final LinkProperties linkProperties = branchSdkHelper.convertToLinkProperties((HashMap<String, Object>) argsMap.get("lp"));
        final BranchQRCode branchQRCode = branchSdkHelper.convertToQRCode((HashMap<String, Object>) argsMap.get("qrCodeSettings"));
        final Map<String, Object> response = new HashMap<>();
        try {
            branchQRCode.getQRCodeAsData(context, buo, linkProperties, new BranchQRCode.BranchQRCodeDataHandler() {
                @Override
                public void onSuccess(byte[] qrCodeData) {

                    response.put("success", Boolean.TRUE);
                    response.put("result", qrCodeData);
                    result.success(response);
                }

                @Override
                public void onFailure(Exception error) {
                    response.put("success", Boolean.FALSE);
                    response.put("errorCode", "-1");
                    response.put("errorMessage", error.getMessage());
                    result.success(response);
                }
            });
        } catch (IOException e) {
            response.put("success", Boolean.FALSE);
            response.put("errorCode", "-1");
            response.put("errorMessage", e.getMessage());
            result.success(response);
        }
    }

    private void handleDeepLink(final MethodCall call) {
        LogUtils.debug(DEBUG_NAME, "triggered handleDeepLink");
        if (!(call.arguments instanceof Map)) {
            throw new IllegalArgumentException("Map argument expected");
        }
        final String url = call.argument("url");
        Intent intent = new Intent(context, activity.getClass());
        intent.putExtra("branch", url);
        intent.putExtra("branch_force_new_session", true);
        activity.startActivity(intent);
    }

    private void addFacebookPartnerParameter(MethodCall call) {
        LogUtils.debug(DEBUG_NAME, "triggered addFacebookPartnerParameter");
        if (!(call.arguments instanceof Map)) {
            throw new IllegalArgumentException("Map argument expected");
        }
        final String key = call.argument("key");
        final String value = call.argument("value");
        if (facebookParameters.has(key) && value.isEmpty()) {
            facebookParameters.remove(key);
        } else {
            try {
                facebookParameters.put(key, value);
            } catch (JSONException error) {
            }
        }
        new Handler(Looper.getMainLooper()).post(new Runnable() {
            @Override
            public void run() {
                Branch.getAutoInstance(context).addFacebookPartnerParameterWithName(key, value);
            }
        });
    }

    private void clearPartnerParameters() {
        LogUtils.debug(DEBUG_NAME, "triggered clearPartnerParameters");
        new Handler(Looper.getMainLooper()).post(new Runnable() {
            @Override
            public void run() {
                Branch.getAutoInstance(context).clearPartnerParameters();
            }
        });
    }

    private void setPreinstallCampaign(MethodCall call) {
        LogUtils.debug(DEBUG_NAME, "triggered setPreinstallCampaign");
        if (!(call.arguments instanceof Map)) {
            throw new IllegalArgumentException("Map argument expected");
        }
        final String value = call.argument("value");
        campaingParameters.add(value);

        new Handler(Looper.getMainLooper()).post(new Runnable() {
            @Override
            public void run() {
                Branch.getAutoInstance(context).setPreinstallCampaign(value);
            }
        });
    }

    private void setPreinstallPartner(MethodCall call) {
        LogUtils.debug(DEBUG_NAME, "triggered setPreinstallPartner");
        if (!(call.arguments instanceof Map)) {
            throw new IllegalArgumentException("Map argument expected");
        }
        final String value = call.argument("value");
        preInstallParameters.add(value);

        new Handler(Looper.getMainLooper()).post(new Runnable() {
            @Override
            public void run() {
                Branch.getAutoInstance(context).setPreinstallPartner(value);
            }
        });
    }

    private void addSnapPartnerParameter(MethodCall call) {
        LogUtils.debug(DEBUG_NAME, "triggered addSnapPartnerParameter");
        if (!(call.arguments instanceof Map)) {
            throw new IllegalArgumentException("Map argument expected");
        }
        final String key = call.argument("key");
        final String value = call.argument("value");
        if (snapParameters.has(key) && value.isEmpty()) {
            snapParameters.remove(key);
        } else {
            try {
                snapParameters.put(key, value);
            } catch (JSONException error) {
            }
        }

        new Handler(Looper.getMainLooper()).post(new Runnable() {
            @Override
            public void run() {
                Branch.getAutoInstance(context).addSnapPartnerParameterWithName(key, value);
            }
        });
    }

    private void setDMAParamsForEEA(MethodCall call) {
        LogUtils.debug(DEBUG_NAME, "triggered setDMAParamsForEEA");
        if (!(call.arguments instanceof Map)) {
            throw new IllegalArgumentException("Map argument expected");
        }
        final boolean eeaRegion = Boolean.TRUE.equals(call.argument("eeaRegion"));
        final boolean adPersonalizationConsent = Boolean.TRUE.equals(call.argument("adPersonalizationConsent"));
        final boolean adUserDataUsageConsent = Boolean.TRUE.equals(call.argument("adUserDataUsageConsent"));

        Branch.getInstance().setDMAParamsForEEA(eeaRegion,adPersonalizationConsent,adUserDataUsageConsent);
    }
}


