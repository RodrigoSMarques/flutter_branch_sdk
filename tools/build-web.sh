#!/bin/sh
# This scrip installs the dependencies of the flutter package.
# parse_server_sdk is set to the relative path.

cd example
ls -l
flutter pub get
flutter build web