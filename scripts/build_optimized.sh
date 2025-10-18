#!/bin/bash

# Flutter 优化构建脚本 - 目标30MB以下
# 作者: AI Assistant
# 日期: $(date +%Y-%m-%d)

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 日志函数
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# 检查Flutter环境
check_flutter() {
    log_info "检查Flutter环境..."
    if ! command -v flutter &> /dev/null; then
        log_error "Flutter未安装或未添加到PATH"
        exit 1
    fi
    log_success "Flutter环境检查完成"
}

# 清理项目
clean_project() {
    log_info "清理项目..."
    flutter clean
    rm -rf build/ .dart_tool/
    log_success "项目清理完成"
}

# 获取依赖
get_dependencies() {
    log_info "获取依赖包..."
    flutter pub get
    log_success "依赖包获取完成"
}

# 优化依赖 - 移除不必要的包
optimize_dependencies() {
    log_info "优化依赖配置..."
    
    # 创建精简版pubspec.yaml
    cat > pubspec_minimal.yaml << 'EOF'
name: flutter_ui_template
description: "Flutter UI模板项目 - 精简版"
publish_to: "none"
version: 1.0.0+1

environment:
  sdk: "^3.7.0"

dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.2
  
  # 核心功能
  provider: ^6.1.1
  flutter_riverpod: ^2.4.9
  
  # 基础UI
  flutter_screenutil: ^5.9.0
  google_fonts: ^6.1.0
  
  # 存储
  shared_preferences: ^2.2.2
  
  # 网络
  dio: ^5.4.0
  
  # 国际化
  intl: ^0.20.2
  flutter_localizations:
    sdk: flutter

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0

flutter:
  uses-material-design: true
  generate: true
EOF
    
    log_success "依赖优化完成"
}

# 构建最小体积APK
build_minimal_apk() {
    log_info "构建最小体积APK..."
    
    # 备份原pubspec.yaml
    cp pubspec.yaml pubspec_backup.yaml
    
    # 使用精简版依赖
    cp pubspec_minimal.yaml pubspec.yaml
    flutter pub get
    
    # 构建APK
    flutter build apk \
        --release \
        --target-platform android-arm64 \
        --obfuscate \
        --split-debug-info=build/debug-info \
        --shrink \
        --no-tree-shake-icons \
        --dart-define=FLUTTER_WEB_USE_SKIA=true
    
    # 恢复原pubspec.yaml
    mv pubspec_backup.yaml pubspec.yaml
    flutter pub get
    
    # 重命名文件
    mv build/app/outputs/flutter-apk/app-release.apk build/app/outputs/flutter-apk/app-minimal-optimized.apk
    
    log_success "最小体积APK构建完成"
}

# 构建标准Release APK
build_release_apk() {
    log_info "构建标准Release APK..."
    
    flutter build apk \
        --release \
        --target-platform android-arm64 \
        --obfuscate \
        --split-debug-info=build/debug-info \
        --shrink \
        --no-tree-shake-icons
    
    mv build/app/outputs/flutter-apk/app-release.apk build/app/outputs/flutter-apk/app-standard-release.apk
    
    log_success "标准Release APK构建完成"
}

# 构建App Bundle
build_app_bundle() {
    log_info "构建App Bundle..."
    
    flutter build appbundle \
        --release \
        --obfuscate \
        --split-debug-info=build/debug-info \
        --shrink \
        --no-tree-shake-icons
    
    log_success "App Bundle构建完成"
}

# 分析APK大小
analyze_size() {
    log_info "分析APK大小..."
    
    echo ""
    echo "📊 APK大小分析:"
    echo "=================="
    
    if [ -f "build/app/outputs/flutter-apk/app-minimal-optimized.apk" ]; then
        local size=$(du -h build/app/outputs/flutter-apk/app-minimal-optimized.apk | cut -f1)
        echo "🔹 最小优化版: ${size}"
    fi
    
    if [ -f "build/app/outputs/flutter-apk/app-standard-release.apk" ]; then
        local size=$(du -h build/app/outputs/flutter-apk/app-standard-release.apk | cut -f1)
        echo "🔹 标准Release版: ${size}"
    fi
    
    if [ -f "build/app/outputs/bundle/release/app-release.aab" ]; then
        local size=$(du -h build/app/outputs/bundle/release/app-release.aab | cut -f1)
        echo "🔹 App Bundle: ${size}"
    fi
    
    echo ""
}

# 显示构建结果
show_results() {
    log_success "构建完成！"
    echo ""
    echo "📱 构建产物:"
    echo "├── 最小优化版: build/app/outputs/flutter-apk/app-minimal-optimized.apk"
    echo "├── 标准Release版: build/app/outputs/flutter-apk/app-standard-release.apk"
    echo "└── App Bundle: build/app/outputs/bundle/release/app-release.aab"
    echo ""
    echo "📊 调试信息: build/debug-info/"
    echo ""
    echo "💡 建议:"
    echo "   - 最小优化版适用于测试和演示"
    echo "   - 标准Release版包含完整功能"
    echo "   - App Bundle用于Google Play Store发布"
}

# 主函数
main() {
    echo "🚀 Flutter 优化构建脚本启动"
    echo "目标: 构建30MB以下的APK"
    echo "=================================="
    
    case "${1:-all}" in
        "clean")
            clean_project
            ;;
        "minimal")
            check_flutter
            clean_project
            get_dependencies
            optimize_dependencies
            build_minimal_apk
            analyze_size
            show_results
            ;;
        "standard")
            check_flutter
            clean_project
            get_dependencies
            build_release_apk
            analyze_size
            show_results
            ;;
        "bundle")
            check_flutter
            clean_project
            get_dependencies
            build_app_bundle
            analyze_size
            show_results
            ;;
        "all"|*)
            check_flutter
            clean_project
            get_dependencies
            optimize_dependencies
            build_minimal_apk
            build_release_apk
            build_app_bundle
            analyze_size
            show_results
            ;;
    esac
    
    log_success "脚本执行完成！"
}

# 显示帮助信息
show_help() {
    echo "用法: $0 [选项]"
    echo ""
    echo "选项:"
    echo "  clean     - 仅清理项目"
    echo "  minimal   - 构建最小体积APK (推荐)"
    echo "  standard  - 构建标准Release APK"
    echo "  bundle    - 构建App Bundle"
    echo "  all       - 构建所有格式 (默认)"
    echo "  help      - 显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  $0 minimal    # 构建最小体积APK"
    echo "  $0 standard   # 构建标准APK"
    echo "  $0 bundle     # 构建App Bundle"
}

# 处理帮助参数
if [ "$1" = "help" ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    show_help
    exit 0
fi

# 执行主函数
main "$@"
