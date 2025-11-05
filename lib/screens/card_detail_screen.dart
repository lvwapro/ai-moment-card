import 'package:ai_poetry_card/models/poetry_card.dart';
import 'package:ai_poetry_card/providers/history_manager.dart';
import 'package:ai_poetry_card/providers/card_generator.dart';
import 'package:ai_poetry_card/widgets/card/card_info_widget.dart';
import 'package:ai_poetry_card/widgets/home/nearby_places_widget.dart';
import 'package:ai_poetry_card/widgets/card/card_images_viewer.dart';
import 'package:ai_poetry_card/widgets/preview/multi_platform_preview_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../services/native_share_service.dart';
import '../services/gallery_service.dart';
import '../services/ai_poetry_service.dart';
import '../services/upgrade_service.dart';

import 'package:ai_poetry_card/services/language_service.dart';
import '../widgets/card/poetry_card_widget.dart';
import '../widgets/common/loading_overlay.dart';
import '../theme/app_theme.dart';
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter/painting.dart';
import 'package:path_provider/path_provider.dart';

/// 卡片详情/结果展示屏幕
/// 支持两种模式：详情查看模式和结果展示模式
class CardDetailScreen extends StatefulWidget {
  final PoetryCard card;
  final bool isResultMode; // true: 结果展示模式, false: 详情查看模式
  final bool autoShowPreview; // 是否自动显示预览弹窗

  const CardDetailScreen({
    super.key,
    required this.card,
    this.isResultMode = false,
    this.autoShowPreview = false,
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

    // 打印卡片数据
    _printCardData();

    // 添加生命周期监听器
    WidgetsBinding.instance.addObserver(this);

    // 如果是结果模式，保存到历史记录
    if (widget.isResultMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<HistoryManager>(context, listen: false)
            .addCard(widget.card);
      });
    }

    // 如果需要自动显示预览，延迟弹出预览弹窗
    if (widget.autoShowPreview) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showPreviewDialog();
      });
    }
  }

  /// 显示预览弹窗
  void _showPreviewDialog() {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false, // 设置为半透明
        barrierColor: Colors.transparent, // 透明的遮罩
        pageBuilder: (context, animation, secondaryAnimation) =>
            MultiPlatformPreviewDialog(card: _currentCard),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
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
        ),
        body: Stack(
          children: [
            Column(
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
            // 重新生成时的loading遮罩
            if (_isRegenerating) const LoadingOverlay(),
          ],
        ),
      );

  /// 结果模式底部操作按钮
  Widget _buildResultActions(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 预览按钮（单独一行，更醒目）
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _showPreviewDialog,
                icon: const Icon(Icons.phone_android),
                label: Text(context.l10n('预览各平台效果')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
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
                  onPressed: _isRegenerating ? null : _regenerateCard,
                  icon: _isRegenerating
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.refresh),
                  label: Text(context.l10n('重新生成')),
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
      // 等待图片加载完成
      await _ensureImageLoaded();

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
      // 1. 检查并请求相册权限
      final hasPermission =
          await GalleryService.instance.ensureAccess(toAlbum: true);

      if (!hasPermission) {
        if (mounted) {
          setState(() {
            _isSaving = false;
          });

          // 显示权限被拒绝的对话框
          await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(context.l10n('需要相册权限')),
              content: Text(context.l10n('请在设置中授予"照片和视频"访问权限，以便保存卡片到相册')),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(context.l10n('取消')),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    // 再次尝试请求权限
                    GalleryService.instance.requestAccess(toAlbum: true);
                  },
                  child: Text(context.l10n('重新授权')),
                ),
              ],
            ),
          );
        }
        return;
      }

      // 2. 等待图片加载完成
      await _ensureImageLoaded();

      // 3. 渲染卡片为图片
      RenderRepaintBoundary boundary =
          _cardKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);

      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        throw Exception('图片转换失败');
      }

      // 4. 保存到临时文件
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'AI诗意卡片_$timestamp.png';
      final filePath = '${tempDir.path}/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(byteData.buffer.asUint8List());

      // 5. 使用 gal 保存到相册
      final success = await GalleryService.instance.saveImage(
        filePath,
        useAlbum: true,
      );

      // 6. 清理临时文件
      try {
        // hct
        await file.delete();
      } catch (e) {
        debugPrint('清理临时文件失败: $e');
      }

      if (mounted) {
        setState(() {
          _isSaving = false;
        });

        if (success) {
          // 保存成功
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.l10n('已保存到相册')),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
              action: SnackBarAction(
                label: context.l10n('查看'),
                textColor: Colors.white,
                onPressed: GalleryService.instance.openGallery,
              ),
            ),
          );
        } else {
          // 保存失败
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.l10n('保存失败，请重试')),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('保存卡片失败: $e');
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
    } on QuotaExceededException catch (e) {
      // 配额已超，提示用户升级
      if (mounted) {
        // 显示错误提示
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 2),
          ),
        );
        // 直接显示升级弹窗
        UpgradeService().showUpgradeDialog(context);
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

  /// 打印卡片数据
  void _printCardData() {
    print('═══════════════════════════════════════════════════════');
    print('📋 CurrentCard:');
    print('═══════════════════════════════════════════════════════');
    print(_currentCard.toJson());
    print('═══════════════════════════════════════════════════════');
  }

  /// 确保图片已加载完成
  /// 通过预加载 ImageProvider 来确保图片已经加载到内存中
  Future<void> _ensureImageLoaded() async {
    final firstImagePath = _currentCard.getFirstImagePath();

    // 如果是网络图片或本地文件，尝试预加载
    if (firstImagePath.isNotEmpty) {
      ImageProvider? imageProvider;

      if (firstImagePath.startsWith('http')) {
        imageProvider = NetworkImage(firstImagePath);
      } else {
        try {
          final file = File(firstImagePath);
          if (await file.exists()) {
            imageProvider = FileImage(file);
          }
        } catch (e) {
          debugPrint('预加载图片失败: $e');
        }
      }

      if (imageProvider != null) {
        try {
          // 使用 resolve 来确保图片已加载
          final completer = Completer<void>();
          final stream = imageProvider.resolve(const ImageConfiguration());
          final listener = ImageStreamListener(
            (ImageInfo info, bool synchronousCall) {
              completer.complete();
            },
            onError: (exception, stackTrace) {
              // 图片加载失败，继续执行（会使用备用背景）
              completer.complete();
            },
          );
          stream.addListener(listener);

          // 等待图片加载完成，最多等待 2 秒
          await completer.future.timeout(
            const Duration(seconds: 2),
            onTimeout: () {
              stream.removeListener(listener);
            },
          );
        } catch (e) {
          debugPrint('预加载图片超时或失败: $e');
        }
      }
    }

    // 等待几帧以确保UI完全渲染
    await Future.delayed(const Duration(milliseconds: 200));
    await WidgetsBinding.instance.endOfFrame;
  }
}
