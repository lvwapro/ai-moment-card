# AI诗意瞬间卡片生成器

一款「AI 诗意瞬间卡片生成器」。它不仅仅是美化图片，而是为你的瞬间配上有灵魂的文字，并生成一张值得分享的优雅卡片。

## ✨ 核心功能

### 🎯 核心定位
- **AI赋能的美学表达**：通过惊艳的文案生成和无需思考的自动化设计，为用户提供即刻的成就感与分享欲
- **三步完成创作**：输入图片 → AI生成文案 → 自动设计卡片

### 🚀 核心功能闭环

1. **输入**：用户拍照或选图
2. **创作**：AI核心引擎自动（或根据关键词）生成一句诗或一段契合的文案
3. **呈现**：App将图片、文案、以及可选的精致二维码，自动合成在一张设计感十足的卡片上
4. **终点**：用户保存或分享这张成品卡片

### 🌟 核心亮点与差异化

#### 有灵魂的AI文案
- 不仅仅是标签，而是能生成真正有诗意、有氛围、有情感的短句或诗词
- 提供3种风格一键切换：
  - **现代诗**：简洁现代，富有哲理
  - **古诗**：古韵悠长，意境深远  
  - **俏皮话**：轻松幽默，贴近生活

#### 有设计感的自动排版
- 不是简单的模板堆砌
- AI会根据图片的色彩、构图和主题，自动匹配最合适的字体、文字颜色和排版位置
- 提供6个真正高质量的极简设计模板：
  - 极简、优雅、浪漫、复古、自然、都市

#### 有意义的二维码
- 扫描二维码后，能看到关于这张卡的更多信息（如生成时间、地点）
- 或者一句隐藏的诗句，让它成为卡片故事的一部分

### 📱 关键扩展功能

#### 「灵感长廊」
- 极简的本地历史记录页面
- 以时间线或瀑布流展示所有生成过的卡片
- 宛如用户个人的诗意日记本

#### 「隐藏设置」
- 提供一些不破坏主流程的微调选项
- 如是否显示二维码、切换Logo水印的显隐等

## 🎨 技术特色

- **Flutter 3.0+**：跨平台原生性能
- **Material Design 3**：现代化UI设计
- **Provider状态管理**：响应式数据流
- **模块化架构**：清晰的代码结构
- **优雅的动画**：流畅的用户体验

## 📦 项目结构

```
lib/
├── main.dart                 # 应用入口
├── models/                   # 数据模型
│   └── poetry_card.dart     # 卡片数据模型
├── providers/               # 状态管理
│   ├── app_state.dart      # 应用状态
│   ├── card_generator.dart # 卡片生成器
│   └── history_manager.dart # 历史记录管理
├── screens/                 # 页面
│   ├── home_screen.dart    # 主页
│   ├── card_generator_screen.dart # 卡片生成页
│   ├── card_result_screen.dart    # 生成结果页
│   ├── history_screen.dart        # 历史记录页
│   ├── card_detail_screen.dart    # 卡片详情页
│   └── settings_screen.dart       # 设置页
├── widgets/                 # 组件
│   ├── hero_section.dart   # 英雄区域
│   ├── usage_indicator.dart # 使用情况指示器
│   ├── quick_actions.dart  # 快速操作
│   ├── recent_cards.dart   # 最近卡片
│   ├── image_picker_widget.dart # 图片选择器
│   ├── poetry_style_selector.dart # 风格选择器
│   ├── card_preview.dart   # 卡片预览
│   ├── poetry_card_widget.dart # 卡片组件
│   └── history_filter_bar.dart # 历史筛选栏
├── services/               # 服务层
│   ├── ai_poetry_service.dart # AI文案服务
│   └── card_design_service.dart # 卡片设计服务
└── theme/                  # 主题
    └── app_theme.dart     # 应用主题
```

## 🚀 快速开始

### 环境要求
- Flutter 3.0+
- Dart 3.0+
- Android Studio / VS Code
- iOS 12.0+ / Android API 21+

### 安装步骤

1. **克隆项目**
```bash
git clone <repository-url>
cd ai-poetry-card
```

2. **安装依赖**
```bash
flutter pub get
```

3. **运行项目**
```bash
flutter run
```

### 主要依赖

```yaml
dependencies:
  flutter:
    sdk: flutter
  # UI & 动画
  cupertino_icons: ^1.0.2
  flutter_svg: ^2.0.9
  lottie: ^2.7.0
  
  # 图片处理
  image_picker: ^1.0.4
  cached_network_image: ^3.3.0
  image: ^4.1.3
  
  # 二维码
  qr_flutter: ^4.1.0
  
  # 状态管理
  provider: ^6.1.1
  
  # 本地存储
  shared_preferences: ^2.2.2
  sqflite: ^2.3.0
  path: ^1.8.3
  
  # 网络请求
  http: ^1.1.0
  
  # 工具类
  intl: ^0.18.1
  permission_handler: ^11.0.1
  
  # 分享功能
  share_plus: ^7.2.1
  
  # 文件操作
  path_provider: ^2.1.1
```

## 💡 使用说明

### 基本流程

1. **启动应用**：打开应用，查看今日使用情况
2. **选择图片**：点击"开始创作"，拍照或从相册选择图片
3. **选择风格**：选择你喜欢的文案风格（现代诗/古诗/俏皮话）
4. **生成卡片**：AI自动生成文案并设计卡片
5. **保存分享**：保存到相册或分享给朋友

### 功能说明

#### 免费版限制
- 每日可生成3张卡片
- 使用基础模板
- 包含水印

#### 专业版特权
- 无限生成次数
- 所有高级模板
- 独家字体样式
- 优先技术支持
- 无水印导出

## 🎯 商业化思路

### 免费用户
- 可使用所有核心功能
- 每日生成次数有限（3次）
- 使用基础模板

### 付费订阅
- 解锁无限生成
- 所有高级模板和独家字体
- 核心是为"热爱"付费，而不是为"功能"付费

## 🔮 未来规划

- [ ] 集成真实AI API（GPT/文心一言等）
- [ ] 增加更多文案风格
- [ ] 支持自定义模板
- [ ] 添加社交分享功能
- [ ] 支持视频卡片生成
- [ ] 多语言支持

## 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

## 📞 联系我们

- 项目地址：[GitHub Repository]
- 问题反馈：[Issues]
- 邮箱：your-email@example.com

---

**保持简单、优雅、有用，就是这个想法最成功的样子。** ✨
