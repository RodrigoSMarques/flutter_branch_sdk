#!/bin/sh
# This scrip installs the dependencies of the flutter package.
# parse_server_sdk is set to the relative path.

cd example
flutter config --no-analytics
flutter pub get
#flutter build web --source-maps
#flutter build web --profile --source-maps --dart-define=Dart2jsOptimization=O0
flutter build web