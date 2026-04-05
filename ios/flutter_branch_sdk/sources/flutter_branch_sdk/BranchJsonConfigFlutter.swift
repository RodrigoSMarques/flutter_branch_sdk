import Foundation
import Flutter

struct BranchJsonConfigFlutter: Codable {
    let apiUrl: String?
    let apiUrlAndroid: String?
    let apiUrlIOS: String?
    let branchKey: String?
    let liveKey: String?
    let testKey: String?
    let enableLogging: Bool?
    let logLevel: String?
    let useTestInstance: Bool?
    let installReferrerTimeout: Int?

    static func loadFromFile(registrar: FlutterPluginRegistrar) -> BranchJsonConfigFlutter? {
        let assetKey = registrar.lookupKey(forAsset: "assets/branch-config.json")
        
        guard let path = Bundle.main.path(forResource: assetKey, ofType: nil) else {
            LogUtils.debug(message: "Configuration file 'assets/branch-config.json' not found. Using default configuration.")
            return nil
        }
        
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path))
            let config = try JSONDecoder().decode(BranchJsonConfigFlutter.self, from: data)
            LogUtils.debug(message: "BranchJsonConfigFlutter loaded successfully from 'assets/branch-config.json'")
            return config
        } catch let decodingError as DecodingError {
            LogUtils.debug(message: "Failed to decode 'assets/branch-config.json'. Invalid JSON structure. Error: \(decodingError)")
            return nil
        } catch {
            LogUtils.debug(message: "Failed to read 'assets/branch-config.json'. Error: \(error)")
            return nil
        }
    }
}
