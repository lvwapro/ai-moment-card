import 'package:ai_poetry_card/models/poetry_card.dart';
import 'package:ai_poetry_card/providers/history_manager.dart';
import 'package:ai_poetry_card/providers/card_generator.dart';
import 'package:ai_poetry_card/widgets/card_info_widget.dart';
import 'package:ai_poetry_card/widgets/nearby_places_widget.dart';
import 'package:ai_poetry_card/widgets/card_images_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../services/native_share_service.dart';

import 'package:ai_poetry_card/services/language_service.dart';
import '../widgets/poetry_card_widget.dart';
import '../theme/app_theme.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';

/// 卡片详情/结果展示屏幕
/// 支持两种模式：详情查看模式和结果展示模式
class CardDetailScreen extends StatefulWidget {
  final PoetryCard card;
  final bool isResultMode; // true: 结果展示模式, false: 详情查看模式

  const CardDetailScreen({
    super.key,
    required this.card,
    this.isResultMode = false,
  });

  @override
  State<CardDetailScreen> createState() => _CardDetailScreenState();
}

class _CardDetailScreenState extends State<CardDetailScreen>
    with WidgetsBindingObserver {
  final GlobalKey _cardKey =
      GlobalKey(debugLabel: 'card_detail_repaint_boundary');
  late PoetryCard _currentCard;
  bool _isRegenerating = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _currentCard = widget.card;

    // 添加生命周期监听器
    WidgetsBinding.instance.addObserver(this);

    // 如果是结果模式，保存到历史记录
    if (widget.isResultMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<HistoryManager>(context, listen: false)
            .addCard(widget.card);
      });
    }
  }

  @override
  void dispose() {
    // 移除生命周期监听器
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // 原生分享方案不需要复杂的生命周期处理
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          leading: IconButton(
            icon:
                const Icon(Icons.arrow_back_ios, color: AppTheme.primaryColor),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
              widget.isResultMode ? context.l10n('生成完成') : context.l10n('卡片详情'),
              style: TextStyle(color: Theme.of(context).primaryColor)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: widget.isResultMode
              ? [
                  // 重新生成图标按钮
                  if (_isRegenerating)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    )
                  else
                    IconButton(
                      icon: Icon(
                        Icons.refresh,
                        color: Theme.of(context).primaryColor,
                      ),
                      onPressed: _regenerateCard,
                      tooltip: context.l10n('重新生成文案'),
                    ),
                ]
              : null,
        ),
        body: Column(
          children: [
            // 卡片展示
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // 卡片展示
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: RepaintBoundary(
                        key: _cardKey,
                        child: PoetryCardWidget(
                          card: _currentCard,
                          showControls: false,
                        ),
                      ),
                    ),

                    // 卡片信息（包含各平台文案）
                    CardInfoWidget(
                      card: _currentCard,
                      onPoetryUpdated: (updatedCard) {
                        setState(() {
                          _currentCard = updatedCard;
                        });
                      },
                    ),

                    // 图片查看器
                    CardImagesViewer(card: _currentCard),

                    // 附近地点信息
                    if (_currentCard.selectedPlace != null)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                        child: NearbyPlacesWidget(
                          places: [_currentCard.selectedPlace!],
                        ),
                      ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // 结果模式：底部操作按钮
            _buildResultActions(context),
          ],
        ),
      );

  /// 结果模式底部操作按钮
  Widget _buildResultActions(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _shareCard(context),
                    icon: const Icon(Icons.share),
                    label: Text(context.l10n('分享')),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).primaryColor,
                      side: BorderSide(color: Theme.of(context).primaryColor),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isSaving ? () {} : () => _saveCard(context),
                    icon: _isSaving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.download),
                    label: Text(context.l10n('保存')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Theme.of(context).primaryColor,
                      disabledForegroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            if (widget.isResultMode) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: _createAnother,
                  icon: const Icon(Icons.add),
                  label: Text(context.l10n('再创作一张')),
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ],
          ],
        ),
      );

  /// 分享卡片（存储到文件/分享）
  void _shareCard(BuildContext context) async {
    try {
      // 渲染卡片为图片
      RenderRepaintBoundary boundary =
          _cardKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);

      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        throw Exception('图片转换失败');
      }

      // 保存到临时文件
      final tempDir = await getTemporaryDirectory();
      final fileName = 'AI诗意卡片_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(byteData.buffer.asUint8List());

      // 使用原生分享方案（已验证无蒙层）
      try {
        final success = await NativeShareService.shareImage(file.path);
        if (!success) {
          // 回退到插件方案
          Share.shareXFiles(
            [XFile(file.path)],
            subject: context.l10n('我的诗意瞬间'),
          );
        }
      } catch (e) {
        // 回退到插件方案
        Share.shareXFiles(
          [XFile(file.path)],
          subject: context.l10n('我的诗意瞬间'),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n('分享失败：$e')),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  /// 保存到相册（点击保存按钮）
  void _saveCard(BuildContext context) async {
    setState(() {
      _isSaving = true;
    });

    try {
      // 渲染卡片为图片
      RenderRepaintBoundary boundary =
          _cardKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);

      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        throw Exception('图片转换失败');
      }

      // 保存到相册
      await Share.shareXFiles(
        [
          XFile.fromData(byteData.buffer.asUint8List(),
              name: 'AI诗意卡片_${DateTime.now().millisecondsSinceEpoch}.png')
        ],
        subject: context.l10n('我的诗意瞬间'),
      );

      if (mounted) {
        setState(() {
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n('保存成功')),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n('保存失败：$e')),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  /// 重新生成文案
  void _regenerateCard() async {
    setState(() {
      _isRegenerating = true;
    });

    try {
      final cardGenerator = Provider.of<CardGenerator>(context, listen: false);

      // 调用重新生成卡片方法
      final newCard = await cardGenerator.regenerateCard(_currentCard);

      // 更新当前卡片
      setState(() {
        _currentCard = newCard;
      });

      // 更新历史记录中的卡片（addCard会自动更新已存在的卡片）
      if (widget.isResultMode) {
        Provider.of<HistoryManager>(context, listen: false).addCard(newCard);
      }

      // 显示成功提示
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n('文案重新生成成功')),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n('重新生成失败：$e')),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRegenerating = false;
        });
      }
    }
  }

  /// 再创作一张卡片
  void _createAnother() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/',
      (route) => false,
    );
  }
}
