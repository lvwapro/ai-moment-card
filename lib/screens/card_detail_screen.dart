import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:provider/provider.dart';
import 'package:ai_poetry_card/models/poetry_card.dart';
import 'package:ai_poetry_card/widgets/poetry_card_widget.dart';
import 'package:ai_poetry_card/providers/history_manager.dart';
import 'package:ai_poetry_card/providers/card_generator.dart';
import 'package:ai_poetry_card/services/image_save_service.dart';

class CardDetailScreen extends StatefulWidget {
  final PoetryCard card;

  const CardDetailScreen({
    super.key,
    required this.card,
  });

  @override
  State<CardDetailScreen> createState() => _CardDetailScreenState();
}

class _CardDetailScreenState extends State<CardDetailScreen> {
  final GlobalKey _cardKey = GlobalKey();
  bool _isRegenerating = false;
  late PoetryCard _currentCard;

  @override
  void initState() {
    super.initState();
    _currentCard = widget.card;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          title: const Text('卡片详情'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () => _shareCard(context),
            ),
            IconButton(
              icon: const Icon(Icons.save_alt),
              onPressed: () => _saveCard(context),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'copy':
                    _copyText(context);
                    break;
                  case 'delete':
                    _deleteCard(context);
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'copy',
                  child: Row(
                    children: [
                      Icon(Icons.copy),
                      SizedBox(width: 8),
                      Text('复制文案'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('删除卡片', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        body: SingleChildScrollView(
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

              // 卡片信息
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '卡片信息',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    _buildPoetrySection(),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                        '风格', _getStyleDisplayName(_currentCard.style)),
                    _buildInfoRow(
                        '创建时间', _formatDateTime(_currentCard.createdAt)),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      );

  Widget _buildPoetrySection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '文案',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.copy, size: 20),
                onPressed: () => _copyText(context),
                tooltip: '复制文案',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 32,
                  minHeight: 32,
                ),
              ),
              IconButton(
                icon: _isRegenerating
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh, size: 20),
                onPressed: _isRegenerating ? null : _regeneratePoetry,
                tooltip: '重新生成文案',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 32,
                  minHeight: 32,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _currentCard.poetry,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  height: 1.6,
                  color: Colors.grey.shade800,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  void _shareCard(BuildContext context) async {
    try {
      await Share.share(
        '我刚刚用AI诗意瞬间卡片生成器创作了一张卡片：\n\n"${_currentCard.poetry}"\n\n快来试试吧！',
        subject: '我的诗意瞬间',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('分享失败：$e')),
      );
    }
  }

  void _saveCard(BuildContext context) async {
    try {
      // 显示保存中提示
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              SizedBox(width: 16),
              Text('正在保存到相册...'),
            ],
          ),
          duration: Duration(seconds: 2),
        ),
      );

      // 保存卡片到相册
      final imageSaveService = ImageSaveService();
      final success = await imageSaveService.saveCardToGallery(_cardKey);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('卡片已保存到相册'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('保存失败，请检查相册权限'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('保存失败：$e')),
      );
    }
  }

  void _copyText(BuildContext context) {
    Clipboard.setData(ClipboardData(text: _currentCard.poetry));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('文案已复制到剪贴板')),
    );
  }

  void _regeneratePoetry() async {
    setState(() {
      _isRegenerating = true;
    });

    try {
      final cardGenerator = Provider.of<CardGenerator>(context, listen: false);
      final historyManager =
          Provider.of<HistoryManager>(context, listen: false);

      // 重新生成文案
      final newPoetry = await cardGenerator.regeneratePoetry(
        _currentCard.image,
        _currentCard.style,
      );

      // 创建更新后的卡片
      final updatedCard = _currentCard.copyWith(
        poetry: newPoetry,
        metadata: {
          ..._currentCard.metadata,
          'lastRegeneratedAt': DateTime.now().toIso8601String(),
        },
      );

      // 更新历史记录中的卡片
      await historyManager.addCard(updatedCard);

      // 更新当前显示的卡片
      setState(() {
        _currentCard = updatedCard;
      });

      // 显示成功提示
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('文案重新生成成功'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('重新生成失败：$e'),
            backgroundColor: Colors.red,
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

  void _deleteCard(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除卡片'),
        content: const Text('确定要删除这张卡片吗？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              final historyManager =
                  Provider.of<HistoryManager>(context, listen: false);
              historyManager.removeCard(_currentCard.id);
              Navigator.pop(context); // 关闭对话框
              Navigator.pop(context); // 返回上一页
            },
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  String _getStyleDisplayName(PoetryStyle style) {
    switch (style) {
      case PoetryStyle.modernPoetic:
        return '现代诗意';
      case PoetryStyle.classicalElegant:
        return '古风雅韵';
      case PoetryStyle.humorousPlayful:
        return '幽默俏皮';
      case PoetryStyle.warmLiterary:
        return '文艺暖心';
      case PoetryStyle.minimalTags:
        return '极简摘要';
      case PoetryStyle.sciFiImagination:
        return '科幻想象';
      case PoetryStyle.deepPhilosophical:
        return '深沉哲思';
      case PoetryStyle.blindBox:
        return '盲盒';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}年${dateTime.month}月${dateTime.day}日 ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
