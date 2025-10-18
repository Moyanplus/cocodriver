#!/bin/bash

# Flutter 精简构建脚本 - 最小体积版本
# 目标: 构建小于30MB的APK

set -e

echo "🚀 开始精简构建..."

# 清理
flutter clean
flutter pub get

# 构建最小体积的Release APK (仅ARM64)
echo "📱 构建ARM64 Release APK..."
flutter build apk \
    --release \
    --target-platform android-arm64 \
    --obfuscate \
    --split-debug-info=build/debug-info \
    --shrink \
    --no-tree-shake-icons

# 重命名文件
mv build/app/outputs/flutter-apk/app-release.apk build/app/outputs/flutter-apk/app-minimal-release.apk

# 显示大小
size=$(du -h build/app/outputs/flutter-apk/app-minimal-release.apk | cut -f1)
echo "✅ 构建完成! APK大小: $size"
echo "📁 文件位置: build/app/outputs/flutter-apk/app-minimal-release.apk"
