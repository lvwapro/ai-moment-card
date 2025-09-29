import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/poetry_card.dart';
import '../providers/card_generator.dart';
import '../utils/localization_extension.dart';
import '../utils/style_utils.dart';

/// 卡片信息展示组件
class CardInfoWidget extends StatefulWidget {
  final PoetryCard card;
  final Function(PoetryCard)? onPoetryUpdated;

  const CardInfoWidget({
    super.key,
    required this.card,
    this.onPoetryUpdated,
  });

  @override
  State<CardInfoWidget> createState() => _CardInfoWidgetState();
}

class _CardInfoWidgetState extends State<CardInfoWidget> {
  bool _isRegenerating = false;

  @override
  Widget build(BuildContext context) => Container(
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
              context.l10n('卡片信息'),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
            ),
            const SizedBox(height: 16),
            _buildPoetrySection(),
            const SizedBox(height: 16),
            _buildInfoRow(context.l10n('风格'),
                StyleUtils.getStyleDisplayName(context, widget.card.style)),
            _buildInfoRow(
                context.l10n('创建时间'), _formatDateTime(widget.card.createdAt)),
          ],
        ),
      );

  Widget _buildPoetrySection() => Container(
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
                  context.l10n('文案'),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.copy, size: 20),
                  onPressed: () => _copyText(context),
                  tooltip: context.l10n('复制文案'),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                  color: Theme.of(context).primaryColor,
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
                  tooltip: context.l10n('重新生成文案'),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                  color: Theme.of(context).primaryColor,
                ),
              ],
            ),
            Text(
              widget.card.poetry,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    height: 1.6,
                    color: Theme.of(context).primaryColor,
                  ),
            ),
          ],
        ),
      );

  Widget _buildInfoRow(String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 80,
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ),
            Expanded(
              child: Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).primaryColor,
                    ),
              ),
            ),
          ],
        ),
      );

  void _copyText(BuildContext context) {
    Clipboard.setData(ClipboardData(text: widget.card.poetry));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n('文案已复制到剪贴板'))),
    );
  }

  void _regeneratePoetry() async {
    setState(() {
      _isRegenerating = true;
    });

    try {
      final cardGenerator = Provider.of<CardGenerator>(context, listen: false);

      // 重新生成文案
      final newPoetry = await cardGenerator.regeneratePoetry(
        widget.card.image,
        widget.card.style,
      );

      // 创建更新后的卡片
      final updatedCard = widget.card.copyWith(
        poetry: newPoetry,
        metadata: {
          ...widget.card.metadata,
          'lastRegeneratedAt': DateTime.now().toIso8601String(),
        },
      );

      // 通知父组件更新
      if (widget.onPoetryUpdated != null) {
        widget.onPoetryUpdated!(updatedCard);
      }

      // 显示成功提示
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n('文案重新生成成功')),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n('重新生成失败：$e')),
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

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}年${dateTime.month}月${dateTime.day}日 ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
