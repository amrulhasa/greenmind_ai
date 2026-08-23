#!/bin/bash
set -e

echo "Installing Flutter..."

git clone https://github.com/flutter/flutter.git -b stable --depth 1 $HOME/flutter

export PATH="$PATH:$HOME/flutter/bin"

echo "Flutter version:"
flutter --version

echo "Enabling Flutter web..."
flutter config --enable-web

echo "Building Flutter web..."
flutter build web --release

echo "Build completed successfully."