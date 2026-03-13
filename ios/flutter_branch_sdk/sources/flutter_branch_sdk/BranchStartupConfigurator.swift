import Foundation
import BranchSDK

protocol BranchSDKClientProtocol {
    func setAPIUrl(_ url: String)
    func setBranchKey(_ key: String)
    func registerPluginName(_ name: String, version: String)
    func checkPasteboardOnInstall()
}

final class BranchSDKClient: BranchSDKClientProtocol {
    func setAPIUrl(_ url: String) {
        Branch.setAPIUrl(url)
    }

    func setBranchKey(_ key: String) {
        Branch.setBranchKey(key)
    }

    func registerPluginName(_ name: String, version: String) {
        Branch.getInstance().registerPluginName(name, version: version)
    }

    func checkPasteboardOnInstall() {
        Branch.getInstance().checkPasteboardOnInstall()
    }
}

final class BranchStartupConfigurator {
    private let branchSDKClient: BranchSDKClientProtocol
    private let logHandler: LogStreamHandler?

    init(branchSDKClient: BranchSDKClientProtocol = BranchSDKClient(), logHandler: LogStreamHandler? = logStreamHandler) {
        self.branchSDKClient = branchSDKClient
        self.logHandler = logHandler
    }

    @discardableResult
    func apply(
        config: BranchJsonConfig,
        disableNativeLink: Bool,
        shouldCheckPasteboardOnInstall: Bool,
        pluginName: String,
        pluginVersion: String
    ) -> Bool {
        if let apiUrl = config.apiUrl {
            LogUtils.debug(message: "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
            LogUtils.debug(message: "The apiUrl parameter has been deprecated. Please use apiUrlIOS instead. Check the documentation.")
            LogUtils.debug(message: "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
            _ = apiUrl
        }

        if let apiUrlIOS = config.apiUrlIOS {
            branchSDKClient.setAPIUrl(apiUrlIOS)
            LogUtils.debug(message: "Set API URL from branch-config.json: \(apiUrlIOS)")
        }

        if let branchKey = config.branchKey {
            branchSDKClient.setBranchKey(branchKey)
            LogUtils.debug(message: "Set BranchKey from branch-config.json: \(branchKey)")
        } else {
            let testKey = config.testKey ?? ""
            let liveKey = config.liveKey ?? ""
            let useTestInstance = config.useTestInstance ?? false

            if useTestInstance && !testKey.isEmpty {
                branchSDKClient.setBranchKey(testKey)
                LogUtils.debug(message: "Set TestKey from branch-config.json: \(testKey)")
            } else if !liveKey.isEmpty {
                branchSDKClient.setBranchKey(liveKey)
                LogUtils.debug(message: "Set LiveKey from branch-config.json: \(liveKey)")
            }
        }

        var enableLoggingFromJson = false
        if let enableLogging = config.enableLogging, enableLogging {
            let logLevelStr = config.logLevel ?? "VERBOSE"
            let logLevel = branchMapLogLevel(logLevelStr)

            logHandler?.enableBranchLogging(at: logLevel)
            enableLoggingFromJson = true
            LogUtils.debug(message: "Set enableLogging and logLevel from branch-config.json: \(logLevelStr)")
        }

        branchSDKClient.registerPluginName(pluginName, version: pluginVersion)

        if !disableNativeLink && shouldCheckPasteboardOnInstall {
            branchSDKClient.checkPasteboardOnInstall()
        }

        return enableLoggingFromJson
    }
}

func branchMapLogLevel(_ logLevel: String) -> BranchLogLevel {
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