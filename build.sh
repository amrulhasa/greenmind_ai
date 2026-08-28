#!/bin/bash
set -e

FLUTTER_VERSION="3.44.8"
FLUTTER_DIR="$HOME/flutter"

echo "Installing Flutter $FLUTTER_VERSION..."

if [ ! -d "$FLUTTER_DIR" ]; then
  git clone \
    https://github.com/flutter/flutter.git \
    -b "$FLUTTER_VERSION" \
    --depth 1 \
    "$FLUTTER_DIR"
fi

export PATH="$FLUTTER_DIR/bin:$PATH"

echo "Flutter version:"
flutter --version

echo "Enabling Flutter web..."
flutter config --enable-web

echo "Getting dependencies..."
flutter pub get

echo "Building Flutter web..."
flutter build web --release

echo "Build completed successfully."