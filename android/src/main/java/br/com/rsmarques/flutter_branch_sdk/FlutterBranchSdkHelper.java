package br.com.rsmarques.flutter_branch_sdk;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.time.Instant;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import io.branch.indexing.BranchUniversalObject;
import io.branch.referral.QRCode.BranchQRCode;
import io.branch.referral.util.AdType;
import io.branch.referral.util.BRANCH_STANDARD_EVENT;
import io.branch.referral.util.BranchContentSchema;
import io.branch.referral.util.BranchEvent;
import io.branch.referral.util.ContentMetadata;
import io.branch.referral.util.CurrencyType;
import io.branch.referral.util.LinkProperties;
import io.branch.referral.util.ProductCategory;

public class FlutterBranchSdkHelper {
    /**---------------------------------------------------------------------------------------------
     Object Conversion Functions
     --------------------------------------------------------------------------------------------**/
    BranchUniversalObject convertToBUO(HashMap<String, Object> argsMap) {

        BranchUniversalObject buo = new BranchUniversalObject();
        String canonicalIdentifier = (String) argsMap.get("canonicalIdentifier");
        buo.setCanonicalIdentifier(canonicalIdentifier);

        if (argsMap.containsKey("canonicalUrl"))
            buo.setCanonicalUrl((String) argsMap.get("canonicalUrl"));
        if (argsMap.containsKey("title"))
            buo.setTitle((String) argsMap.get("title"));
        if (argsMap.containsKey("contentDescription"))
            buo.setContentDescription((String) argsMap.get("contentDescription"));
        if (argsMap.containsKey("imageUrl"))
            buo.setContentImageUrl((String) argsMap.get("imageUrl"));
        if (argsMap.containsKey("keywords"))
            buo.addKeyWords((ArrayList<String>) argsMap.get("keywords"));
        if (argsMap.containsKey("expirationDate"))
            buo.setContentExpiration(new Date((long) argsMap.get("expirationDate")));

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

    LinkProperties convertToLinkProperties(HashMap<String, Object> argsMap) {

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

    BranchEvent convertToEvent(HashMap<String, Object> eventMap) {
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

    BranchQRCode convertToQRCode(HashMap<String, Object> qrCodeMap) {
        BranchQRCode branchQRCode = new BranchQRCode();
        if (qrCodeMap.containsKey("width")) {
            branchQRCode.setWidth((int) qrCodeMap.get("width"));
        }
        if (qrCodeMap.containsKey("margin")) {
            branchQRCode.setMargin((int) qrCodeMap.get("margin"));
        }
        if (qrCodeMap.containsKey("codeColor")) {
            branchQRCode.setCodeColor((String) qrCodeMap.get("codeColor"));
        }
        if (qrCodeMap.containsKey("backgroundColor")) {
            branchQRCode.setBackgroundColor((String) qrCodeMap.get("backgroundColor"));
        }
        if (qrCodeMap.containsKey("imageFormat")) {
            final String imageFormat = (String) qrCodeMap.get("imageFormat");
            if (imageFormat.equals("JPEG")) {
                branchQRCode.setImageFormat(BranchQRCode.BranchImageFormat.JPEG);
            } else {
                branchQRCode.setImageFormat(BranchQRCode.BranchImageFormat.PNG);
            }
        }
        if (qrCodeMap.containsKey("centerLogoUrl")) {
            branchQRCode.setCenterLogo((String) qrCodeMap.get("centerLogoUrl"));
        }
        return  branchQRCode;
    }

    AdType convertToAdType(String adType) {
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

    Map<String, Object> paramsToMap(JSONObject jsonObject) throws JSONException {
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

    List<Object> jsonArrayToList(JSONArray array) throws JSONException {
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
