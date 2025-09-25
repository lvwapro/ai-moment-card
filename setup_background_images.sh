#!/bin/bash

# 设置背景图片脚本
# 请将您提供的8张图片按照以下文件名放置到 assets/images/backgrounds/ 目录中

echo "🎨 设置AI诗意卡片背景图片"
echo "================================"

# 创建背景图片目录
mkdir -p assets/images/backgrounds

echo "📁 已创建目录: assets/images/backgrounds/"
echo ""
echo "请将以下4张图片文件复制到 assets/images/backgrounds/ 目录中："
echo ""
echo "1. dog_in_flowers.jpg   - 花丛中的狗背景"  
echo "2. cormorant_fishing.jpg - 鸬鹚捕鱼背景"
echo "3. traditional_view.jpg - 传统景观背景"
echo "4. mountain_sunset.jpg  - 山峦日落背景"
echo ""
echo "添加完成后，运行以下命令："
echo "flutter pub get"
echo "flutter run"
echo ""
echo "✨ 系统将自动根据用户信息智能选择最合适的背景图片！"
