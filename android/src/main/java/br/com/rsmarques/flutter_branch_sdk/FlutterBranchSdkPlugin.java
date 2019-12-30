package br.com.rsmarques.flutter_branch_sdk;

import android.app.Activity;
import android.app.Application;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;

import androidx.annotation.NonNull;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import io.branch.indexing.BranchUniversalObject;
import io.branch.referral.Branch;
import io.branch.referral.BranchError;
import io.branch.referral.util.AdType;
import io.branch.referral.util.BRANCH_STANDARD_EVENT;
import io.branch.referral.util.BranchContentSchema;
import io.branch.referral.util.BranchEvent;
import io.branch.referral.util.ContentMetadata;
import io.branch.referral.util.CurrencyType;
import io.branch.referral.util.LinkProperties;
import io.branch.referral.util.ProductCategory;
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

/**
 * FlutterBranchSdkPlugin
 */
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

    /**
     * Plugin registration.
     */

    public static void registerWith(Registrar registrar) {
        FlutterBranchSdkPlugin plugin = new FlutterBranchSdkPlugin();
        plugin.setupChannels(registrar.messenger(), registrar.context());
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
        this.activity = null;

        methodChannel = new MethodChannel(messenger, MESSAGE_CHANNEL);
        eventChannel = new EventChannel(messenger, EVENT_CHANNEL);

        methodChannel.setMethodCallHandler(this);
        eventChannel.setStreamHandler(this);

        FlutterBranchSdkInit.init(this.context);
    }

    private void teardownChannels() {
        this.activityPluginBinding = null;
        this.activity = null;
        this.context = null;
    }

    @Override
    public void onAttachedToActivity(ActivityPluginBinding binding) {
        this.activity = binding.getActivity();
        this.activityPluginBinding = binding;

        activity.getApplication().registerActivityLifecycleCallbacks(this);
        binding.addOnNewIntentListener(this);
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
    public void onReattachedToActivityForConfigChanges(ActivityPluginBinding binding) {
        onAttachedToActivity(binding);
    }

    @Override
    public void onListen(Object o, EventChannel.EventSink eventSink) {
        this.eventSink = eventSink;
    }

    @Override
    public void onCancel(Object o) {
        this.eventSink = null;
    }

    @Override
    public void onActivityCreated(Activity activity, Bundle bundle) {
        Log.d(DEBUG_NAME, "Activity Created");
    }

    @Override
    public void onActivityStarted(Activity activity) {
        Log.d(DEBUG_NAME, "Activity Started");
        Branch.getInstance().initSession(branchReferralInitListener, activity.getIntent().getData(), activity);
    }

    @Override
    public void onActivityResumed(Activity activity) {
        Log.d(DEBUG_NAME, "Activity Resumed");
    }

    @Override
    public void onActivityPaused(Activity activity) {
        Log.d(DEBUG_NAME, "Activity Paused");
    }

    @Override
    public void onActivityStopped(Activity activity) {
        Log.d(DEBUG_NAME, "Activity Stopped");
    }

    @Override
    public void onActivitySaveInstanceState(Activity activity, Bundle bundle) {
        Log.d(DEBUG_NAME, "Activity SaveInstance");
    }

    @Override
    public void onActivityDestroyed(Activity activity) {
        Log.d(DEBUG_NAME, "Activity Destroy");
        if (this.activity == activity) {
            activity.getApplication().unregisterActivityLifecycleCallbacks(this);
        }
    }

    @Override
    public boolean onNewIntent(Intent intent) {
        Log.d(DEBUG_NAME, " onNewIntent");
        if (this.activity != null) {
            intent.putExtra("branch_force_new_session", true);
            activity.setIntent(intent);
            Branch.getInstance().reInitSession(activity, branchReferralInitListener);
        }
        return true;
    }

    //----------------------------------------------------------------------------------------------

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
            case "setIdentity":
                setIdentity(call);
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
            default:
                result.notImplemented();
        }
    }

    //----------------------------------------------------------------------------------------------

    private Branch.BranchReferralInitListener branchReferralInitListener = new
            Branch.BranchReferralInitListener() {
                @Override
                public void onInitFinished(JSONObject params, BranchError error) {
                    if (error == null) {
                        Log.d(DEBUG_NAME, "branchReferralInitListener" + params.toString());
                        if (eventSink == null) {
                            return;
                        }
                        try {
                            eventSink.success(paramsToMap(params));
                        } catch (JSONException e) {
                            e.printStackTrace();
                        }
                    } else {
                        Log.d(DEBUG_NAME, "branchReferralInitListener - error: " + error.toString());
                    }
                }
            };
    //----------------------------------------------------------------------------------------------

    private void validateSDKIntegration() {
        IntegrationValidator.validate(activity);
    }

    private void getShortUrl(MethodCall call, final Result result) {
        if (!(call.arguments instanceof Map)) {
            throw new IllegalArgumentException("Map argument expected");
        }

        HashMap<String, Object> argsMap = (HashMap<String, Object>) call.arguments;
        BranchUniversalObject buo = convertToBUO((HashMap<String, Object>) argsMap.get("buo"));

        LinkProperties linkProperties = convertToLinkProperties((HashMap<String, Object>) argsMap.get("lp"));

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
                    response.put("errorDescription", error.getMessage());
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
        BranchUniversalObject buo = convertToBUO((HashMap<String, Object>) argsMap.get("buo"));

        LinkProperties linkProperties = convertToLinkProperties((HashMap<String, Object>) argsMap.get("lp"));
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
                            response.put("errorDescription", error.getMessage());
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
        BranchUniversalObject buo = convertToBUO((HashMap<String, Object>) argsMap.get("buo"));
        buo.registerView();
    }

    private void listOnSearch(MethodCall call, Result result) {
        if (!(call.arguments instanceof Map)) {
            throw new IllegalArgumentException("Map argument expected");
        }
        HashMap<String, Object> argsMap = (HashMap<String, Object>) call.arguments;
        BranchUniversalObject buo = convertToBUO((HashMap<String, Object>) argsMap.get("buo"));
        if (argsMap.containsKey("lp")) {
            LinkProperties linkProperties = convertToLinkProperties((HashMap<String, Object>) argsMap.get("lp"));
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
        BranchUniversalObject buo = convertToBUO((HashMap<String, Object>) argsMap.get("buo"));
        if (argsMap.containsKey("lp")) {
            LinkProperties linkProperties = convertToLinkProperties((HashMap<String, Object>) argsMap.get("lp"));
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
        BranchUniversalObject buo = convertToBUO((HashMap<String, Object>) argsMap.get("buo"));
        BranchEvent event = convertToEvent((HashMap<String, Object>) argsMap.get("event"));
        event.addContentItems(buo).logEvent(context);
    }

    private void setIdentity(MethodCall call) {
        if (!(call.arguments instanceof Map)) {
            throw new IllegalArgumentException("Map argument expected");
        }
        String userId = call.argument("userId");
        Branch.getInstance(context).setIdentity(userId);
    }

    private void logout() {
        Branch.getInstance(context).logout();
    }

    private void getLatestReferringParams(Result result) {
        JSONObject sessionParams = Branch.getInstance(context).getLatestReferringParams();
        try {
            result.success(paramsToMap(sessionParams));
        } catch (JSONException e) {
            e.printStackTrace();
            result.error(DEBUG_NAME, e.getMessage(), null);
        }
    }

    private void getFirstReferringParams(Result result) {
        JSONObject sessionParams = Branch.getInstance(context).getFirstReferringParams();
        try {
            result.success(paramsToMap(sessionParams));
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

    private BranchUniversalObject convertToBUO(HashMap<String, Object> argsMap) {

        BranchUniversalObject buo = new BranchUniversalObject();
        String canonicalIdentifier = (String) argsMap.get("canonicalIdentifier");
        buo.setCanonicalIdentifier(canonicalIdentifier);

        if (argsMap.containsKey("canonicalUrl"))
            buo.setCanonicalIdentifier((String) argsMap.get("canonicalUrl"));
        if (argsMap.containsKey("title"))
            buo.setTitle((String) argsMap.get("title"));
        if (argsMap.containsKey("contentDescription"))
            buo.setContentDescription((String) argsMap.get("contentDescription"));
        if (argsMap.containsKey("imageUrl"))
            buo.setContentImageUrl((String) argsMap.get("imageUrl"));
        if (argsMap.containsKey("keywords"))
            buo.addKeyWords((ArrayList<String>) argsMap.get("keywords"));
        if (argsMap.containsKey("expirationDate"))
            buo.setContentExpiration((Date) argsMap.get("expirationDate"));
        if (argsMap.containsKey("locallyIndex")) {
            boolean value = (boolean) argsMap.get("locallyIndex");
            if (value) {
                buo.setLocalIndexMode(BranchUniversalObject.CONTENT_INDEX_MODE.PUBLIC);
            } else
                buo.setLocalIndexMode(BranchUniversalObject.CONTENT_INDEX_MODE.PRIVATE);
        }
        if (argsMap.containsKey("publiclyIndex")) {
            boolean value = (boolean) argsMap.get("publiclyIndex");
            if (value) {
                buo.setContentIndexingMode(BranchUniversalObject.CONTENT_INDEX_MODE.PUBLIC);
            } else
                buo.setContentIndexingMode(BranchUniversalObject.CONTENT_INDEX_MODE.PRIVATE);
        }
        if (argsMap.containsKey("contentMetadata")) {
            HashMap<String, Object> contentMap = (HashMap<String, Object>) argsMap.get("contentMetadata");
            ContentMetadata contentMetadata = new ContentMetadata();
            if (contentMap.containsKey("quantity"))
                contentMetadata.setQuantity((double) contentMap.get("quantity"));
            if (contentMap.containsKey("price") && contentMap.containsKey("currency")) {
                contentMetadata.setPrice((double) contentMap.get("price"), CurrencyType.getValue((String) contentMap.get("currency")));
            }
            if (contentMap.containsKey("rating_average") || contentMap.containsKey("rating_count") ||
                    contentMap.containsKey("rating_max") || contentMap.containsKey("rating")) {
                Double rating = null;
                if (contentMap.containsKey("rating")) {
                    rating = (double) contentMap.get("rating");
                }
                Double rating_average = null;
                if (contentMap.containsKey("rating_average")) {
                    rating_average = (double) contentMap.get("rating_average");
                }
                Integer rating_count = null;
                if (contentMap.containsKey("rating_count")) {
                    rating_count = (Integer) contentMap.get("rating_count");
                }
                Double rating_max = null;
                if (contentMap.containsKey("rating_max")) {
                    rating_max = (double) contentMap.get("rating_max");
                }
                contentMetadata.setRating(rating, rating_average, rating_max, rating_count);
            }
            if (contentMap.containsKey("latitude") && contentMap.containsKey("longitude")) {
                contentMetadata.setLocation((double) contentMap.get("latitude"), (double) contentMap.get("longitude"));
            }
            if (contentMap.containsKey("address_street") || contentMap.containsKey("address_city") ||
                    contentMap.containsKey("address_region") || contentMap.containsKey("address_country") || contentMap.containsKey("address_postal_code")) {
                String street = (String) contentMap.get("address_street");
                String city = (String) contentMap.get("address_city");
                String region = (String) contentMap.get("address_region");
                String country = (String) contentMap.get("address_country");
                String postal_code = (String) contentMap.get("address_postal_code");
                contentMetadata.setAddress(street, city, region, country, postal_code);
            }
            if (contentMap.containsKey("content_schema")) {
                contentMetadata.setContentSchema(BranchContentSchema.getValue((String) contentMap.get("content_schema")));
            }
            if (contentMap.containsKey("sku")) {
                contentMetadata.setSku((String) contentMap.get("sku"));
            }
            if (contentMap.containsKey("product_name")) {
                contentMetadata.setProductName((String) contentMap.get("product_name"));
            }
            if (contentMap.containsKey("product_brand")) {
                contentMetadata.setProductBrand((String) contentMap.get("product_brand"));
            }
            if (contentMap.containsKey("product_category")) {
                contentMetadata.setProductCategory(ProductCategory.getValue((String) contentMap.get("product_category")));
            }
            if (contentMap.containsKey("product_variant")) {
                contentMetadata.setProductVariant((String) contentMap.get("product_variant"));
            }
            if (contentMap.containsKey("condition")) {
                contentMetadata.setProductCondition(ContentMetadata.CONDITION.getValue((String) contentMap.get("product_category")));
            }
            if (contentMap.containsKey("image_captions")) {
                ArrayList<String> _imageCaptions = (ArrayList<String>) contentMap.get("image_captions");
                for (int i = 0; i < _imageCaptions.size(); i++) {
                    contentMetadata.addImageCaptions(_imageCaptions.get(i));
                }
            }
            if (contentMap.containsKey("customMetadata")) {
                for (Map.Entry<String, Object> customMetaData : ((HashMap<String, Object>) contentMap.get("customMetadata")).entrySet()) {
                    contentMetadata.addCustomMetadata(customMetaData.getKey(), customMetaData.getValue().toString());
                }
            }
            buo.setContentMetadata(contentMetadata);
        }
        return buo;
    }

    private LinkProperties convertToLinkProperties(HashMap<String, Object> argsMap) {

        LinkProperties linkProperties = new LinkProperties();

        if (argsMap.containsKey("channel"))
            linkProperties.setChannel((String) argsMap.get("channel"));
        if (argsMap.containsKey("feature"))
            linkProperties.setFeature((String) argsMap.get("feature"));
        if (argsMap.containsKey("campaign"))
            linkProperties.setCampaign((String) argsMap.get("campaign"));
        if (argsMap.containsKey("stage"))
            linkProperties.setStage((String) argsMap.get("stage"));
        if (argsMap.containsKey("alias"))
            linkProperties.setAlias((String) argsMap.get("alias"));
        if (argsMap.containsKey("matchDuration"))
            linkProperties.setDuration((int) argsMap.get("matchDuration"));
        if (argsMap.containsKey("tags")) {
            ArrayList<String> _tags = (ArrayList<String>) argsMap.get("tags");
            for (int i = 0; i < _tags.size(); i++) {
                linkProperties.addTag(_tags.get(i));
            }
        }
        if (argsMap.containsKey("controlParams")) {
            for (Map.Entry<String, String> content : ((HashMap<String, String>) argsMap.get("controlParams")).entrySet()) {
                linkProperties.addControlParameter(content.getKey(), content.getValue());
            }
        }
        return linkProperties;
    }

    private BranchEvent convertToEvent(HashMap<String, Object> eventMap) {
        BranchEvent event;

        if ((boolean) eventMap.get("isStandardEvent")) {
            event = new BranchEvent(BRANCH_STANDARD_EVENT.valueOf((String) eventMap.get("eventName")));
        } else {
            event = new BranchEvent((String) eventMap.get("eventName"));
        }

        if (eventMap.containsKey("transactionID"))
            event.setTransactionID((String) eventMap.get("transactionID"));
        if (eventMap.containsKey("currency"))
            event.setCurrency(CurrencyType.getValue((String) eventMap.get("currency")));
        if (eventMap.containsKey("revenue"))
            event.setRevenue((Double) eventMap.get("revenue"));
        if (eventMap.containsKey("shipping"))
            event.setShipping((Double) eventMap.get("shipping"));
        if (eventMap.containsKey("tax"))
            event.setTax((Double) eventMap.get("tax"));
        if (eventMap.containsKey("coupon"))
            event.setCoupon((String) eventMap.get("coupon"));
        if (eventMap.containsKey("affiliation"))
            event.setAffiliation((String) eventMap.get("affiliation"));
        if (eventMap.containsKey("eventDescription"))
            event.setDescription((String) eventMap.get("eventDescription"));
        if (eventMap.containsKey("searchQuery"))
            event.setSearchQuery((String) eventMap.get("searchQuery"));
        if (eventMap.containsKey("adType"))
            event.setAdType(convertToAdType((String) eventMap.get("adType")));
        if (eventMap.containsKey("customData")) {
            for (Map.Entry<String, String> customData : ((HashMap<String, String>) eventMap.get("customData")).entrySet()) {
                event.addCustomDataProperty(customData.getKey(), customData.getValue());
            }
        }
        return event;
    }

    private AdType convertToAdType(String adType) {
        switch (adType) {
            case "BANNER":
                return AdType.BANNER;
            case "INTERSTITIAL":
                return AdType.INTERSTITIAL;
            case "REWARDED_VIDEO":
                return AdType.REWARDED_VIDEO;
            case "NATIVE":
                return AdType.NATIVE;
            default:
                throw new IllegalStateException("Unexpected value: " + adType);
        }
    }

    //----------------------------------------------------------------------------------------------

    private Map<String, Object> paramsToMap(JSONObject jsonObject) throws JSONException {
        Map<String, Object> map = new HashMap<>();
        Iterator<String> keys = jsonObject.keys();
        while (keys.hasNext()) {
            String key = keys.next();
            Object value = jsonObject.get(key);
            if (value instanceof JSONArray) {
                value = jsonArrayToList((JSONArray) value);
            } else if (value instanceof JSONObject) {
                value = paramsToMap((JSONObject) value);
            }
            map.put(key, value);
        }
        return map;
    }

    private List<Object> jsonArrayToList(JSONArray array) throws JSONException {
        List<Object> list = new ArrayList<>();
        for (int i = 0; i < array.length(); i++) {
            Object value = array.get(i);
            if (value instanceof JSONArray) {
                value = jsonArrayToList((JSONArray) value);
            } else if (value instanceof JSONObject) {
                value = paramsToMap((JSONObject) value);
            }
            list.add(value);
        }
        return list;
    }
}
