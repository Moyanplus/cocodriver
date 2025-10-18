#!/bin/bash

# Flutter Release 构建脚本 - 优化体积版本
# 作者: AI Assistant
# 日期: $(date +%Y-%m-%d)

set -e  # 遇到错误立即退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查Flutter环境
check_flutter() {
    log_info "检查Flutter环境..."
    if ! command -v flutter &> /dev/null; then
        log_error "Flutter未安装或未添加到PATH"
        exit 1
    fi
    
    flutter doctor --version
    log_success "Flutter环境检查完成"
}

# 清理项目
clean_project() {
    log_info "清理项目..."
    flutter clean
    rm -rf build/
    rm -rf .dart_tool/
    log_success "项目清理完成"
}

# 获取依赖
get_dependencies() {
    log_info "获取依赖包..."
    flutter pub get
    log_success "依赖包获取完成"
}

# 构建Release APK (单架构)
build_release_apk() {
    local arch=$1
    log_info "构建Release APK (${arch})..."
    
    flutter build apk \
        --release \
        --target-platform ${arch} \
        --obfuscate \
        --split-debug-info=build/debug-info \
        --shrink \
        --no-tree-shake-icons
    
    log_success "Release APK构建完成 (${arch})"
}

# 构建App Bundle (推荐)
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

# 构建分架构APK
build_split_apks() {
    log_info "构建分架构APK..."
    
    # ARM64 (主流架构)
    build_release_apk "android-arm64"
    mv build/app/outputs/flutter-apk/app-release.apk build/app/outputs/flutter-apk/app-arm64-release.apk
    
    # ARM (兼容老设备)
    build_release_apk "android-arm"
    mv build/app/outputs/flutter-apk/app-release.apk build/app/outputs/flutter-apk/app-arm-release.apk
    
    log_success "分架构APK构建完成"
}

# 分析APK大小
analyze_size() {
    log_info "分析APK大小..."
    
    if [ -f "build/app/outputs/flutter-apk/app-arm64-release.apk" ]; then
        local size=$(du -h build/app/outputs/flutter-apk/app-arm64-release.apk | cut -f1)
        log_info "ARM64 APK大小: ${size}"
    fi
    
    if [ -f "build/app/outputs/flutter-apk/app-arm-release.apk" ]; then
        local size=$(du -h build/app/outputs/flutter-apk/app-arm-release.apk | cut -f1)
        log_info "ARM APK大小: ${size}"
    fi
    
    if [ -f "build/app/outputs/bundle/release/app-release.aab" ]; then
        local size=$(du -h build/app/outputs/bundle/release/app-release.aab | cut -f1)
        log_info "App Bundle大小: ${size}"
    fi
}

# 显示构建结果
show_results() {
    log_success "构建完成！"
    echo ""
    echo "📱 构建产物:"
    echo "├── ARM64 APK: build/app/outputs/flutter-apk/app-arm64-release.apk"
    echo "├── ARM APK: build/app/outputs/flutter-apk/app-arm-release.apk"
    echo "└── App Bundle: build/app/outputs/bundle/release/app-release.aab"
    echo ""
    echo "📊 调试信息: build/debug-info/"
    echo ""
    echo "💡 建议:"
    echo "   - 上传App Bundle到Google Play Store"
    echo "   - 使用APK进行测试或第三方分发"
    echo "   - ARM64版本适用于大多数现代设备"
}

# 主函数
main() {
    echo "🚀 Flutter Release 构建脚本启动"
    echo "=================================="
    
    # 检查参数
    case "${1:-all}" in
        "clean")
            clean_project
            ;;
        "apk")
            check_flutter
            clean_project
            get_dependencies
            build_split_apks
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
            build_split_apks
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
    echo "  clean    - 仅清理项目"
    echo "  apk      - 构建分架构APK"
    echo "  bundle   - 构建App Bundle"
    echo "  all      - 构建所有格式 (默认)"
    echo "  help     - 显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  $0          # 构建所有格式"
    echo "  $0 apk      # 仅构建APK"
    echo "  $0 bundle   # 仅构建App Bundle"
}

# 处理帮助参数
if [ "$1" = "help" ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    show_help
    exit 0
fi

# 执行主函数
main "$@"
