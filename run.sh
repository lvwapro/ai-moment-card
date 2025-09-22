#!/bin/bash

# AI诗意瞬间卡片生成器 - 启动脚本

echo "🎨 AI诗意瞬间卡片生成器"
echo "=========================="
echo ""

# 检查Flutter是否安装
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter未安装，请先安装Flutter"
    echo "   访问: https://flutter.dev/docs/get-started/install"
    exit 1
fi

echo "✅ Flutter已安装"

# 检查依赖
echo "📦 检查依赖..."
flutter pub get

# 检查代码
echo "🔍 检查代码..."
flutter analyze

# 运行项目
echo "🚀 启动项目..."
echo ""
echo "选择运行平台:"
echo "1) Android模拟器"
echo "2) iOS模拟器 (仅macOS)"
echo "3) Web浏览器"
echo "4) 桌面应用"
echo ""
read -p "请输入选择 (1-4): " choice

case $choice in
    1)
        echo "启动Android模拟器..."
        flutter run -d android
        ;;
    2)
        echo "启动iOS模拟器..."
        flutter run -d ios
        ;;
    3)
        echo "启动Web浏览器..."
        flutter run -d web-server --web-port 8080
        ;;
    4)
        echo "启动桌面应用..."
        flutter run -d macos
        ;;
    *)
        echo "无效选择，启动默认平台..."
        flutter run
        ;;
esac
