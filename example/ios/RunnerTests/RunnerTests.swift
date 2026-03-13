import Flutter
import UIKit
import XCTest
import BranchSDK
@testable import flutter_branch_sdk

final class EventRecorder {
  var events: [String] = []
}

final class RecordingBranchSDKClient: BranchSDKClientProtocol {
  init(recorder: EventRecorder) {
    self.recorder = recorder
  }

  private let recorder: EventRecorder

  func setAPIUrl(_ url: String) {
    recorder.events.append("api:\(url)")
  }

  func setBranchKey(_ key: String) {
    recorder.events.append("key:\(key)")
  }

  func registerPluginName(_ name: String, version: String) {
    recorder.events.append("register:\(name):\(version)")
  }

  func checkPasteboardOnInstall() {
    recorder.events.append("pasteboard")
  }
}

final class RecordingLogStreamHandler: LogStreamHandler {
  init(recorder: EventRecorder) {
    self.recorder = recorder
  }

  private let recorder: EventRecorder

  override func enableBranchLogging(at level: BranchLogLevel) {
    recorder.events.append("log:\(level.rawValue)")
  }
}

class RunnerTests: XCTestCase {

  func testExample() {
    // If you add code to the Runner application, consider adding tests here.
    // See https://developer.apple.com/documentation/xctest for more information about using XCTest.
  }

  func testBranchKeyIsAppliedBeforeLoggingForTestInstance() {
    let recorder = EventRecorder()
    let configurator = BranchStartupConfigurator(
      branchSDKClient: RecordingBranchSDKClient(recorder: recorder),
      logHandler: RecordingLogStreamHandler(recorder: recorder)
    )

    let config = BranchJsonConfig(
      apiUrl: nil,
      apiUrlAndroid: nil,
      apiUrlIOS: nil,
      branchKey: nil,
      liveKey: "live_key",
      testKey: "test_key",
      enableLogging: true,
      logLevel: "VERBOSE",
      useTestInstance: true
    )

    let enableLoggingFromJson = configurator.apply(
      config: config,
      disableNativeLink: false,
      shouldCheckPasteboardOnInstall: false,
      pluginName: "Flutter",
      pluginVersion: "9.1.0"
    )

    XCTAssertTrue(enableLoggingFromJson)
    XCTAssertEqual(
      recorder.events,
      [
        "key:test_key",
        "log:0",
        "register:Flutter:9.1.0"
      ]
    )
  }

  func testExplicitBranchKeyTakesPriorityAndNoLoggingWhenDisabled() {
    let recorder = EventRecorder()
    let configurator = BranchStartupConfigurator(
      branchSDKClient: RecordingBranchSDKClient(recorder: recorder),
      logHandler: RecordingLogStreamHandler(recorder: recorder)
    )

    let config = BranchJsonConfig(
      apiUrl: nil,
      apiUrlAndroid: nil,
      apiUrlIOS: nil,
      branchKey: "explicit_key",
      liveKey: "live_key",
      testKey: "test_key",
      enableLogging: false,
      logLevel: "ERROR",
      useTestInstance: true
    )

    let enableLoggingFromJson = configurator.apply(
      config: config,
      disableNativeLink: false,
      shouldCheckPasteboardOnInstall: false,
      pluginName: "Flutter",
      pluginVersion: "9.1.0"
    )

    XCTAssertFalse(enableLoggingFromJson)
    XCTAssertEqual(
      recorder.events,
      [
        "key:explicit_key",
        "register:Flutter:9.1.0"
      ]
    )
  }

}
