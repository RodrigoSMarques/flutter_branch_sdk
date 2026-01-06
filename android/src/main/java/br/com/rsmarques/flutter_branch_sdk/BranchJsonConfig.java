package br.com.rsmarques.flutter_branch_sdk;

import android.content.Context;
import org.json.JSONException;
import org.json.JSONObject;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import io.flutter.embedding.engine.plugins.FlutterPlugin;

public class BranchJsonConfig {
    private static final String DEBUG_NAME = "FlutterBranchSDK";

    public final String apiUrl;
    public final String branchKey;
    public final String liveKey;
    public final String testKey;
    public final Boolean enableLogging;
    public final String logLevel;
    public final Boolean useTestInstance;

    public final String apiUrlAndroid;
    public final String apiUrlIOS;

    private BranchJsonConfig(JSONObject jsonObject) {
        this.apiUrl = jsonObject.optString("apiUrl", "");
        this.apiUrlAndroid = jsonObject.optString("apiUrlAndroid", "");
        this.apiUrlIOS = jsonObject.optString("apiUrlIOS", "");
        this.branchKey = jsonObject.optString("branchKey", "");
        this.liveKey = jsonObject.optString("liveKey", "");
        this.testKey = jsonObject.optString("testKey", "");
        this.enableLogging = jsonObject.has("enableLogging") && jsonObject.optBoolean("enableLogging");
        this.logLevel = jsonObject.optString("logLevel", "VERBOSE");
        this.useTestInstance = jsonObject.has("useTestInstance") && jsonObject.optBoolean("useTestInstance");
    }

    public static BranchJsonConfig loadFromFile(Context context, FlutterPlugin.FlutterPluginBinding binding) {
        try {
            String assetKey = binding.getFlutterAssets().getAssetFilePathByName("assets/branch-config.json");

            try (InputStream inputStream = context.getAssets().open(assetKey)) {
                BufferedReader reader = new BufferedReader(new InputStreamReader(inputStream));
                StringBuilder stringBuilder = new StringBuilder();
                String line;
                while ((line = reader.readLine()) != null) {
                    stringBuilder.append(line);
                }
                JSONObject jsonObject = new JSONObject(stringBuilder.toString());
                return new BranchJsonConfig(jsonObject);
            }
        } catch (IOException e) {
            //File 'assets/branch-config.json' not exists
            return null;
        } catch (JSONException e) {
            LogUtils.debug(DEBUG_NAME, "Failed to decode 'assets/branch-config.json'. Check if the JSON is valid. Error: " + e);
            return null;
        }
    }
}