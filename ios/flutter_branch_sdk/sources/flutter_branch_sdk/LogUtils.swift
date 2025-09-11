//
//  File.swift
//  flutter_branch_sdk
//
//  Created by Rodrigo Marques on 10/09/25.
//

import Foundation

public class LogUtils {
    private static let DEBUG_NAME = "FlutterBranchSDK"
    public static func debug(message: String) {
        #if DEBUG
            print(DEBUG_NAME, " - ", message)
    #endif
    }
}
