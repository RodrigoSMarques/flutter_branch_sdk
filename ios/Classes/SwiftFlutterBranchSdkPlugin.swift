import Flutter
import UIKit
import BranchSDK
import AppTrackingTransparency
import AdSupport

var methodChannel: FlutterMethodChannel?
var eventChannel: FlutterEventChannel?
let MESSAGE_CHANNEL = "flutter_branch_sdk/message";
let EVENT_CHANNEL = "flutter_branch_sdk/event";
let ERROR_CODE = "FLUTTER_BRANCH_SDK_ERROR";
let PLUGIN_NAME = "Flutter";
let COCOA_POD_NAME = "org.cocoapods.flutter-branch-sdk";

public class SwiftFlutterBranchSdkPlugin: NSObject, FlutterPlugin, FlutterStreamHandler  {
    var eventSink: FlutterEventSink?
    var initialParams : [String: Any]? = nil
    var initialError : NSError? = nil

    var branch : Branch?
    var isInitialized = false

    var requestMetadata : [String: String] = [:]
    var facebookParameters : [String: String] = [:]
    var snapParameters : [String: String] = [:]
    
    //---------------------------------------------------------------------------------------------
    // Plugin registry
    // --------------------------------------------------------------------------------------------
    public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = SwiftFlutterBranchSdkPlugin()
        
        methodChannel = FlutterMethodChannel(name: MESSAGE_CHANNEL, binaryMessenger: registrar.messenger())
        eventChannel = FlutterEventChannel(name: EVENT_CHANNEL, binaryMessenger: registrar.messenger())
        eventChannel!.setStreamHandler(instance)
        
        registrar.addApplicationDelegate(instance)
        registrar.addMethodCallDelegate(instance, channel: methodChannel!)
    }
    
    func getPluginVersion() -> String {
        var pluginVersion : String = ""
        if let version = Bundle(identifier: COCOA_POD_NAME)?.infoDictionary?["CFBundleShortVersionString"] as? String {
            pluginVersion = version;
        }
        return pluginVersion
    }
    
    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [AnyHashable : Any] = [:]) -> Bool {
        Branch.getInstance().registerPluginName(PLUGIN_NAME, version:  getPluginVersion())

        if #available(iOS 15.0, *) {
            Branch.getInstance().checkPasteboardOnInstall()
        }

        Branch.getInstance().initSession(launchOptions: launchOptions) { (params, error) in
            if error == nil {
                print("Branch InitSession params: \(String(describing: params as? [String: Any]))")
                guard let _ = self.eventSink else {
                    self.initialParams = params as? [String: Any]
                    return
                }
                self.eventSink!(params as? [String: Any])
            } else {
                let err = (error! as NSError)
                print("Branch InitSession error: \(err.localizedDescription)")
                guard let _ = self.eventSink else {
                    self.initialError = err
                    return
                }
                self.eventSink!(FlutterError(code: String(err.code),
                                             message: err.localizedDescription,
                                             details: nil))
            }
        }
        return true
    }
    
    public func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        let branchHandled = Branch.getInstance().application(app, open: url, options: options)
        return branchHandled
    }
    
    public func application(_ app: UIApplication, open url: URL, sourceApplication: String, annotation: Any) -> Bool {
        let branchHandled = Branch.getInstance().application(app, open: url, sourceApplication: sourceApplication, annotation: annotation)
        return branchHandled
    }
    
    public func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]) -> Void) -> Bool {
        let handledByBranch = Branch.getInstance().continue(userActivity)
        return handledByBranch
    }
    
    public func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        Branch.getInstance().handlePushNotification(userInfo)
    }
    
    //---------------------------------------------------------------------------------------------
    // FlutterStreamHandler Interface Methods
    // --------------------------------------------------------------------------------------------
    public func onListen(withArguments arguments: Any?,
                         eventSink: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = eventSink
        if (initialParams != nil) {
            self.eventSink!(self.initialParams)
            initialParams = nil
            initialError = nil
        } else if (initialError != nil) {
            self.eventSink!(FlutterError(code: String(self.initialError!.code),
                                         message: self.initialError!.localizedDescription,
                                         details: nil))
            initialParams = nil
            initialError = nil
        }
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
        default:
            result(FlutterMethodNotImplemented)
            break
        }
    }
    
    //---------------------------------------------------------------------------------------------
    // Branch SDK Call Methods
    // --------------------------------------------------------------------------------------------
    private func setupBranch(call: FlutterMethodCall, result: @escaping FlutterResult) {
        
        if (isInitialized) {
            result(true)
        }
        let args = call.arguments as! [String: Any?]
        
#if DEBUG
        NSLog("setupBranch args: %@", args)
#endif
        
        if args["disableTracking"] as! Bool == true {
            Branch.setTrackingDisabled(true)
        } else {
            Branch.setTrackingDisabled(false)
        }
        
       
        if args["enableLogging"] as! Bool == true {
            Branch.enableLogging(at: BranchLogLevel.debug)
        }
        
        if (!requestMetadata.isEmpty) {
            for param in requestMetadata {
                Branch.getInstance().setRequestMetadataKey(param.key, value: param.value)
            }
        }
        if (!snapParameters.isEmpty) {
            for param in snapParameters {
                Branch.getInstance().addSnapPartnerParameter(withName: param.key, value: param.value)
            }
        }
        if (!facebookParameters.isEmpty) {
            for param in facebookParameters {
                Branch.getInstance().addFacebookPartnerParameter(withName: param.key, value: param.value)
            }
        }
        isInitialized = true
        result(true)
    }
    
    private func getShortUrl(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args = call.arguments as! [String: Any?]
        let buoDict = args["buo"] as! [String: Any?]
        let lpDict = args["lp"] as! [String: Any?]
        let buo: BranchUniversalObject? = convertToBUO(dict: buoDict)
        let lp : BranchLinkProperties? = convertToLp(dict: lpDict )
        
        let response : NSMutableDictionary! = [:]
        buo?.getShortUrl(with: lp!) { (url, error) in
            if ((error == nil && url != nil) || (error != nil && url != nil)) {
                NSLog("getShortUrl: %@", url!)
                response["success"] = NSNumber(value: true)
                response["url"] = url!
            } else {
                response["success"] = NSNumber(value: false)
                if let err = (error as NSError?) {
                    response["errorCode"] = String(err.code)
                    response["errorMessage"] = err.localizedDescription
                }
            }
            DispatchQueue.main.async {
                result(response)
            }
        }
    }
    
    private func showShareSheet(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args = call.arguments as! [String: Any?]
        let buoDict = args["buo"] as! [String: Any?]
        let lpDict = args["lp"] as! [String: Any?]
        let shareText = args["messageText"] as! String
        let buo: BranchUniversalObject? = convertToBUO(dict: buoDict)
        let lp : BranchLinkProperties? = convertToLp(dict: lpDict )
        let controller = UIApplication.shared.keyWindow!.rootViewController
        
        let response : NSMutableDictionary! = [:]
        buo?.showShareSheet(with: lp, andShareText: shareText, from: controller) { (activityType, completed, error) in
            if completed {
                response["success"] = NSNumber(value: true)
            } else {
                response["success"] = NSNumber(value: false)
                if let err = (error as NSError?) {
                    response["errorCode"] = String(err.code)
                    response["errorMessage"] = err.localizedDescription
                } else {
                    response["errorCode"] = "-1"
                    response["errorMessage"] = "Canceled by user"
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
        let args = call.arguments as! [String: Any?]
        let buoDict = args["buo"] as! [[String: Any?]]
        let eventDict = args["event"] as! [String: Any?]
        let buoList: [BranchUniversalObject] = buoDict.map { b in
            convertToBUO(dict: b)!
        }
        let event: BranchEvent? = convertToEvent(dict : eventDict)
        event!.contentItems =  buoList
        
        DispatchQueue.main.async {
            event!.logEvent()
        }
    }
    
    private func trackContentWithoutBuo(call: FlutterMethodCall) {
        let args = call.arguments as! [String: Any?]
        let eventDict = args["event"] as! [String: Any?]
        let event: BranchEvent? = convertToEvent(dict : eventDict)
        
        DispatchQueue.main.async {
            event!.logEvent()
        }
    }
    
    private func registerView(call: FlutterMethodCall) {
        let args = call.arguments as! [String: Any?]
        let buoDict = args["buo"] as! [String: Any?]
        let buo: BranchUniversalObject? = convertToBUO(dict: buoDict)
        
        DispatchQueue.main.async {
            buo!.registerView()
        }
    }
    
    private func listOnSearch(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args = call.arguments as! [String: Any?]
        let buoDict = args["buo"] as! [String: Any?]
        let buo: BranchUniversalObject? = convertToBUO(dict: buoDict)
        var response = NSNumber(value: true)
        if let lpDict = args["lp"] as? [String: Any?] {
            let lp : BranchLinkProperties! = convertToLp(dict: lpDict)
            buo!.listOnSpotlight(with: lp) { (url, error) in
                if (error == nil) {
                    print("Successfully indexed on spotlight")
                    response = NSNumber(value: true)
                } else {
                    print("Failed indexed on spotlight")
                    response = NSNumber(value: false)
                }
                DispatchQueue.main.async {
                    result(response)
                }
            }
        } else {
            buo!.listOnSpotlight() { (url, error) in
                if (error == nil) {
                    print("Successfully indexed on spotlight")
                    response = NSNumber(value: true)
                } else {
                    print("Failed indexed on spotlight")
                    response = NSNumber(value: false)
                }
                DispatchQueue.main.async {
                    result(response)
                }
            }
        }
    }
    
    private func removeFromSearch(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args = call.arguments as! [String: Any?]
        let buoDict = args["buo"] as! [String: Any?]
        let buo: BranchUniversalObject? = convertToBUO(dict: buoDict)
        var response = NSNumber(value: true)
        buo!.removeFromSpotlight { (error) in
            if (error == nil) {
                print("BUO successfully removed from spotlight")
                response = NSNumber(value: true)
            } else {
                response = NSNumber(value: false)
            }
            DispatchQueue.main.async {
                result(response)
            }
        }
    }
    
    private func setIdentity(call: FlutterMethodCall) {
        let args = call.arguments as! [String: Any?]
        let userId = args["userId"] as! String
        
        DispatchQueue.main.async {
            Branch.getInstance().setIdentity(userId)
        }
    }
    
    private func setRequestMetadata(call: FlutterMethodCall) {
        let args = call.arguments as! [String: Any?]
        let key = args["key"] as! String
        let value = args["value"] as! String
        
        
        if (requestMetadata.keys.contains(key) && value.isEmpty) {
            requestMetadata.removeValue(forKey: key)
        } else {
            requestMetadata[key] = value;
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
        let args = call.arguments as! [String: Any?]
        let value = args["disable"] as! Bool
        
        DispatchQueue.main.async {
            Branch.setTrackingDisabled(value)
        }
    }
    
    private func getLastAttributedTouchData(call: FlutterMethodCall, result: @escaping FlutterResult) {
        
        let args = call.arguments as! [String: Any?]
        let response : NSMutableDictionary! = [:]
        let data : NSMutableDictionary! = [:]
        let attributionWindow = args["attributionWindow"] as? Int ?? 0
        
        Branch.getInstance().lastAttributedTouchData(withAttributionWindow: attributionWindow) { latd, error in
            if error == nil {
                if latd != nil {
                    data["latd"] = ["attibution_window": latd!.attributionWindow,
                                    "last_atributed_touch_data" : latd!.lastAttributedTouchJSON]
                } else {
                    data["latd"] = [:]
                }
                response["success"] = NSNumber(value: true)
                response["data"] = data
            } else {
                print("Failed to lastAttributedTouchData: \(String(describing: error))")
                let err = (error! as NSError)
                response["success"] = NSNumber(value: false)
                response["errorCode"] = String(err.code)
                response["errorMessage"] = err.localizedDescription
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
        let args = call.arguments as! [String: Any?]
        let _  = args["timeout"] as? Int ?? 0
    }
    
    private func setConnectTimeout(call: FlutterMethodCall) {
        let args = call.arguments as! [String: Any?]
        let connectTimeout = args["connectTimeout"] as? Int ?? 0
        DispatchQueue.main.async {
            Branch.getInstance().setNetworkTimeout(TimeInterval(connectTimeout))
        }
    }
    
    private func setRetryCount(call: FlutterMethodCall) {
        let args = call.arguments as! [String: Any?]
        let _ = args["retryCount"] as? Int ?? 0
    }
    
    private func setRetryInterval(call: FlutterMethodCall) {
        let args = call.arguments as! [String: Any?]
        let retryInterval = args["retryInterval"] as? Int ?? 0
        DispatchQueue.main.async {
            Branch.getInstance().setRetryInterval(TimeInterval(retryInterval))
        }
    }
    
    private func getQRCode(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args = call.arguments as! [String: Any?]
        let buoDict = args["buo"] as! [String: Any?]
        let lpDict = args["lp"] as! [String: Any?]
        let qrCodeDict = args["qrCodeSettings"] as! [String: Any?]
        
        let buo: BranchUniversalObject? = convertToBUO(dict: buoDict)
        let lp : BranchLinkProperties? = convertToLp(dict: lpDict )
        let qrCode : BranchQRCode? = convertToQRCode(dict: qrCodeDict)
        
        let response : NSMutableDictionary! = [:]
        
        qrCode?.getAsData(buo, linkProperties: lp, completion: { data, error in
            if (error == nil) {
                response["success"] = NSNumber(value: true)
                response["result"] = FlutterStandardTypedData(bytes: data!)
            } else {
                response["success"] = NSNumber(value: false)
                if let err = (error as NSError?) {
                    response["errorCode"] = String(err.code)
                    response["errorMessage"] = err.localizedDescription
                }
            }
            DispatchQueue.main.async {
                result(response)
            }
            
        })
    }
    
    private func shareWithLPLinkMetadata(call: FlutterMethodCall, result: @escaping FlutterResult) {
        
        let args = call.arguments as! [String: Any?]
        let buoDict = args["buo"] as! [String: Any?]
        let lpDict = args["lp"] as! [String: Any?]
        let messageText = args["messageText"] as! String
        let buo: BranchUniversalObject? = convertToBUO(dict: buoDict)
        let lp : BranchLinkProperties? = convertToLp(dict: lpDict )
        var iconImage : UIImage?
        
        if let iconData = args["iconData"] as? FlutterStandardTypedData {
            iconImage = UIImage(data: iconData.data)
        } else {
            iconImage = Bundle.main.icon
        }
        
        let bsl = BranchShareLink(universalObject: buo!, linkProperties: lp!)
        if #available(iOS 13.0, *) {
            bsl.addLPLinkMetadata(messageText, icon: iconImage)
            let controller = UIApplication.shared.keyWindow!.rootViewController
            bsl.presentActivityViewController(from: controller, anchor: nil)
        } else {
            showShareSheet(call: call, result: result)
        }
    }
    
    private func handleDeepLink(call: FlutterMethodCall) {
        let args = call.arguments as! [String: Any?]
        let url = args["url"] as! String
        Branch.getInstance().handleDeepLink(withNewSession: URL(string: url))
    }
    
    private func addFacebookPartnerParameter(call: FlutterMethodCall) {
        let args = call.arguments as! [String: Any?]
        let key = args["key"] as! String
        let value = args["value"] as! String
        
        if (facebookParameters.keys.contains(key) && value.isEmpty) {
            facebookParameters.removeValue(forKey: key)
        } else {
            facebookParameters[key] = value;
        }
        
        DispatchQueue.main.async {
            Branch.getInstance().addFacebookPartnerParameter(withName: key, value:value)
        }
    }
    
    private func addSnapPartnerParameter(call: FlutterMethodCall) {
        let args = call.arguments as! [String: Any?]
        let key = args["key"] as! String
        let value = args["value"] as! String
        
        if (snapParameters.keys.contains(key) && value.isEmpty) {
            snapParameters.removeValue(forKey: key)
        } else {
            snapParameters[key] = value;
        }
        
        DispatchQueue.main.async {
            Branch.getInstance().addSnapPartnerParameter(withName: key, value:value)
        }
    }
    
    private func setPreinstallCampaign(call: FlutterMethodCall) {
    }
    
    private func setPreinstallPartner(call: FlutterMethodCall) {
    }
    
    private func setDMAParamsForEEA(call: FlutterMethodCall) {
        let args = call.arguments as! [String: Any?]
        let eeaRegion = args["eeaRegion"] as! Bool
        let adPersonalizationConsent = args["adPersonalizationConsent"]  as! Bool
        let adUserDataUsageConsent = args["adUserDataUsageConsent"] as! Bool
        
        DispatchQueue.main.async {
            Branch.setDMAParamsForEEA(eeaRegion,adPersonalizationConsent: adPersonalizationConsent, adUserDataUsageConsent: adUserDataUsageConsent)
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
                result(Int(4)) // return notSupported
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
                result(Int(4))  // return notSupported
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
}
