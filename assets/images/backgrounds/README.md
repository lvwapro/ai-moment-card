# 背景图片资源说明

请将以下4张背景图片添加到 `assets/images/backgrounds/` 目录中：

## 背景图片列表

1. **dog_in_flowers.jpg** - 花丛中的狗背景
   - 描述：白色马尔济斯犬在花丛中跳跃，充满活力的场景
   - 对应模板：BackgroundTemplate.dogInFlowers

2. **cormorant_fishing.jpg** - 鸬鹚捕鱼背景
   - 描述：渔夫和鸬鹚在晨雾中的传统捕鱼场景
   - 对应模板：BackgroundTemplate.cormorantFishing

3. **traditional_view.jpg** - 传统景观背景
   - 描述：传统建筑和山峦的室内外景观
   - 对应模板：BackgroundTemplate.traditionalView

4. **mountain_sunset.jpg** - 山峦日落背景
   - 描述：雪峰在日落时分的壮丽景色
   - 对应模板：BackgroundTemplate.mountainSunset

## 图片要求

- 格式：JPG 或 PNG
- 尺寸：建议 400x400 像素或更高分辨率
- 质量：高清，适合作为卡片背景
- 命名：严格按照上述文件名命名

## 添加步骤

1. 将4张图片文件复制到 `assets/images/backgrounds/` 目录
2. 确保文件名与上述列表完全一致
3. 运行 `flutter pub get` 更新资源
4. 重新构建应用

## 智能选择逻辑

系统会根据用户信息智能选择背景：

- **宠物爱好者** → 花丛中的狗背景
- **旅行/摄影爱好者** → 山峦日落背景
- **园艺/自然爱好者** → 花丛中的狗背景
- **文艺/浪漫性格** → 传统景观背景
- **哲学/深沉性格** → 鸬鹚捕鱼背景
- **其他情况** → 随机选择

## 注意事项

- 如果图片文件不存在，系统会自动回退到程序化生成的背景
- 建议图片文件大小控制在500KB以内以优化应用性能
- 所有图片都会自动适配不同的屏幕尺寸