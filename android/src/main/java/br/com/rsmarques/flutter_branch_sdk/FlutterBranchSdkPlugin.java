package br.com.rsmarques.flutter_branch_sdk;

import android.app.Activity;
import android.app.Application;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

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
        setupChannels(binding.getFlutterEngine().getDartExecutor(), binding.getApplicationContext());
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        teardownChannels();
    }

    private void setupChannels(BinaryMessenger messenger, Context context) {
        this.context = context;

        methodChannel = new MethodChannel(messenger, MESSAGE_CHANNEL);
        eventChannel = new EventChannel(messenger, EVENT_CHANNEL);

        methodChannel.setMethodCallHandler(this);
        eventChannel.setStreamHandler(this);

        FlutterBranchSdkInit.init(context);
    }

    private void setActivity(Activity activity) {
        this.activity = activity;
        activity.getApplication().registerActivityLifecycleCallbacks(this);
    }

    private void teardownChannels() {
        this.activityPluginBinding = null;
        this.activity = null;
        this.context = null;
    }

    /**---------------------------------------------------------------------------------------------
     ActivityAware Interface Methods
     --------------------------------------------------------------------------------------------**/
    @Override
    public void onAttachedToActivity(ActivityPluginBinding activityPluginBinding) {
        this.activityPluginBinding = activityPluginBinding;
        setActivity(activityPluginBinding.getActivity());
        activityPluginBinding.addOnNewIntentListener(this);
    }

    @Override
    public void onDetachedFromActivity() {
        activityPluginBinding.removeOnNewIntentListener(this);
        this.activity = null;
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {
        onDetachedFromActivity();
    }

    @Override
    public void onReattachedToActivityForConfigChanges(ActivityPluginBinding activityPluginBinding) {
        onAttachedToActivity(activityPluginBinding);
    }

    /**---------------------------------------------------------------------------------------------
     StreamHandler Interface Methods
     --------------------------------------------------------------------------------------------**/
    @Override
    public void onListen(Object o, EventChannel.EventSink eventSink) {
        this.eventSink = eventSink;
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
        this.eventSink = null;
        initialError = null;
        initialParams = null;
    }

    /**---------------------------------------------------------------------------------------------
     ActivityLifecycleCallbacks Interface Methods
     --------------------------------------------------------------------------------------------**/
    @Override
    public void onActivityCreated(Activity activity, Bundle bundle) {
    }

    @Override
    public void onActivityStarted(Activity activity) {
        Branch.sessionBuilder(activity).withCallback(branchReferralInitListener).withData(activity.getIntent() != null ? activity.getIntent().getData() : null).init();
    }

    @Override
    public void onActivityResumed(Activity activity) {}

    @Override
    public void onActivityPaused(Activity activity) {}

    @Override
    public void onActivityStopped(Activity activity) {}

    @Override
    public void onActivitySaveInstanceState(Activity activity, Bundle bundle) {}

    @Override
    public void onActivityDestroyed(Activity activity) {
        if (this.activity == activity) {
            activity.getApplication().unregisterActivityLifecycleCallbacks(this);
        }
    }

    /**---------------------------------------------------------------------------------------------
     NewIntentListener Interface Methods
     --------------------------------------------------------------------------------------------**/
    @Override
    public boolean onNewIntent(Intent intent) {
        if (this.activity != null) {
            intent.putExtra("branch_force_new_session", true);
            this.activity.setIntent(intent);
            Branch.sessionBuilder(this.activity).withCallback(branchReferralInitListener).reInit();
        }
        return false;
    }

    /**---------------------------------------------------------------------------------------------
     MethodCallHandler Interface Methods
     --------------------------------------------------------------------------------------------**/
    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
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
                        Log.d(DEBUG_NAME, "BranchReferralInitListener - params: " + params.toString());
                        try {
                            initialParams = branchSdkHelper.paramsToMap(params);
                        } catch (JSONException e) {
                            Log.d(DEBUG_NAME, "BranchReferralInitListener - error to Map: " + e.getLocalizedMessage());
                            return;
                        }
                        if (eventSink != null) {
                            eventSink.success(initialParams);
                            initialParams = null;
                        }
                    } else {
                        Log.d(DEBUG_NAME, "BranchReferralInitListener - error: " + error.toString());
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
                    Log.d(DEBUG_NAME, "Branch link to share: " + url);
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
                            Log.d(DEBUG_NAME, "Branch link share: " + sharedLink);
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
        if (!(call.arguments instanceof Map)) {
            throw new IllegalArgumentException("Map argument expected");
        }
        HashMap<String, Object> argsMap = (HashMap<String, Object>) call.arguments;
        BranchUniversalObject buo = branchSdkHelper.convertToBUO((HashMap<String, Object>) argsMap.get("buo"));
        buo.registerView();
    }

    private void listOnSearch(MethodCall call, Result result) {
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
        if (!(call.arguments instanceof Map)) {
            throw new IllegalArgumentException("Map argument expected");
        }
        HashMap<String, Object> argsMap = (HashMap<String, Object>) call.arguments;
        BranchUniversalObject buo = branchSdkHelper.convertToBUO((HashMap<String, Object>) argsMap.get("buo"));
        BranchEvent event = branchSdkHelper.convertToEvent((HashMap<String, Object>) argsMap.get("event"));
        event.addContentItems(buo).logEvent(context);
    }

    private void trackContentWithoutBuo(MethodCall call) {
        if (!(call.arguments instanceof Map)) {
            throw new IllegalArgumentException("Map argument expected");
        }
        HashMap<String, Object> argsMap = (HashMap<String, Object>) call.arguments;
        BranchEvent event = branchSdkHelper.convertToEvent((HashMap<String, Object>) argsMap.get("event"));
        event.logEvent(context);
    }

    private void setIdentity(MethodCall call) {
        if (!(call.arguments instanceof Map)) {
            throw new IllegalArgumentException("Map argument expected");
        }
        String userId = call.argument("userId");
        Branch.getInstance(context).setIdentity(userId);
    }

    private void setRequestMetadata(MethodCall call) {
        if (!(call.arguments instanceof Map)) {
            throw new IllegalArgumentException("Map argument expected");
        }
        String key = call.argument("key");
        String value = call.argument("value");

        Branch.getInstance(context).setRequestMetadata(key, value);
    }

    private void logout() {
        Branch.getInstance(context).logout();
    }

    private void getLatestReferringParams(Result result) {
        JSONObject sessionParams = Branch.getInstance(context).getLatestReferringParams();
        try {
            result.success(branchSdkHelper.paramsToMap(sessionParams));
        } catch (JSONException e) {
            e.printStackTrace();
            result.error(DEBUG_NAME, e.getMessage(), null);
        }
    }

    private void getFirstReferringParams(Result result) {
        JSONObject sessionParams = Branch.getInstance(context).getFirstReferringParams();
        try {
            result.success(branchSdkHelper.paramsToMap(sessionParams));
        } catch (JSONException e) {
            e.printStackTrace();
            result.error(DEBUG_NAME, e.getMessage(), null);
        }
    }

    private void setTrackingDisabled(MethodCall call) {
        if (!(call.arguments instanceof Map)) {
            throw new IllegalArgumentException("Map argument expected");
        }
        boolean value = call.argument("disable");
        Branch.getInstance().disableTracking(value);
    }

    private void loadRewards(final MethodCall call, final Result result) {

        final Map<String, Object> response = new HashMap<>();
        Branch.getInstance(context).loadRewards(new Branch.BranchReferralStateChangedListener() {
            @Override
            public void onStateChanged(boolean changed, @Nullable BranchError error) {
                int credits;
                if (error == null) {
                    if (!call.hasArgument("bucket")) {
                        credits = Branch.getInstance(context).getCredits();
                    } else {
                        credits = Branch.getInstance(context).getCreditsForBucket(call.argument("bucket").toString());
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
        if (!(call.arguments instanceof Map)) {
            throw new IllegalArgumentException("Map argument expected");
        }

        final int count = call.argument("count");
        final Map<String, Object> response = new HashMap<>();

        if (!call.hasArgument("bucket")) {
            Branch.getInstance(context).redeemRewards(count, new Branch.BranchReferralStateChangedListener() {
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
            Branch.getInstance(context).redeemRewards(call.argument("bucket").toString(), count, new Branch.BranchReferralStateChangedListener() {
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
        if (!(call.arguments instanceof Map)) {
            throw new IllegalArgumentException("Map argument expected");
        }
        final Map<String, Object> response = new HashMap<>();

        if (!call.hasArgument("bucket")) {
            Branch.getInstance(context).getCreditHistory(new Branch.BranchListResponseListener() {
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
            Branch.getInstance(context).getCreditHistory(call.argument("bucket").toString(), new Branch.BranchListResponseListener() {
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
        result.success(Branch.getInstance(context).isUserIdentified());
    }
}
