//
//  BranchJsonConfig.swift
//  flutter_branch_sdk
//
//  Created by Rodrigo Marques on 10/09/25.
//


import Foundation
import Flutter

// A struct corresponde ao JSON, mas todas as propriedades são opcionais (?)
struct BranchJsonConfig: Codable {
    let apiUrl: String?
    let branchKey: String?
    let liveKey: String?
    let testKey: String?
    let enableLogging: Bool?
    let useTestInstance: Bool?

    static func loadFromFile(registrar: FlutterPluginRegistrar) -> BranchJsonConfig? {
        let assetKey = registrar.lookupKey(forAsset: "assets/branch-config.json")
        
        guard let path = Bundle.main.path(forResource: assetKey, ofType: nil) else {
            // File 'assets/branch-config.json' not exists
            return nil
        }
        
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path))
            return try JSONDecoder().decode(BranchJsonConfig.self, from: data)
        } catch {
            // Erro se o arquivo existir, mas for inválido.
            LogUtils.debug(message: "Failed to decode 'assets/branch-config.json'. Check if the JSON is valid. Error:: \(error)")
            return nil
        }
    }
}
