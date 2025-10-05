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
import java.util.Objects;

import io.branch.indexing.BranchUniversalObject;
import io.branch.referral.Branch;
import io.branch.referral.BranchError;
import io.branch.referral.BranchLogger;
import io.branch.referral.Defines;
import io.branch.referral.QRCode.BranchQRCode;
import io.branch.referral.util.BranchEvent;
import io.branch.referral.util.LinkProperties;
import io.branch.referral.validators.IntegrationValidator;
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

public class FlutterBranchSdkPlugin implements FlutterPlugin, MethodCallHandler, StreamHandler, NewIntentListener, ActivityAware,
        Application.ActivityLifecycleCallbacks {
    private static final String DEBUG_NAME = "FlutterBranchSDK";
    private static final String MESSAGE_CHANNEL = "flutter_branch_sdk/message";
    private static final String EVENT_CHANNEL = "flutter_branch_sdk/event";
    private final FlutterBranchSdkHelper branchSdkHelper = new FlutterBranchSdkHelper();
    private final JSONObject requestMetadata = new JSONObject();
    private final JSONObject facebookParameters = new JSONObject();
    private final JSONObject snapParameters = new JSONObject();
    private final ArrayList<String> preInstallParameters = new ArrayList<>();
    private final ArrayList<String> campaingParameters = new ArrayList<>();
    private Activity activity;
    private Context context;
    private ActivityPluginBinding activityPluginBinding;
    private EventSink eventSink = null;
    private Map<String, Object> sessionParams = null;
    private BranchError initialError = null;
    public static BranchJsonConfig branchJsonConfig = null;

    /**
     * ---------------------------------------------------------------------------------------------
     * Branch SDK Call Methods
     * --------------------------------------------------------------------------------------------
     **/
    private final Branch.BranchReferralInitListener branchReferralInitListener = (params, error) -> {
        LogUtils.debug(DEBUG_NAME, "triggered onInitFinished");
        if (error == null) {
            LogUtils.debug(DEBUG_NAME, "BranchReferralInitListener - params: " + Objects.requireNonNull(params));
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
        } else if (error.getErrorCode() == BranchError.ERR_BRANCH_ALREADY_INITIALIZED) {
            LogUtils.debug(DEBUG_NAME, "BranchReferralInitListener : " + error.getMessage());
            try {
                sessionParams = branchSdkHelper.paramsToMap(Branch.getInstance().getLatestReferringParams());
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
    };
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

        branchJsonConfig = BranchJsonConfig.loadFromFile(context, binding);
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

        if (this.activity != null && FlutterFragmentActivity.class.isAssignableFrom(activity.getClass())) {
            Branch.sessionBuilder(activity).withCallback(branchReferralInitListener).withData(activity.getIntent().getData()).init();
        }
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
    public void onListen(Object o, EventSink eventSink) {
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
        if (intent.hasExtra("branch_force_new_session") && intent.getBooleanExtra("branch_force_new_session", false)) {
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
                //setTrackingDisabled(call);
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
            case "setConsumerProtectionAttributionLevel":
                setConsumerProtectionAttributionLevel(call);
                break;
            default:
                result.notImplemented();
                break;
        }
    }

    @SuppressWarnings("unchecked")
    private void setupBranch(MethodCall call, final Result result) {
        boolean enableLoggingFromJson = false;

        LogUtils.debug(DEBUG_NAME, "triggered setupBranch");
        if (!(call.arguments instanceof Map)) {
            throw new IllegalArgumentException("Map argument expected");
        }

        if (isInitialized) {
            result.success(Boolean.TRUE);
        }

        if (branchJsonConfig != null) {
            if (!branchJsonConfig.apiUrl.isEmpty()) {
                LogUtils.debug(DEBUG_NAME, "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
                LogUtils.debug(DEBUG_NAME, "The apiUrl parameter has been deprecated. Please use apiUrlAndroid instead. Check the documentation.");
                LogUtils.debug(DEBUG_NAME, "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
                throw new IllegalArgumentException("The apiUrl parameter has been deprecated. Please use apiUrlAndroid instead. Check the documentation.");
            }

            if (!branchJsonConfig.apiUrlAndroid.isEmpty()) {
                Branch.setAPIUrl(branchJsonConfig.apiUrlAndroid);
                LogUtils.debug(DEBUG_NAME, "Set API URL from branch-config.json: " + branchJsonConfig.apiUrlAndroid);
            }


            if (branchJsonConfig.enableLogging) {
                Branch.enableLogging();
                LogUtils.debug(DEBUG_NAME, "Set EnableLogging from branch-config.json");
                enableLoggingFromJson = true;
            }

            if (!branchJsonConfig.branchKey.isEmpty()) {
                Branch.getInstance().setBranchKey(branchJsonConfig.branchKey);
                LogUtils.debug(DEBUG_NAME, "Set Branch Key from branch-config.json: " + branchJsonConfig.branchKey);
            } else {
                if (branchJsonConfig.useTestInstance && !branchJsonConfig.testKey.isEmpty()) {
                    Branch.getInstance().setBranchKey(branchJsonConfig.testKey);
                    LogUtils.debug(DEBUG_NAME, "Set Test Key from branch-config.json: " + branchJsonConfig.testKey);

                } else if (!branchJsonConfig.liveKey.isEmpty()) {
                    Branch.getInstance().setBranchKey(branchJsonConfig.liveKey);
                    LogUtils.debug(DEBUG_NAME, "Set Live Key from branch-config.json: " + branchJsonConfig.liveKey);
                }
            }
        }

        HashMap<String, Object> argsMap = (HashMap<String, Object>) call.arguments;

        if (!enableLoggingFromJson) {
            if ((Boolean) Objects.requireNonNull(argsMap.get("enableLogging"))) {
                Branch.enableLogging(BranchLogger.BranchLogLevel.VERBOSE);
            } else {
                Branch.disableLogging();
            }
        }

        if (requestMetadata.length() > 0) {
            Iterator<String> keys = requestMetadata.keys();
            while (keys.hasNext()) {
                String key = keys.next();
                try {
                    Branch.getInstance().setRequestMetadata(key, requestMetadata.getString(key));
                } catch (JSONException e) {
                    // no-op
                }
            }
        }
        if (facebookParameters.length() > 0) {
            Iterator<String> keys = facebookParameters.keys();
            while (keys.hasNext()) {
                String key = keys.next();
                try {
                    Branch.getInstance().addFacebookPartnerParameterWithName(key, facebookParameters.getString(key));
                } catch (JSONException e) {
                    // no-op
                }
            }
        }
        if (snapParameters.length() > 0) {
            Iterator<String> keys = snapParameters.keys();
            while (keys.hasNext()) {
                String key = keys.next();
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

        final String branchAttributionLevelString = Objects.requireNonNull(call.argument("branchAttributionLevel"));
        if (!branchAttributionLevelString.isEmpty()) {
            Branch.getInstance().setConsumerProtectionAttributionLevel(Defines.BranchAttributionLevel.valueOf(branchAttributionLevelString));
        }

        LogUtils.debug(DEBUG_NAME, "notifyNativeToInit()");
        Branch.notifyNativeToInit();
        isInitialized = true;
        result.success(Boolean.TRUE);
    }

    private void validateSDKIntegration() {
        IntegrationValidator.validate(this.activity);
    }

    @SuppressWarnings("unchecked")
    private void getShortUrl(MethodCall call, final Result result) {
        if (!(call.arguments instanceof Map)) {
            throw new IllegalArgumentException("Map argument expected");
        }
        HashMap<String, Object> argsMap = (HashMap<String, Object>) call.arguments;
        BranchUniversalObject buo = branchSdkHelper.convertToBUO((HashMap<String, Object>) Objects.requireNonNull(argsMap.get("buo")));
        LinkProperties linkProperties = branchSdkHelper.convertToLinkProperties((HashMap<String, Object>) Objects.requireNonNull(argsMap.get("lp")));
        final Map<String, Object> response = new HashMap<>();
        buo.generateShortUrl(activity, linkProperties, (url, error) -> {

            if ((error == null && url != null) || (error != null && url != null)) {
                LogUtils.debug(DEBUG_NAME, "Branch link to share: " + url);
                response.put("success", true);
                response.put("url", url);
            } else {
                response.put("success", false);
                response.put("errorCode", String.valueOf(error != null ? error.getErrorCode() : -1));
                response.put("errorMessage", error != null ? error.getMessage() : "Error message not defined");
            }
            result.success(response);
        });
    }

    @SuppressWarnings("unchecked")
    private void showShareSheet(MethodCall call, final Result result) {
        if (!(call.arguments instanceof Map)) {
            throw new IllegalArgumentException("Map argument expected");
        }
        HashMap<String, Object> argsMap = (HashMap<String, Object>) call.arguments;
        BranchUniversalObject buo = branchSdkHelper.convertToBUO((HashMap<String, Object>) Objects.requireNonNull(argsMap.get("buo")));
        LinkProperties linkProperties = branchSdkHelper.convertToLinkProperties((HashMap<String, Object>) Objects.requireNonNull(argsMap.get("lp")));
        String messageText = (String) Objects.requireNonNull(argsMap.get("messageText"));
        String messageTitle = "";
        if (argsMap.containsKey("messageTitle")) {
            messageTitle = (String) Objects.requireNonNull(argsMap.get("messageTitle"));
        }
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
                messageText
            );
        } else {
            response.put("success", Boolean.FALSE);
            response.put("errorCode", "UNSUPPORTED_VERSION");
            response.put("errorMessage","Version not supported. Requires API 22");
            result.success(response);
        }
    }

    @SuppressWarnings("unchecked")
    private void registerView(MethodCall call) {
        LogUtils.debug(DEBUG_NAME, "triggered registerView");
        if (!(call.arguments instanceof Map)) {
            throw new IllegalArgumentException("Map argument expected");
        }
        HashMap<String, Object> argsMap = (HashMap<String, Object>) Objects.requireNonNull(call.arguments);
        final BranchUniversalObject buo = branchSdkHelper.convertToBUO((HashMap<String, Object>) Objects.requireNonNull(argsMap.get("buo")));
        new Handler(Looper.getMainLooper()).post(buo::registerView);
    }

    private void listOnSearch(MethodCall ignoredCall, Result result) {
        LogUtils.debug(DEBUG_NAME, "triggered listOnSearch");
        result.success(Boolean.TRUE);
    }

    private void removeFromSearch(MethodCall ignoredCall, Result result) {
        LogUtils.debug(DEBUG_NAME, "triggered removeFromSearch");
        result.success(Boolean.TRUE);
    }

    @SuppressWarnings("unchecked")
    private void trackContent(MethodCall call) {
        LogUtils.debug(DEBUG_NAME, "triggered trackContent");
        if (!(call.arguments instanceof Map)) {
            throw new IllegalArgumentException("Map argument expected");
        }
        HashMap<String, Object> argsMap = (HashMap<String, Object>) call.arguments;
        final List<BranchUniversalObject> buo = new ArrayList<>();
        for (HashMap<String, Object> b : (List<HashMap<String, Object>>) Objects.requireNonNull(argsMap.get("buo"))) {
            buo.add(branchSdkHelper.convertToBUO(b));
        }
        final BranchEvent event = branchSdkHelper.convertToEvent((HashMap<String, Object>) Objects.requireNonNull(argsMap.get("event")));
        new Handler(Looper.getMainLooper()).post(() -> event.addContentItems(buo).logEvent(context));
    }

    @SuppressWarnings("unchecked")
    private void trackContentWithoutBuo(MethodCall call) {
        LogUtils.debug(DEBUG_NAME, "triggered trackContentWithoutBuo");
        if (!(call.arguments instanceof Map)) {
            throw new IllegalArgumentException("Map argument expected");
        }
        HashMap<String, Object> argsMap = (HashMap<String, Object>) call.arguments;
        final BranchEvent event = branchSdkHelper.convertToEvent((HashMap<String, Object>) Objects.requireNonNull(argsMap.get("event")));
        new Handler(Looper.getMainLooper()).post(() -> event.logEvent(context));
    }

    @SuppressWarnings("unchecked")
    private void setIdentity(MethodCall call) {
        LogUtils.debug(DEBUG_NAME, "triggered setIdentity");
        if (!(call.arguments instanceof Map)) {
            throw new IllegalArgumentException("Map argument expected");
        }
        final String userId = Objects.requireNonNull(call.argument("userId"));
        new Handler(Looper.getMainLooper()).post(() -> Branch.getInstance().setIdentity(userId));
    }

    @SuppressWarnings("unchecked")
    private void setRequestMetadata(MethodCall call) {
        LogUtils.debug(DEBUG_NAME, "triggered setRequestMetadata");
        if (!(call.arguments instanceof Map)) {
            throw new IllegalArgumentException("Map argument expected");
        }
        final String key = Objects.requireNonNull(call.argument("key"));
        final String value = Objects.requireNonNull(call.argument("value"));

        if (requestMetadata.has(key) && value.isEmpty()) {
            requestMetadata.remove(key);
        } else {
            try {
                requestMetadata.put(key, value);
            } catch (JSONException error) {
                return;
            }
        }
        new Handler(Looper.getMainLooper()).post(() -> Branch.getInstance().setRequestMetadata(key, value));
    }

    private void logout() {
        LogUtils.debug(DEBUG_NAME, "triggered logout");
        new Handler(Looper.getMainLooper()).post(() -> Branch.getInstance().logout());
    }

    private void getLatestReferringParams(Result result) {
        LogUtils.debug(DEBUG_NAME, "triggered getLatestReferringParams");
        JSONObject sessionParams = Branch.getInstance().getLatestReferringParams();
        try {
            result.success(branchSdkHelper.paramsToMap(sessionParams));
        } catch (JSONException e) {
            e.getMessage();
            result.error(DEBUG_NAME, e.getMessage(), null);
        }
    }

    private void getFirstReferringParams(Result result) {
        LogUtils.debug(DEBUG_NAME, "triggered getFirstReferringParams");
        JSONObject sessionParams = Branch.getInstance().getFirstReferringParams();
        try {
            result.success(branchSdkHelper.paramsToMap(sessionParams));
        } catch (JSONException e) {
            e.getMessage();
            result.error(DEBUG_NAME, e.getMessage(), null);
        }
    }

    private void isUserIdentified(Result result) {
        LogUtils.debug(DEBUG_NAME, "triggered isUserIdentified");
        result.success(Branch.getInstance().isUserIdentified());
    }

    @SuppressWarnings("unchecked")
    private void setConnectTimeout(final MethodCall call) {
        LogUtils.debug(DEBUG_NAME, "triggered setConnectTimeout");
        if (!(call.arguments instanceof Map)) {
            throw new IllegalArgumentException("Map argument expected");
        }
        final int value = Objects.requireNonNull(call.argument("connectTimeout"));
        new Handler(Looper.getMainLooper()).post(() -> Branch.getInstance().setNetworkConnectTimeout(value));
    }

    @SuppressWarnings("unchecked")
    private void setTimeout(final MethodCall call) {
        LogUtils.debug(DEBUG_NAME, "triggered setConnectTimeout");
        if (!(call.arguments instanceof Map)) {
            throw new IllegalArgumentException("Map argument expected");
        }
        final int value = Objects.requireNonNull(call.argument("timeout"));
        new Handler(Looper.getMainLooper()).post(() -> Branch.getInstance().setNetworkTimeout(value));
    }

    @SuppressWarnings("unchecked")
    private void setRetryCount(final MethodCall call) {
        LogUtils.debug(DEBUG_NAME, "triggered setRetryCount");
        if (!(call.arguments instanceof Map)) {
            throw new IllegalArgumentException("Map argument expected");
        }
        final int value = Objects.requireNonNull(call.argument("retryCount"));
        new Handler(Looper.getMainLooper()).post(() -> Branch.getInstance().setRetryCount(value));
    }

    @SuppressWarnings("unchecked")
    private void setRetryInterval(final MethodCall call) {
        LogUtils.debug(DEBUG_NAME, "triggered setRetryInterval");
        if (!(call.arguments instanceof Map)) {
            throw new IllegalArgumentException("Map argument expected");
        }
        final int value = Objects.requireNonNull(call.argument("retryInterval"));
        new Handler(Looper.getMainLooper()).post(() -> Branch.getInstance().setRetryInterval(value));
    }

    @SuppressWarnings("unchecked")
    private void getLastAttributedTouchData(final MethodCall call, final Result result) {
        LogUtils.debug(DEBUG_NAME, "triggered getLastAttributedTouchData");
        final Map<String, Object> response = new HashMap<>();
        if (call.hasArgument("attributionWindow")) {
            final int attributionWindow = Objects.requireNonNull(call.argument("attributionWindow"));
            Branch.getInstance().getLastAttributedTouchData(
                    (jsonObject, error) -> {
                        if (error == null) {
                            response.put("success", Boolean.TRUE);
                            JSONObject jo = new JSONObject();
                            try {
                                jo.put("latd", jsonObject);
                                response.put("data", branchSdkHelper.paramsToMap(jo));
                            } catch (JSONException e) {
                                LogUtils.debug(DEBUG_NAME, e.getLocalizedMessage());
                            }
                        } else {
                            response.put("success", Boolean.FALSE);
                            response.put("errorCode", String.valueOf(error.getErrorCode()));
                            response.put("errorMessage", error.getMessage());
                        }
                        result.success(response);
                    }, attributionWindow);

        } else {
            Branch.getInstance().getLastAttributedTouchData(
                    (jsonObject, error) -> {
                        if (error == null) {
                            response.put("success", Boolean.TRUE);
                            JSONObject jo = new JSONObject();
                            try {
                                jo.put("latd", jsonObject);
                                response.put("data", branchSdkHelper.paramsToMap(jo));
                            } catch (JSONException e) {
                                LogUtils.debug(DEBUG_NAME, e.getLocalizedMessage());
                            }
                        } else {
                            response.put("success", Boolean.FALSE);
                            response.put("errorCode", String.valueOf(error.getErrorCode()));
                            response.put("errorMessage", error.getMessage());
                        }
                        result.success(response);
                    });
        }
    }

    @SuppressWarnings("unchecked")
    private void getQRCode(final MethodCall call, final Result result) {
        LogUtils.debug(DEBUG_NAME, "triggered getQRCodeAsData");
        if (!(call.arguments instanceof Map)) {
            throw new IllegalArgumentException("Map argument expected");
        }
        HashMap<String, Object> argsMap = (HashMap<String, Object>) call.arguments;
        final BranchUniversalObject buo = branchSdkHelper.convertToBUO((HashMap<String, Object>) Objects.requireNonNull(argsMap.get("buo")));
        final LinkProperties linkProperties = branchSdkHelper.convertToLinkProperties((HashMap<String, Object>) Objects.requireNonNull(argsMap.get("lp")));
        final BranchQRCode branchQRCode = branchSdkHelper.convertToQRCode((HashMap<String, Object>) Objects.requireNonNull(argsMap.get("qrCodeSettings")));
        final Map<String, Object> response = new HashMap<>();
        try {
            branchQRCode.getQRCodeAsData(context, buo, linkProperties, new BranchQRCode.BranchQRCodeDataHandler<byte[]>() {
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

    @SuppressWarnings("unchecked")
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

    @SuppressWarnings("unchecked")
    private void addFacebookPartnerParameter(MethodCall call) {
        LogUtils.debug(DEBUG_NAME, "triggered addFacebookPartnerParameter");
        if (!(call.arguments instanceof Map)) {
            throw new IllegalArgumentException("Map argument expected");
        }
        final String key = Objects.requireNonNull(call.argument("key"));
        final String value = Objects.requireNonNull(call.argument("value"));
        if (facebookParameters.has(key) && value.isEmpty()) {
            facebookParameters.remove(key);
        } else {
            try {
                facebookParameters.put(key, value);
            } catch (JSONException error) {
                LogUtils.debug(DEBUG_NAME, error.getLocalizedMessage());
            }
        }
        new Handler(Looper.getMainLooper()).post(() -> Branch.getAutoInstance(context).addFacebookPartnerParameterWithName(key, value));
    }

    private void clearPartnerParameters() {
        LogUtils.debug(DEBUG_NAME, "triggered clearPartnerParameters");
        new Handler(Looper.getMainLooper()).post(() -> Branch.getAutoInstance(context).clearPartnerParameters());
    }

    @SuppressWarnings("unchecked")
    private void setPreinstallCampaign(MethodCall call) {
        LogUtils.debug(DEBUG_NAME, "triggered setPreinstallCampaign");
        if (!(call.arguments instanceof Map)) {
            throw new IllegalArgumentException("Map argument expected");
        }
        final String value = Objects.requireNonNull(call.argument("value"));
        campaingParameters.add(value);

        new Handler(Looper.getMainLooper()).post(() -> Branch.getAutoInstance(context).setPreinstallCampaign(value));
    }

    @SuppressWarnings("unchecked")
    private void setPreinstallPartner(MethodCall call) {
        LogUtils.debug(DEBUG_NAME, "triggered setPreinstallPartner");
        if (!(call.arguments instanceof Map)) {
            throw new IllegalArgumentException("Map argument expected");
        }
        final String value = Objects.requireNonNull(call.argument("value"));
        preInstallParameters.add(value);

        new Handler(Looper.getMainLooper()).post(() -> Branch.getAutoInstance(context).setPreinstallPartner(value));
    }

    @SuppressWarnings("unchecked")
    private void addSnapPartnerParameter(MethodCall call) {
        LogUtils.debug(DEBUG_NAME, "triggered addSnapPartnerParameter");
        if (!(call.arguments instanceof Map)) {
            throw new IllegalArgumentException("Map argument expected");
        }
        final String key = Objects.requireNonNull(call.argument("key"));
        final String value = Objects.requireNonNull(call.argument("value"));
        if (snapParameters.has(key) && value.isEmpty()) {
            snapParameters.remove(key);
        } else {
            try {
                snapParameters.put(key, value);
            } catch (JSONException error) {
                LogUtils.debug(DEBUG_NAME, error.getLocalizedMessage());
            }
        }

        new Handler(Looper.getMainLooper()).post(() -> Branch.getAutoInstance(context).addSnapPartnerParameterWithName(key, value));
    }

    @SuppressWarnings("unchecked")
    private void setDMAParamsForEEA(MethodCall call) {
        LogUtils.debug(DEBUG_NAME, "triggered setDMAParamsForEEA");
        if (!(call.arguments instanceof Map)) {
            throw new IllegalArgumentException("Map argument expected");
        }
        final boolean eeaRegion = Boolean.TRUE.equals(call.argument("eeaRegion"));
        final boolean adPersonalizationConsent = Boolean.TRUE.equals(call.argument("adPersonalizationConsent"));
        final boolean adUserDataUsageConsent = Boolean.TRUE.equals(call.argument("adUserDataUsageConsent"));

        Branch.getInstance().setDMAParamsForEEA(eeaRegion, adPersonalizationConsent, adUserDataUsageConsent);
    }

    @SuppressWarnings("unchecked")
    private void setConsumerProtectionAttributionLevel(MethodCall call) {
        LogUtils.debug(DEBUG_NAME, "triggered setConsumerProtectionAttributionLevel");
        if (!(call.arguments instanceof Map)) {
            throw new IllegalArgumentException("Map argument expected");
        }
        final String branchAttributionLevelString = call.argument("branchAttributionLevel");
        Branch.getInstance().setConsumerProtectionAttributionLevel(Defines.BranchAttributionLevel.valueOf(branchAttributionLevelString));
    }
}


