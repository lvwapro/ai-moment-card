import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:excel/excel.dart';
import '../../providers/history_manager.dart';
import '../../utils/style_utils.dart';
import '../../services/language_service.dart';
import '../settings_card_widget.dart';

/// 数据管理部分
class DataSection extends StatelessWidget {
  const DataSection({super.key});

  @override
  Widget build(BuildContext context) => Consumer<HistoryManager>(
        builder: (context, historyManager, child) => SettingsCardWidget(
          title: context.l10n('数据管理'),
          children: [
            SettingItemWidget(
              icon: Icons.history,
              title: context.l10n('历史记录'),
              subtitle: context
                  .l10n('共 {0} 张卡片')
                  .replaceAll('{0}', historyManager.totalCount.toString()),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pushNamed(context, '/history');
              },
            ),
            SettingItemWidget(
              icon: Icons.download,
              title: context.l10n('导出数据'),
              subtitle: context.l10n('导出所有卡片数据'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _exportData(context, historyManager),
            ),
            SettingItemWidget(
              icon: Icons.delete_forever,
              title: context.l10n('清空历史'),
              subtitle: context.l10n('删除所有历史记录'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showClearHistoryDialog(context, historyManager),
            ),
          ],
        ),
      );

  void _showClearHistoryDialog(
    BuildContext context,
    HistoryManager historyManager,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n('清空历史记录')),
        content: Text(context.l10n('确定要清空所有历史记录吗？此操作不可撤销。')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n('取消')),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              historyManager.clearHistory();
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(context.l10n('历史记录已清空'))));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(context.l10n('清空')),
          ),
        ],
      ),
    );
  }

  /// 导出数据为Excel文件
  Future<void> _exportData(
    BuildContext context,
    HistoryManager historyManager,
  ) async {
    try {
      if (historyManager.totalCount == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n('没有可导出的数据'))),
        );
        return;
      }

      // 显示导出中提示
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n('正在准备导出数据...')),
          duration: const Duration(seconds: 2),
        ),
      );

      // 创建Excel文件
      final excel = Excel.createExcel();
      final sheet = excel['AI诗意卡片数据'];

      // 设置表头
      final headers = [
        '序号',
        '创建时间',
        '风格',
        '图片链接',
        '朋友圈文案',
        '小红书文案',
        '微博文案',
        '抖音文案',
        '诗句',
        '原诗标题',
        '原诗作者',
        '原诗朝代',
        '原诗内容',
      ];

      // 添加表头
      for (var i = 0; i < headers.length; i++) {
        final cell = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0),
        );
        cell.value = TextCellValue(headers[i]);
        cell.cellStyle = CellStyle(
          bold: true,
          fontSize: 12,
          horizontalAlign: HorizontalAlign.Center,
          verticalAlign: VerticalAlign.Center,
        );
      }

      // 获取所有卡片数据
      final cards = historyManager.cards;

      // 添加数据行
      for (var i = 0; i < cards.length; i++) {
        final card = cards[i];
        final rowIndex = i + 1;

        // 获取图片链接（优先云端链接，其次本地路径）
        String imageUrl = '';
        final cloudUrls = card.metadata['cloudImageUrls'] as List<dynamic>?;
        final localPaths = card.metadata['localImagePaths'] as List<dynamic>?;

        if (cloudUrls != null && cloudUrls.isNotEmpty) {
          imageUrl = cloudUrls.first.toString();
        } else if (localPaths != null && localPaths.isNotEmpty) {
          imageUrl = localPaths.first.toString();
        } else if (card.image.path.isNotEmpty) {
          imageUrl = card.image.path;
        }

        final rowData = [
          (i + 1).toString(), // 序号
          _formatDateTime(card.createdAt), // 创建时间
          StyleUtils.getStyleDisplayName(card.style), // 风格
          imageUrl, // 图片链接
          card.pengyouquan ?? '', // 朋友圈
          card.xiaohongshu ?? '', // 小红书
          card.weibo ?? '', // 微博
          card.douyin ?? '', // 抖音
          card.shiju ?? '', // 诗句
          card.title ?? '', // 原诗标题
          card.author ?? '', // 原诗作者
          card.time ?? '', // 原诗朝代
          card.content ?? '', // 原诗内容
        ];

        for (var j = 0; j < rowData.length; j++) {
          final cell = sheet.cell(
            CellIndex.indexByColumnRow(columnIndex: j, rowIndex: rowIndex),
          );
          cell.value = TextCellValue(rowData[j]);
        }
      }

      // 自动调整列宽
      for (var i = 0; i < headers.length; i++) {
        if (i == 3) {
          // 图片链接列设置更宽
          sheet.setColumnWidth(i, 40);
        } else if (i >= 4 && i <= 8) {
          // 文案列设置更宽
          sheet.setColumnWidth(i, 30);
        } else {
          sheet.setColumnWidth(i, 20);
        }
      }

      // 获取临时目录
      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${directory.path}/AI诗意卡片数据_$timestamp.xlsx');

      // 保存Excel文件
      final excelBytes = excel.encode();
      if (excelBytes != null) {
        await file.writeAsBytes(excelBytes);

        // 分享文件
        await Share.shareXFiles(
          [XFile(file.path)],
          subject: context.l10n('AI诗意卡片数据导出'),
          text: context
              .l10n('共导出 {0} 张卡片')
              .replaceAll('{0}', cards.length.toString()),
        );

        // 显示成功提示
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n('数据导出成功')),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(context.l10n('导出失败：{0}').replaceAll('{0}', e.toString())),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}年${dateTime.month}月${dateTime.day}日 ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
