import Flutter
import UIKit
import BranchSDK
import AppTrackingTransparency
import AdSupport

// Plugin channel variables and constants
var methodChannel: FlutterMethodChannel?
var eventChannel: FlutterEventChannel?
var logEventChannel : FlutterEventChannel?
var logStreamHandler: LogStreamHandler?
let MESSAGE_CHANNEL = "flutter_branch_sdk/message";
let EVENT_CHANNEL = "flutter_branch_sdk/event";
let LOG_CHANNEL = "flutter_branch_sdk/logStream";
let ERROR_CODE = "FLUTTER_BRANCH_SDK_ERROR";
let PLUGIN_NAME = "Flutter";
let PLUGIN_VERSION = "8.11.0";
let COCOA_POD_NAME = "org.cocoapods.flutter-branch-sdk";

//---------------------------------------------------------------------------------------------
// LogStreamHandler - Separate handler for log events
// --------------------------------------------------------------------------------------------
public class LogStreamHandler: NSObject, FlutterStreamHandler {
    var logEventSink: FlutterEventSink?
    private var logBuffer: [String] = []
    private let bufferLock = NSLock()
    
    public func onListen(withArguments arguments: Any?, eventSink: @escaping FlutterEventSink) -> FlutterError? {
        self.logEventSink = eventSink
        
        // Send buffered log messages
        bufferLock.lock()
        for bufferedMessage in logBuffer {
            eventSink(bufferedMessage)
        }
        logBuffer.removeAll()
        bufferLock.unlock()
        
        LogUtils.debug(message: "LOG_CHANNEL listener attached")
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        logEventSink = nil
        LogUtils.debug(message: "LOG_CHANNEL listener cancelled")
        return nil
    }
    
    private func logLevelName(_ level: BranchLogLevel) -> String {
        switch level {
        case .verbose:
            return "VERBOSE"
        case .debug:
            return "DEBUG"
        case .warning:
            return "WARNING"
        case .error:
            return "ERROR"
        @unknown default:
            return "UNKNOWN"
        }
    }
    
    // Enable Branch logging with callback and buffering
    public func enableBranchLogging(at level: BranchLogLevel) {
        Branch.enableLogging(at: level) { (message: String, logLevel: BranchLogLevel, error: Error?) in
            let levelName = self.logLevelName(logLevel)
            let formattedMessage = "[Branch \(levelName)] \(message)"
            
            self.bufferLock.lock()
            if let sink = self.logEventSink {
                // Send on main thread to comply with Flutter platform channel requirements
                DispatchQueue.main.async {
                    sink(formattedMessage)
                }
            } else {
                // Buffer the message if sink is not ready
                self.logBuffer.append(formattedMessage)
            }
            self.bufferLock.unlock()
        }
    }
}

public class FlutterBranchSdkPlugin: NSObject, FlutterPlugin, FlutterStreamHandler  {
    var eventSink: FlutterEventSink?
    var logEventSink: FlutterEventSink?
    var initialParams : [String: Any]? = nil
    var initialError : NSError? = nil
    
    var branch : Branch?
    var isInitialized = false
    
    var requestMetadata : [String: String] = [:]
    var facebookParameters : [String: String] = [:]
    var snapParameters : [String: String] = [:]
    static var branchJsonConfig: BranchJsonConfig? = nil
    
    //---------------------------------------------------------------------------------------------
    // Plugin registry
    // --------------------------------------------------------------------------------------------
    public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = FlutterBranchSdkPlugin()
        let handler = LogStreamHandler()
        logStreamHandler = handler
        
        methodChannel = FlutterMethodChannel(name: MESSAGE_CHANNEL, binaryMessenger: registrar.messenger())
        eventChannel = FlutterEventChannel(name: EVENT_CHANNEL, binaryMessenger: registrar.messenger())
        eventChannel!.setStreamHandler(instance)
        
        logEventChannel = FlutterEventChannel(name: LOG_CHANNEL, binaryMessenger: registrar.messenger())
        logEventChannel!.setStreamHandler(handler)
        
        registrar.addApplicationDelegate(instance)
        registrar.addMethodCallDelegate(instance, channel: methodChannel!)
        
        self.branchJsonConfig = BranchJsonConfig.loadFromFile(registrar: registrar)
        
    }
        
    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [AnyHashable : Any] = [:]) -> Bool {
        
        if let branchJsonConfig = FlutterBranchSdkPlugin.branchJsonConfig {

            if let apiUrl = branchJsonConfig.apiUrl as? String {
                LogUtils.debug(message: "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
                LogUtils.debug(message: "The apiUrl parameter has been deprecated. Please use apiUrlIOS instead. Check the documentation.")
                LogUtils.debug(message: "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
                return false
              }

            if let apiUrlIOS = branchJsonConfig.apiUrlIOS as? String {
                Branch.setAPIUrl(apiUrlIOS)
                LogUtils.debug(message: "Set API URL from branch-config.json: \(apiUrlIOS)")
              }
            
            if let branchKey = branchJsonConfig.branchKey as? String {
                Branch.setBranchKey(branchKey)
                LogUtils.debug(message: "Set BranchKey from branch-config.json: \(branchKey)")
            } else {
                let testKey = branchJsonConfig.testKey ?? ""
                let liveKey = branchJsonConfig.liveKey  ?? ""
                
                let useTestInstance = branchJsonConfig.useTestInstance ?? false
                
                if (useTestInstance && !testKey.isEmpty) {
                    Branch.setBranchKey(testKey)
                    LogUtils.debug(message: "Set TestKey from branch-config.json: \(testKey)")
                } else if (!liveKey.isEmpty) {
                    Branch.setBranchKey(liveKey)
                    LogUtils.debug(message: "Set LiveKey from branch-config.json: \(liveKey)")
                }
            }
        }
        
        Branch.getInstance().registerPluginName(PLUGIN_NAME, version:  PLUGIN_VERSION)
        
        // Enable Branch logging BEFORE initSession to capture all logs
        if let branchJsonConfig = FlutterBranchSdkPlugin.branchJsonConfig {
            if let enableLogging = branchJsonConfig.enableLogging as? Bool {
                if (enableLogging) {
                    let logLevelStr = branchJsonConfig.logLevel ?? "VERBOSE"
                    let logLevel = mapLogLevel(logLevelStr)
                    // Enable Branch logging with callback through LogStreamHandler
                    if let handler = logStreamHandler {
                        handler.enableBranchLogging(at: logLevel)
                    }
                    LogUtils.debug(message: "Set enableLogging and logLevel from branch-config.json: \(logLevelStr)")
                }
            }
        }
        
        let disable_nativelink: Bool = Bundle.main.object(forInfoDictionaryKey: "branch_disable_nativelink") as? Bool ?? false
        LogUtils.debug(message: "Disable NativeLink: \(String(describing:disable_nativelink))")
        
        if !disable_nativelink {
            if #available(iOS 15.0, *) {
                Branch.getInstance().checkPasteboardOnInstall()
            }
        }
        
        Branch.getInstance().initSession(launchOptions: launchOptions) { (params, error) in
            if error == nil {
                LogUtils.debug(message: "InitSession params: \(String(describing: params as? [String: Any]))")
                guard let _ = self.eventSink else {
                    self.initialParams = params as? [String: Any]
                    return
                }
                // Send on main thread to comply with Flutter platform channel requirements
                DispatchQueue.main.async {
                    self.eventSink!(params as? [String: Any])
                }
            } else {
                let err = (error! as NSError)
                LogUtils.debug(message: "Branch InitSession error: \(err.localizedDescription)")
                guard let _ = self.eventSink else {
                    self.initialError = err
                    return
                }
                // Send on main thread to comply with Flutter platform channel requirements
                DispatchQueue.main.async {
                    self.eventSink!(FlutterError(code: String(err.code), message: err.localizedDescription, details: nil))
                }
            }
        }
        return true
    }
    
    public func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return Branch.getInstance().application(app, open: url, options: options)
    }
    
    public func application(_ app: UIApplication, open url: URL, sourceApplication: String, annotation: Any) -> Bool {
        return Branch.getInstance().application(app, open: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    public func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]) -> Void) -> Bool {
        return Branch.getInstance().continue(userActivity)
    }
    
    public func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        Branch.getInstance().handlePushNotification(userInfo)
    }
    
    //---------------------------------------------------------------------------------------------
    // FlutterStreamHandler Interface Methods
    // --------------------------------------------------------------------------------------------
    public func onListen(withArguments arguments: Any?, eventSink: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = eventSink
        if (initialParams != nil) {
            self.eventSink!(self.initialParams)
        } else if (initialError != nil) {
            self.eventSink!(FlutterError(code: String(self.initialError!.code),message: self.initialError!.localizedDescription, details: nil))
        }
        initialParams = nil
        initialError = nil
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        eventSink = nil
        initialParams = nil
        initialError = nil
        return nil
    }
    
    //---------------------------------------------------------------------------------------------
    // FlutterMethodChannel Interface Methods
    // --------------------------------------------------------------------------------------------
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch (call.method) {
        case "init":
            setupBranch(call: call, result: result)
            break
        case "getShortUrl":
            getShortUrl(call: call, result: result)
            break
        case "showShareSheet":
            showShareSheet(call: call, result: result)
            break
        case "registerView":
            registerView(call: call)
            break
        case "listOnSearch":
            listOnSearch(call: call, result: result)
            break
        case "removeFromSearch":
            removeFromSearch(call: call, result: result)
            break
        case "trackContent":
            trackContent(call: call)
            break
        case "trackContentWithoutBuo":
            trackContentWithoutBuo(call: call)
            break
        case "setIdentity":
            setIdentity(call: call)
            break
        case "setRequestMetadata":
            setRequestMetadata(call: call);
            break
        case "logout":
            logout()
            break
        case "getLatestReferringParams":
            getLatestReferringParams(result: result)
            break
        case "getFirstReferringParams":
            getFirstReferringParams(result: result)
            break
        case "setTrackingDisabled":
            setTrackingDisabled(call: call)
            break
        case "validateSDKIntegration":
            validateSDKIntegration()
            break
        case "isUserIdentified":
            isUserIdentified(result: result)
            break
        case "requestTrackingAuthorization" :
            requestTrackingAuthorization(result: result)
            break
        case "getTrackingAuthorizationStatus" :
            getTrackingAuthorizationStatus(result: result)
            break
        case "getAdvertisingIdentifier" :
            getAdvertisingIdentifier(result: result)
            break
        case "setConnectTimeout":
            setConnectTimeout(call: call)
            break
        case "setRetryCount":
            setRetryCount(call: call)
            break
        case "setRetryInterval":
            setRetryInterval(call: call)
            break
        case "setTimeout":
            setTimeout(call: call)
            break
        case "getLastAttributedTouchData":
            getLastAttributedTouchData(call: call, result: result)
            break
        case "getQRCode":
            getQRCode(call: call, result: result)
            break
        case "shareWithLPLinkMetadata":
            shareWithLPLinkMetadata(call: call, result: result)
            break
        case "handleDeepLink":
            handleDeepLink(call: call)
            break
        case "addFacebookPartnerParameter" :
            addFacebookPartnerParameter(call: call)
            break
        case  "clearPartnerParameters" :
            Branch.getInstance().clearPartnerParameters()
            break
        case "setPreinstallCampaign" :
            setPreinstallPartner(call: call)
            break
        case "setPreinstallPartner" :
            setPreinstallPartner(call: call)
            break
        case "addSnapPartnerParameter" :
            addSnapPartnerParameter(call: call)
            break
        case "setDMAParamsForEEA":
            setDMAParamsForEEA(call: call)
            break;
        case "setConsumerProtectionAttributionLevel" :
            setConsumerProtectionAttributionLevel(call: call)
            break;
        case "setAnonID":
            setAnonID(call: call)
            break;
        case "setSDKWaitTimeForThirdPartyAPIs":
            setSDKWaitTimeForThirdPartyAPIs(call: call)
            break;
        default:
            result(FlutterMethodNotImplemented)
            break
        }
    }
    
    //---------------------------------------------------------------------------------------------
    // Helper Functions
    // --------------------------------------------------------------------------------------------
    
    private func getRootViewController() -> UIViewController? {
        if #available(iOS 13.0, *) {
            let windowScene = UIApplication.shared.connectedScenes
                .filter { $0.activationState == .foregroundActive }
                .first as? UIWindowScene
            return windowScene?.windows.first(where: { $0.isKeyWindow })?.rootViewController
        } else {
            return UIApplication.shared.keyWindow?.rootViewController
        }
    }
    
    private func flutterError(message: String, details: Any? = nil) -> FlutterError {
        return FlutterError(code: ERROR_CODE, message: message, details: details)
    }
    
    //---------------------------------------------------------------------------------------------
    // Branch SDK Call Methods
    // --------------------------------------------------------------------------------------------
    private func setupBranch(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let enableLogging = args["enableLogging"] as? Bool,
              let logLevel = args["logLevel"] as? String,
              let branchAttributionLevel = args["branchAttributionLevel"] as? String
        else {
            result(flutterError(message: "Invalid arguments provided for setupBranch", details: call.arguments))
            return
        }
        
        LogUtils.debug(message: "setupBranch args: \(args)")
        
        if isInitialized {
            result(true)
            return
        }

        if !branchAttributionLevel.isEmpty {
            Branch.getInstance().setConsumerProtectionAttributionLevel(BranchAttributionLevel(rawValue: branchAttributionLevel))
        }
        
        if enableLogging {
            let branchLogLevel = mapLogLevel(logLevel)
            // Enable Branch logging with callback through LogStreamHandler
            if let handler = logStreamHandler {
                handler.enableBranchLogging(at: branchLogLevel)
            }
            LogUtils.debug(message: "Enabled logging with level: \(logLevel)")
        }
        
        for (key, value) in requestMetadata {
            Branch.getInstance().setRequestMetadataKey(key, value: value)
        }
        for (key, value) in snapParameters {
            Branch.getInstance().addSnapPartnerParameter(withName: key, value: value)
        }
        for (key, value) in facebookParameters {
            Branch.getInstance().addFacebookPartnerParameter(withName: key, value: value)
        }
        
        isInitialized = true
        result(true)
    }
    
    private func getShortUrl(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let buoDict = args["buo"] as? [String: Any?],
              let lpDict = args["lp"] as? [String: Any?]
        else {
            result(flutterError(message: "Invalid arguments provided for getShortUrl", details: call.arguments))
            return
        }
        
        guard let buo = convertToBUO(dict: buoDict), let lp = convertToLp(dict: lpDict) else {
            result(flutterError(message: "Failed to create Branch Universal Object or Link Properties.", details: call.arguments))
            return
        }
        
        var response: [String: Any] = [:]
        buo.getShortUrl(with: lp) { (url, error) in
            if let urlString = url, error == nil {
                NSLog("getShortUrl: %@", urlString)
                response["success"] = true
                response["url"] = urlString
            } else {
                response["success"] = false
                if let err = error as NSError? {
                    response["errorCode"] = String(err.code)
                    response["errorMessage"] = err.localizedDescription
                } else {
                    response["errorCode"] = ""
                    response["errorMessage"] = "Error message not returned by Branch SDK. See log for details."
                }
            }
            DispatchQueue.main.async {
                result(response)
            }
        }
    }
    
    private func showShareSheet(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let buoDict = args["buo"] as? [String: Any?],
              let lpDict = args["lp"] as? [String: Any?],
              let shareText = args["messageText"] as? String
        else {
            result(flutterError(message: "Invalid arguments provided for showShareSheet", details: call.arguments))
            return
        }
        
        guard let controller = getRootViewController() else {
            result(flutterError(message: "Could not find root view controller to present share sheet"))
            return
        }
        
        guard let buo = convertToBUO(dict: buoDict), let lp = convertToLp(dict: lpDict) else {
            result(flutterError(message: "Failed to create Branch Universal Object or Link Properties.", details: call.arguments))
            return
        }
        
        var response: [String: Any] = [:]
        buo.showShareSheet(with: lp, andShareText: shareText, from: controller) { (activityType, completed, error) in
            if completed {
                response["success"] = true
            } else {
                response["success"] = false
                if let err = error as NSError? {
                    response["errorCode"] = String(err.code)
                    response["errorMessage"] = err.localizedDescription
                } else {
                    response["errorCode"] = "-1"
                    response["errorMessage"] = "Share sheet cancelled by user or unknown error"
                }
            }
            DispatchQueue.main.async {
                result(response)
            }
        }
    }
    
    private func validateSDKIntegration() {
        DispatchQueue.main.async {
            Branch.getInstance().validateSDKIntegration()
        }
    }
    
    private func trackContent(call: FlutterMethodCall) {
        guard let args = call.arguments as? [String: Any],
              let buoDictArray = args["buo"] as? [[String: Any?]],
              let eventDict = args["event"] as? [String: Any?]
        else {
            LogUtils.debug(message: "Invalid arguments provided for trackContent")
            return
        }
        
        let buoList = buoDictArray.compactMap { convertToBUO(dict: $0) }
        guard let event = convertToEvent(dict: eventDict) else {
            LogUtils.debug(message: "Failed to create BranchEvent from event dictionary")
            return
        }
        
        event.contentItems = buoList
        
        DispatchQueue.main.async {
            event.logEvent()
        }
    }
    
    private func trackContentWithoutBuo(call: FlutterMethodCall) {
        guard let args = call.arguments as? [String: Any],
              let eventDict = args["event"] as? [String: Any?]
        else {
            LogUtils.debug(message: "Invalid arguments provided for trackContentWithoutBuo")
            return
        }
        
        guard let event = convertToEvent(dict: eventDict) else {
            LogUtils.debug(message: "Failed to create BranchEvent from event dictionary")
            return
        }
        
        DispatchQueue.main.async {
            event.logEvent()
        }
    }
    
    private func registerView(call: FlutterMethodCall) {
        guard let args = call.arguments as? [String: Any],
              let buoDict = args["buo"] as? [String: Any?]
        else {
            LogUtils.debug(message: "Invalid arguments provided for registerView")
            return
        }
        
        guard let buo = convertToBUO(dict: buoDict) else {
            LogUtils.debug(message: "ailed to create BranchUniversalObject from dictionary")
            return
        }
        
        DispatchQueue.main.async {
            buo.registerView()
        }
    }
    
    private func listOnSearch(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let buoDict = args["buo"] as? [String: Any?]
        else {
            result(flutterError(message: "Invalid arguments provided for listOnSearch", details: call.arguments))
            return
        }
        
        guard let buo = convertToBUO(dict: buoDict) else {
            result(flutterError(message: "Failed to create BranchUniversalObject from dictionary", details: buoDict))
            return
        }
        
        if let lpDict = args["lp"] as? [String: Any?], let lp = convertToLp(dict: lpDict) {
            buo.listOnSpotlight(with: lp) { (url, error) in
                DispatchQueue.main.async {
                    if (error != nil) {
                        LogUtils.debug(message: "Failed indexed on spotlight \(error)")
                    }
                    result(error == nil)
                }
            }
        } else {
            buo.listOnSpotlight() { (url, error) in
                DispatchQueue.main.async {
                    if (error != nil) {
                        LogUtils.debug(message: "Failed indexed on spotlight \(error)")
                    }
                    result(error == nil)
                }
            }
        }

    }
    
    private func removeFromSearch(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let buoDict = args["buo"] as? [String: Any?]
        else {
            result(flutterError(message: "Invalid arguments provided for removeFromSearch", details: call.arguments))
            return
        }
        
        guard let buo = convertToBUO(dict: buoDict) else {
            result(flutterError(message: "Failed to create BranchUniversalObject from dictionary", details: buoDict))
            return
        }
        
        buo.removeFromSpotlight { (error) in
            DispatchQueue.main.async {
                if (error != nil) {
                    LogUtils.debug(message: "Failed remove on spotligh \(error)")
                }
                result(error == nil)
            }
        }
    }
    
    private func setIdentity(call: FlutterMethodCall) {
        guard let args = call.arguments as? [String: Any],
              let userId = args["userId"] as? String else {
            LogUtils.debug(message: "Invalid arguments provided for setIdentity")
            return
        }
        
        DispatchQueue.main.async {
            Branch.getInstance().setIdentity(userId)
        }
    }
    
    private func setRequestMetadata(call: FlutterMethodCall) {
        guard let args = call.arguments as? [String: Any],
              let key = args["key"] as? String,
              let value = args["value"] as? String else {
            LogUtils.debug(message: "Invalid arguments provided for setRequestMetadata")
            return
        }
        
        if requestMetadata.keys.contains(key) && value.isEmpty {
            requestMetadata.removeValue(forKey: key)
        } else {
            requestMetadata[key] = value
        }
        
        DispatchQueue.main.async {
            Branch.getInstance().setRequestMetadataKey(key, value: value)
        }
    }
    
    private func logout() {
        DispatchQueue.main.async {
            Branch.getInstance().logout()
        }
    }
    
    private func getLatestReferringParams(result: @escaping FlutterResult) {
        let latestParams = Branch.getInstance().getLatestReferringParams()
        DispatchQueue.main.async {
            result(latestParams)
        }
    }
    
    private func getFirstReferringParams(result: @escaping FlutterResult) {
        let firstParams = Branch.getInstance().getFirstReferringParams()
        DispatchQueue.main.async {
            result(firstParams)
        }
    }
    
    private func setTrackingDisabled(call: FlutterMethodCall) {
        guard let args = call.arguments as? [String: Any],
              let value = args["disable"] as? Bool else {
            LogUtils.debug(message: "Invalid arguments provided for setTrackingDisabled")
            return
        }
        
        DispatchQueue.main.async {
            Branch.setTrackingDisabled(value)
        }
    }
    
    private func getLastAttributedTouchData(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any] else {
            result(flutterError(message: "Invalid arguments provided for getLastAttributedTouchData", details: call.arguments))
            return
        }
        
        var response: [String: Any] = [:]
        let attributionWindow = args["attributionWindow"] as? Int ?? 0
        
        Branch.getInstance().lastAttributedTouchData(withAttributionWindow: attributionWindow) { latd, error in
            if error == nil {
                var data: [String: Any] = [:]
                if let attributedData = latd {
                    data["latd"] = ["attibution_window": attributedData.attributionWindow,
                                    "last_atributed_touch_data": attributedData.lastAttributedTouchJSON]
                } else {
                    data["latd"] = [:]
                }
                response["success"] = true
                response["data"] = data
            } else {
                LogUtils.debug(message: "Failed to get lastAttributedTouchData: \(String(describing: error))")
                response["success"] = false
                if let err = error as NSError? {
                    response["errorCode"] = String(err.code)
                    response["errorMessage"] = err.localizedDescription
                } else {
                    response["errorCode"] = ""
                    response["errorMessage"] = "Error message not returned by Branch SDK. See log for details."
                }
            }
            DispatchQueue.main.async {
                result(response)
            }
        }
    }
    
    private func isUserIdentified(result: @escaping FlutterResult) {
        DispatchQueue.main.async {
            result(Branch.getInstance().isUserIdentified())
        }
    }
    
    private func setTimeout(call: FlutterMethodCall) {
        // The Branch iOS SDK no longer directly exposes a method for `setTimeout`.
        LogUtils.debug(message: "setTimeout called, but not applicable for iOS SDK version.")
    }
    
    private func setConnectTimeout(call: FlutterMethodCall) {
        guard let args = call.arguments as? [String: Any],
              let connectTimeout = args["connectTimeout"] as? Int else {
            LogUtils.debug(message: "Invalid arguments provided for setConnectTimeout")
            return
        }
        DispatchQueue.main.async {
            Branch.getInstance().setNetworkTimeout(TimeInterval(connectTimeout))
        }
    }
    
    private func setRetryCount(call: FlutterMethodCall) {
        // The Branch iOS SDK no longer directly exposes a method for `setRetryCount`.
        LogUtils.debug(message: "setRetryCount called, but not applicable for iOS SDK version.")
    }
    
    private func setRetryInterval(call: FlutterMethodCall) {
        guard let args = call.arguments as? [String: Any],
              let retryInterval = args["retryInterval"] as? Int else {
            LogUtils.debug(message: "Invalid arguments provided for setRetryInterval")
            return
        }
        DispatchQueue.main.async {
            Branch.getInstance().setRetryInterval(TimeInterval(retryInterval))
        }
    }
    
    private func getQRCode(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let buoDict = args["buo"] as? [String: Any?],
              let lpDict = args["lp"] as? [String: Any?],
              let qrCodeDict = args["qrCodeSettings"] as? [String: Any?]
        else {
            result(flutterError(message: "Invalid arguments provided for getQRCode", details: call.arguments))
            return
        }
        
        // First, safely unwrap the optionals.
        guard let buo = convertToBUO(dict: buoDict),
              let lp = convertToLp(dict: lpDict) else {
            result(flutterError(message: "Failed to create Branch Universal Object or Link Properties.", details: call.arguments))
            return
        }
        

        let qrCode = convertToQRCode(dict: qrCodeDict)
        
        var response: [String: Any] = [:]
        
        qrCode.getAsData(buo, linkProperties: lp, completion: { data, error in
            if let imageData = data, error == nil {
                response["success"] = true
                response["result"] = FlutterStandardTypedData(bytes: imageData)
            } else {
                response["success"] = false
                if let err = error as NSError? {
                    response["errorCode"] = String(err.code)
                    response["errorMessage"] = err.localizedDescription
                } else {
                    response["errorCode"] = ""
                    response["errorMessage"] = "Error message not returned by Branch SDK. See log for details."
                }
            }
            DispatchQueue.main.async {
                result(response)
            }
        })
    }
    
    private func shareWithLPLinkMetadata(call: FlutterMethodCall, result: @escaping FlutterResult) {
        
        guard let args = call.arguments as? [String: Any],
              let buoDict = args["buo"] as? [String: Any?],
              let lpDict = args["lp"] as? [String: Any?],
              let messageText = args["messageText"] as? String
        else {
            result(flutterError(message: "Invalid arguments provided for shareWithLPLinkMetadata", details: call.arguments))
            return
        }
        
        guard let buo = convertToBUO(dict: buoDict),
              let lp = convertToLp(dict: lpDict) else {
            result(flutterError(message: "Failed to create BranchUniversalObject or BranchLinkProperties", details: call.arguments))
            return
        }
        
        var iconImage: UIImage?
        if let iconData = args["iconData"] as? FlutterStandardTypedData {
            iconImage = UIImage(data: iconData.data)
        } else {
            iconImage = Bundle.main.icon
        }
        
        let bsl = BranchShareLink(universalObject: buo, linkProperties: lp)
        if #available(iOS 13.0, *) {
            bsl.addLPLinkMetadata(messageText, icon: iconImage)
            guard let controller = getRootViewController() else {
                result(flutterError(message: "Could not find root view controller to present share sheet for LPLinkMetadata"))
                return
            }
            bsl.presentActivityViewController(from: controller, anchor: nil)
            result(true)
        } else {
            showShareSheet(call: call, result: result)
        }
    }
    
    private func handleDeepLink(call: FlutterMethodCall) {
        guard let args = call.arguments as? [String: Any],
              let urlString = args["url"] as? String,
              let url = URL(string: urlString) else {
            LogUtils.debug(message: "Invalid arguments provided for handleDeepLink (URL missing or invalid)")
            return
        }
        Branch.getInstance().handleDeepLink(withNewSession: url)
    }
    
    private func addFacebookPartnerParameter(call: FlutterMethodCall) {
        guard let args = call.arguments as? [String: Any],
              let key = args["key"] as? String,
              let value = args["value"] as? String else {
            LogUtils.debug(message: "Invalid arguments provided for addFacebookPartnerParameter")
            return
        }
        
        if facebookParameters.keys.contains(key) && value.isEmpty {
            facebookParameters.removeValue(forKey: key)
        } else {
            facebookParameters[key] = value
        }
        
        DispatchQueue.main.async {
            Branch.getInstance().addFacebookPartnerParameter(withName: key, value: value)
        }
    }
    
    private func addSnapPartnerParameter(call: FlutterMethodCall) {
        guard let args = call.arguments as? [String: Any],
              let key = args["key"] as? String,
              let value = args["value"] as? String else {
            LogUtils.debug(message: "Invalid arguments provided for addSnapPartnerParameter")
            return
        }
        
        if snapParameters.keys.contains(key) && value.isEmpty {
            snapParameters.removeValue(forKey: key)
        } else {
            snapParameters[key] = value
        }
        
        DispatchQueue.main.async {
            Branch.getInstance().addSnapPartnerParameter(withName: key, value: value)
        }
    }
    
    private func setPreinstallCampaign(call: FlutterMethodCall) {
        // This function is primarily relevant for Android.
        LogUtils.debug(message: "setPreinstallCampaign called, but not directly applicable for iOS SDK version.")
    }
    
    private func setPreinstallPartner(call: FlutterMethodCall) {
        // This function is primarily relevant for Android.
        LogUtils.debug(message: "setPreinstallPartner called, but not directly applicable for iOS SDK version.")
    }
    
    private func setDMAParamsForEEA(call: FlutterMethodCall) {
        guard let args = call.arguments as? [String: Any],
              let eeaRegion = args["eeaRegion"] as? Bool,
              let adPersonalizationConsent = args["adPersonalizationConsent"] as? Bool,
              let adUserDataUsageConsent = args["adUserDataUsageConsent"] as? Bool
        else {
            LogUtils.debug(message: "Invalid arguments provided for setDMAParamsForEEA")
            return
        }
        
        DispatchQueue.main.async {
            Branch.setDMAParamsForEEA(eeaRegion, adPersonalizationConsent: adPersonalizationConsent, adUserDataUsageConsent: adUserDataUsageConsent)
        }
    }
    
    private func setConsumerProtectionAttributionLevel(call: FlutterMethodCall) {
        guard let args = call.arguments as? [String: Any],
              let branchAttributionLevelString = args["branchAttributionLevel"] as? String
        else {
            LogUtils.debug(message: "Invalid arguments provided for setConsumerProtectionAttributionLevel")
            return
        }
        
        let branchAttributionLevel = BranchAttributionLevel(rawValue: branchAttributionLevelString)
        
        DispatchQueue.main.async {
            Branch.getInstance().setConsumerProtectionAttributionLevel(branchAttributionLevel)
        }
    }
    
    
    /*
     https://developer.apple.com/documentation/apptrackingtransparency/attrackingmanager
     
     ATTrackingManager.AuthorizationStatus:
     - authorized = 3
     - denied = 2
     - notDetermined = 0
     - restricted = 1
     */
    
    private func requestTrackingAuthorization(result: @escaping FlutterResult) {
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { (status) in
                Branch.getInstance().handleATTAuthorizationStatus(status.rawValue)
                
                DispatchQueue.main.async {
                    result(Int(status.rawValue))
                }
            }
        } else {
            DispatchQueue.main.async {
                result(Int(4)) // Return custom 'notSupported' code for iOS < 14
            }
        }
    }
    
    private func getTrackingAuthorizationStatus(result: @escaping FlutterResult) {
        if #available(iOS 14, *) {
            DispatchQueue.main.async {
                result(Int(ATTrackingManager.trackingAuthorizationStatus.rawValue))
            }
        } else {
            DispatchQueue.main.async {
                result(Int(4))  // Return custom 'notSupported' code for iOS < 14
            }
        }
    }
    
    private func getAdvertisingIdentifier(result: @escaping FlutterResult) {
        if #available(iOS 14, *) {
            let status = ATTrackingManager.trackingAuthorizationStatus
            if status == .authorized {
                result(String(ASIdentifierManager.shared().advertisingIdentifier.uuidString))
            } else {
                result(String(""))  // return notSupported
            }
        } else {
            DispatchQueue.main.async {
                result(String(""))  // return notSupported
            }
        }
    }
    
    /*
     Sets a custom Meta Anon ID for the current user.
     @param anonID The custom Meta Anon ID to be used by Branch.
     */
    private func setAnonID (call: FlutterMethodCall) {
        guard let args = call.arguments as? [String: Any],
              let anonId = args["anonId"] as? String else {
            LogUtils.debug(message: "Invalid arguments provided for setAnonID")
            return
        }
        LogUtils.debug(message: "setAnonID: \(anonId)")
        DispatchQueue.main.async {
            Branch.setAnonID(anonId)
        }
    }
    /*
     Set the SDK wait time for third party APIs (for fetching ODM info and Apple Attribution Token) to finish
     This timeout should be > 0 and <= 10 seconds.
     @param waitTime Number of seconds before third party API calls are considered timed out. Default is 0.5 seconds (500ms).
     */
    private func setSDKWaitTimeForThirdPartyAPIs (call: FlutterMethodCall) {
        guard let args = call.arguments as? [String: Any],
              let waitTime = args["waitTime"] as? Double else {
            LogUtils.debug(message: "Invalid arguments provided for setSDKWaitTimeForThirdPartyAPIs")
            return
        }
        LogUtils.debug(message: "setSDKWaitTimeForThirdPartyAPIs: \(String(describing: waitTime))")
        DispatchQueue.main.async {
            Branch.setSDKWaitTimeForThirdPartyAPIs(waitTime)
        }
    }
    
    // MARK: - Helper Methods
    
    /**
     Maps Flutter log level string to Branch iOS SDK log level
     */
    private func mapLogLevel(_ logLevel: String) -> BranchLogLevel {
        switch logLevel {
        case "VERBOSE":
            return BranchLogLevel.verbose
        case "DEBUG":
            return BranchLogLevel.debug
        case "WARNING":
            return BranchLogLevel.warning
        case "ERROR":
            return BranchLogLevel.error
        default:
            LogUtils.debug(message: "Unknown log level: \(logLevel), defaulting to verbose")
            return BranchLogLevel.verbose
        }
    }

}
