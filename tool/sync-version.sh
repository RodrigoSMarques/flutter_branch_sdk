#!/bin/sh
# Keeps PLUGIN_VERSION in the iOS plugin in sync with the version in pubspec.yaml.
# The build number (e.g. "+1" in 9.3.4+1) is ignored.
#
# Usage:
#   tool/sync-version.sh          # update the Swift constant
#   tool/sync-version.sh --check  # exit 1 if out of sync (used in CI)

set -e

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SWIFT_FILE="$ROOT/ios/flutter_branch_sdk/sources/flutter_branch_sdk/FlutterBranchSdkPlugin.swift"

VERSION="$(sed -n 's/^version:[[:space:]]*\([0-9][0-9.]*\).*/\1/p' "$ROOT/pubspec.yaml" | head -n 1)"
if [ -z "$VERSION" ]; then
  echo "Could not read version from pubspec.yaml" >&2
  exit 1
fi

CURRENT="$(sed -n 's/^let PLUGIN_VERSION = "\(.*\)";.*/\1/p' "$SWIFT_FILE")"
if [ -z "$CURRENT" ]; then
  echo "PLUGIN_VERSION not found in $SWIFT_FILE" >&2
  exit 1
fi

if [ "$CURRENT" = "$VERSION" ]; then
  echo "PLUGIN_VERSION is up to date ($VERSION)"
  exit 0
fi

if [ "$1" = "--check" ]; then
  echo "PLUGIN_VERSION ($CURRENT) in FlutterBranchSdkPlugin.swift does not match pubspec.yaml ($VERSION)." >&2
  echo "Run tool/sync-version.sh to fix it." >&2
  exit 1
fi

# Portable in-place edit (BSD and GNU sed)
sed "s/^let PLUGIN_VERSION = \".*\";/let PLUGIN_VERSION = \"$VERSION\";/" "$SWIFT_FILE" > "$SWIFT_FILE.tmp"
mv "$SWIFT_FILE.tmp" "$SWIFT_FILE"
echo "PLUGIN_VERSION updated: $CURRENT -> $VERSION"
