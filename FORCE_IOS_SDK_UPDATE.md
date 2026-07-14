## Forcing the native iOS SDK to update to a specific patch version (e.g. 3.14.2)

If you're already on a `flutter_branch_sdk` version whose `Package.swift` allows a version range (e.g. `>=3.14.0 <3.15.0`), you don't need to wait for a new plugin release to pick up a newer patch like `3.14.2`. Xcode/SwiftPM just needs to be told to re-resolve, and its cache needs to be cleared first.

Run these steps from your Flutter app's root folder:

**1. Close Xcode** (if it's open, so it doesn't rewrite stale cache while you clean).

**2. Delete Xcode's DerivedData**

Xcode keeps its own copy of the resolved package versions in DerivedData, separate from `Package.resolved`. This is the main reason a stale version keeps getting reused.

```bash
rm -rf ~/Library/Developer/Xcode/DerivedData/Runner-*
```

**3. Delete the stale SwiftPM lockfile(s)**

```bash
find ios -name "Package.resolved" -delete
```

**4. Run `flutter clean`**

This clears Flutter's own build artifacts and ephemeral files (`build/`, `.dart_tool/`, `ios/Flutter/ephemeral`, etc.).

```bash
flutter clean
flutter pub get
```

**5. Re-resolve Swift Package dependencies**

```bash
cd ios
xcodebuild -resolvePackageDependencies -workspace Runner.xcworkspace -scheme Runner
cd ..
```

This should print the newly resolved version, e.g.:

```
Resolved source packages:
  BranchSDK: https://github.com/BranchMetrics/ios-branch-sdk-spm @ 3.14.2
```

**6. Build normally**

```bash
flutter build ios
```

### Note

This only works if the plugin's `Package.swift` dependency range already covers the version you want (e.g. `.upToNextMinor(from: "3.14.0")` allows any `3.14.x`). If you need a version outside the declared range (e.g. a new minor/major), you'll need an updated release of `flutter_branch_sdk` instead.
