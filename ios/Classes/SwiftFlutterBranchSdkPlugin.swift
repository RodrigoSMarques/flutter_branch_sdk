import Flutter
import UIKit
import Branch

var methodChannel: FlutterMethodChannel?
var eventChannel: FlutterEventChannel?
let MESSAGE_CHANNEL = "flutter_branch_sdk/message";
let EVENT_CHANNEL = "flutter_branch_sdk/event";
let ERROR_CODE = "FLUTTER_BRANCH_SDK_ERROR"

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
        #if DEBUG
        Branch.getInstance().setDebug()
        #endif
        
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
        Branch.getInstance().application(app, open: url, options: options)
        return true
    }
    
    public func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]) -> Void) -> Bool {
        Branch.getInstance().continue(userActivity)
        return true
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
            self.eventSink!(initialParams)
            initialParams = nil
            initialError = nil
        } else if (initialError != nil) {
            self.eventSink!(FlutterError(code: String(initialError!.code),
                                         message: initialError!.localizedDescription,
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
        case "setIdentity":
            setIdentity(call: call)
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
        case "loadRewards":
            loadRewards(call: call, result: result)
            break
        case "redeemRewards":
            redeemRewards(call: call, result: result)
            break
        default:
            result(FlutterMethodNotImplemented)
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
                    response["errorDescription"] = err.localizedDescription
                }
            }
            result(response)
        }
    }
    
    private func showShareSheet(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args = call.arguments as! [String: Any?]
        let buoDict = args["buo"] as! [String: Any?]
        let lpDict = args["lp"] as! [String: Any?]
        let shareText = args["messageText"] as! String
        let buo: BranchUniversalObject? = convertToBUO(dict: buoDict)
        let lp : BranchLinkProperties? = convertToLp(dict: lpDict )
        let controller = UIApplication.shared.keyWindow!.rootViewController as! FlutterViewController
        
        let response : NSMutableDictionary! = [:]
        buo?.showShareSheet(with: lp, andShareText: shareText, from: controller) { (activityType, completed, error) in
            print(activityType ?? "")
            if completed {
                response["success"] = NSNumber(value: true)
            } else {
                response["success"] = NSNumber(value: false)
                if let err = (error as NSError?) {
                    response["errorCode"] = String(err.code)
                    response["errorDescription"] = err.localizedDescription
                }
            }
            result(response)
        }
    }
    
    private func validateSDKIntegration() {
        Branch.getInstance().validateSDKIntegration()
    }
    
    private func trackContent(call: FlutterMethodCall) {
        let args = call.arguments as! [String: Any?]
        let buoDict = args["buo"] as! [String: Any?]
        let eventDict = args["event"] as! [String: Any?]
        let buo: BranchUniversalObject? = convertToBUO(dict: buoDict)
        let event: BranchEvent? = convertToEvent(dict : eventDict)
        event!.contentItems = [ buo! ]
        event!.logEvent()
    }
    
    private func registerView(call: FlutterMethodCall) {
        let args = call.arguments as! [String: Any?]
        let buoDict = args["buo"] as! [String: Any?]
        let buo: BranchUniversalObject? = convertToBUO(dict: buoDict)
        
        buo!.registerView()
    }
    
    private func listOnSearch(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args = call.arguments as! [String: Any?]
        let buoDict = args["buo"] as! [String: Any?]
        let buo: BranchUniversalObject? = convertToBUO(dict: buoDict)
        
        if let lpDict = args["lp"] as? [String: Any?] {
            let lp : BranchLinkProperties! = convertToLp(dict: lpDict)
            buo!.listOnSpotlight(with: lp) { (url, error) in
                if (error == nil) {
                    print("Successfully indexed on spotlight")
                    result(NSNumber(value: true))
                } else {
                    result(NSNumber(value: false))
                }
            }
        } else {
            buo!.listOnSpotlight() { (url, error) in
                if (error == nil) {
                    print("Successfully indexed on spotlight")
                    result(NSNumber(value: true))
                } else {
                    result(NSNumber(value: false))
                }
            }
        }
    }
    
    private func removeFromSearch(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args = call.arguments as! [String: Any?]
        let buoDict = args["buo"] as! [String: Any?]
        let buo: BranchUniversalObject? = convertToBUO(dict: buoDict)
        
        buo!.removeFromSpotlight { (error) in
            if (error == nil) {
                print("BUO successfully removed from spotlight")
                result(NSNumber(value: true))
            } else {
                result(NSNumber(value: false))
            }
        }
    }
    
    private func setIdentity(call: FlutterMethodCall) {
        let args = call.arguments as! [String: Any?]
        let userId = args["userId"] as! String
        Branch.getInstance().setIdentity(userId)
    }
    
    private func logout() {
        Branch.getInstance().logout()
    }
    
    private func getLatestReferringParams(result: @escaping FlutterResult) {
        let latestParams = Branch.getInstance().getLatestReferringParams()
        result(latestParams)
    }
    
    private func getFirstReferringParams(result: @escaping FlutterResult) {
        let firstParams = Branch.getInstance().getFirstReferringParams()
        result(firstParams)
    }
    
    private func setTrackingDisabled(call: FlutterMethodCall) {
        let args = call.arguments as! [String: Any?]
        let value = args["disable"] as! Bool
        Branch.setTrackingDisabled(value)
    }
    
    private func loadRewards(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args = call.arguments as! [String: Any?]
        
        //Branch.getInstance().getCreditHistory { (creditHistory, error) in
        //    if error == nil {
        //        print(creditHistory)
        //    }
        //}
        
        Branch.getInstance().loadRewards { (changed, error) in
            if (error == nil) {
                var credits = 0
                if let bucket = args["bucket"] as? String {
                    credits = Branch.getInstance().getCreditsForBucket(bucket)
                } else {
                    credits = Branch.getInstance().getCredits()
                }
                result(credits)
            } else {
                print(error)
                let err = (error as! NSError)
                result(FlutterError(code: String(err.code),
                message: err.localizedDescription,
                details: nil))
            }
        }
    }
    
    private func redeemRewards(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args = call.arguments as! [String: Any?]
        let count = args["count"] as! Int
        if let bucket = args["bucket"] as? String {
            Branch.getInstance().redeemRewards(count, forBucket: bucket, callback: {(success, error) in
                if success {
                    print("Redeemed 5 credits for myBucket!")
                    result(NSNumber(value: true))
                }
                else {
                    print("Failed to redeem credits: \(error)")
                    result(NSNumber(value: false))
                }
            })
        } else {
            Branch.getInstance().redeemRewards(count, callback: {(success, error) in
                if success {
                    print("Redeemed 5 credits!")
                    result(NSNumber(value: true))
                }
                else {
                    print("Failed to redeem credits: \(error)")
                    result(NSNumber(value: false))
                }
            })
        }
    }
}
