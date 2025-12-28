#!/bin/bash

# Sakinah Flow - Font Setup Script
# This script downloads and sets up the required fonts

echo "🌙 Setting up fonts for Sakinah Flow..."

# Create fonts directory
mkdir -p assets/fonts

cd assets/fonts

# Download Inter font
echo "📥 Downloading Inter font..."
curl -L "https://github.com/google/fonts/raw/main/ofl/inter/Inter-Regular.ttf" -o Inter-Regular.ttf
curl -L "https://github.com/google/fonts/raw/main/ofl/inter/Inter-Medium.ttf" -o Inter-Medium.ttf
curl -L "https://github.com/google/fonts/raw/main/ofl/inter/Inter-SemiBold.ttf" -o Inter-SemiBold.ttf
curl -L "https://github.com/google/fonts/raw/main/ofl/inter/Inter-Bold.ttf" -o Inter-Bold.ttf

# Download Amiri font
echo "📥 Downloading Amiri font..."
curl -L "https://github.com/google/fonts/raw/main/ofl/amiri/Amiri-Regular.ttf" -o Amiri-Regular.ttf
curl -L "https://github.com/google/fonts/raw/main/ofl/amiri/Amiri-Bold.ttf" -o Amiri-Bold.ttf

cd ../..

echo "✅ Fonts downloaded successfully!"
echo ""
echo "Now uncomment the fonts section in pubspec.yaml and run:"
echo "  flutter pub get"
echo "  flutter run"
