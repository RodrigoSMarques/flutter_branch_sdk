import Flutter
import UIKit
import Branch
import AppTrackingTransparency
import AdSupport

var methodChannel: FlutterMethodChannel?
var eventChannel: FlutterEventChannel?
let MESSAGE_CHANNEL = "flutter_branch_sdk/message";
let EVENT_CHANNEL = "flutter_branch_sdk/event";
let ERROR_CODE = "FLUTTER_BRANCH_SDK_ERROR";
let PLUGIN_NAME = "Flutter";
let PLUGIN_VERSION = "6.0.0"

public class SwiftFlutterBranchSdkPlugin: NSObject, FlutterPlugin, FlutterStreamHandler  {
    var eventSink: FlutterEventSink?
    var initialParams : [String: Any]? = nil
    var initialError : NSError? = nil
    
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
    
    
    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [AnyHashable : Any] = [:]) -> Bool {
        
        
        Branch.getInstance().registerPluginName(PLUGIN_NAME, version: PLUGIN_VERSION);
        
#if DEBUG
        let enableLog = Bundle.infoPlistValue(forKey: "branch_enable_log") as? Bool ?? true
        if enableLog {
            Branch.getInstance().enableLogging()
        }
#else
        let enableLog = Bundle.infoPlistValue(forKey: "branch_enable_log") as? Bool ?? false
        if enableLog {
            Branch.getInstance().enableLogging()
        }
#endif
        
        let enableAppleADS = Bundle.infoPlistValue(forKey: "branch_check_apple_ads") as? Bool ?? false
        
        print("Branch Check Apple ADS active: \(String(describing:enableAppleADS))");
        
        if enableAppleADS {
            // This will usually add less than 1 second on first time startup.  Up to 3.5 seconds if Apple Search Ads fails to respond.
            Branch.getInstance().delayInitToCheckForSearchAds()
        }
        
        let enableFacebookAds = Bundle.infoPlistValue(forKey: "branch_enable_facebook_ads") as? Bool ?? false
        print("Branch Check Facebook Link: \(String(describing:enableFacebookAds))");
        
        if enableFacebookAds {
            //Facebook App Install Ads
            //https://help.branch.io/using-branch/docs/facebook-app-install-ads#configure-your-app-to-read-facebook-app-install-deep-links
            
            let FBSDKAppLinkUtility: AnyClass? = NSClassFromString("FBSDKAppLinkUtility")
            if let FBSDKAppLinkUtility = FBSDKAppLinkUtility {
                Branch.getInstance().registerFacebookDeepLinkingClass(FBSDKAppLinkUtility)
            } else {
                NSLog("FBSDKAppLinkUtility not found but branch_enable_facebook_ads set to true. Please be sure you have integrated the Facebook SDK.")
            }
        }
        
        let checkPasteboard  = Bundle.infoPlistValue(forKey: "branch_check_pasteboard") as? Bool ?? false
        print("Branch Clipboard Deferred Deep Linking: \(String(describing:checkPasteboard))");
        
        if checkPasteboard {
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
            break;
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
        case "setSKAdNetworkMaxTime" :
            setSKAdNetworkMaxTime(call: call)
            break
        case "requestTrackingAuthorization" :
            requestTrackingAuthorization(result: result)
            break
        case "getTrackingAuthorizationStatus" :
            requestTrackingAuthorization(result: result)
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
        case"shareWithLPLinkMetadata":
            shareWithLPLinkMetadata(call: call, result: result)
        default:
            result(FlutterMethodNotImplemented)
            break
        }
    }
    
    //---------------------------------------------------------------------------------------------
    // Branch SDK Call Methods
    // --------------------------------------------------------------------------------------------
    private func getShortUrl(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args = call.arguments as! [String: Any?]
        let buoDict = args["buo"] as! [String: Any?]
        let lpDict = args["lp"] as! [String: Any?]
        let buo: BranchUniversalObject? = convertToBUO(dict: buoDict)
        let lp : BranchLinkProperties? = convertToLp(dict: lpDict )
        
        let response : NSMutableDictionary! = [:]
        buo?.getShortUrl(with: lp!) { (url, error) in
            if (error == nil) {
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
                    data["latd"] = latd
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
    
    private func setSKAdNetworkMaxTime(call: FlutterMethodCall) {
        let args = call.arguments as! [String: Any?]
        let maxTimeInterval = args["maxTimeInterval"] as? Int ?? 0
        DispatchQueue.main.async {
            Branch.getInstance().setSKAdNetworkCalloutMaxTimeSinceInstall(TimeInterval(maxTimeInterval * 3600))
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
