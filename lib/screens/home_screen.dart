import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/poetry_card.dart';
import '../providers/app_state.dart';
import '../providers/card_generator.dart';
import '../providers/history_manager.dart';
import '../theme/app_theme.dart';
import '../utils/localization_extension.dart';
import '../widgets/enhanced_image_selection_widget.dart';
import '../widgets/description_input_widget.dart';
import '../widgets/style_selector_widget.dart';
import '../widgets/generate_button_widget.dart';
import 'card_detail_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';

// hct
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<String> _uploadedUrls = []; // 已上传的图片 URL 列表
  List<String> _localImagePaths = []; // 本地图片路径列表
  bool _isGenerating = false;
  final TextEditingController _descriptionController = TextEditingController();
  String _description = '';

  @override
  void initState() {
    super.initState();
    _descriptionController.addListener(() {
      setState(() {
        _description = _descriptionController.text;
      });
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  /// 统一的数据变化回调
  void _onDataChanged(List<String> cloudUrls, List<String> localPaths) {
    setState(() {
      _uploadedUrls = cloudUrls;
      _localImagePaths = localPaths;
    });
    print('🔄 数据更新:');
    print('🔄 云端URLs: $cloudUrls');
    print('🔄 本地路径: $localPaths');
  }

  /// 图片上传失败回调
  void _onUploadFailed(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${context.l10n('图片上传失败')}: $error'),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _generateCard() async {
    final cardGenerator = Provider.of<CardGenerator>(context, listen: false);
    final appState = Provider.of<AppState>(context, listen: false);

    setState(() {
      _isGenerating = true;
    });

    try {
      PoetryCard card;

      // 使用已上传的图片URL生成卡片
      if (_uploadedUrls.isNotEmpty) {
        // TODO: 修改cardGenerator支持URL参数
        // 目前暂时使用默认图片，后续需要修改AI服务支持URL
        card = await cardGenerator.generateCard(
          File(''), // 临时使用空文件，后续需要修改
          appState.selectedStyle,
          userDescription: _description.isNotEmpty ? _description : null,
          localImagePaths: _localImagePaths,
          cloudImageUrls: _uploadedUrls,
        );
        print('localImagePaths: $_localImagePaths');
        print('cloudImageUrls: $_uploadedUrls');
      } else {
        throw Exception('请先选择并上传图片');
      }

      // 保存卡片到历史记录
      final historyManager = Provider.of<HistoryManager>(
        context,
        listen: false,
      );
      await historyManager.addCard(card);

      // 增加使用次数
      await appState.incrementUsage();

      // 跳转到结果页面
      if (mounted) {
        await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  CardDetailScreen(card: card, isResultMode: true)),
        );
        // 生成卡片后清空图片数组
        setState(() {
          _uploadedUrls.clear();
          _localImagePaths.clear();
        });
        print('🧹 生成卡片后清空图片数组');
        print('🧹 清空后的localImagePaths: $_localImagePaths');
        print('🧹 清空后的cloudImageUrls: $_uploadedUrls');
      }
    } catch (e) {
      // 显示错误信息
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.l10n('生成失败：$e'))));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: _buildAppBar(context),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              EnhancedImageSelectionWidget(
                onDataChanged: _onDataChanged,
                onUploadFailed: _onUploadFailed,
              ),
              const SizedBox(height: 24),
              DescriptionInputWidget(
                controller: _descriptionController,
                description: _description,
                onClear: () => _descriptionController.clear(),
              ),
              const SizedBox(height: 24),
              const StyleSelectorWidget(),
              const SizedBox(height: 24),
              GenerateButtonWidget(
                isGenerating: _isGenerating,
                hasImages: _uploadedUrls.isNotEmpty,
                onPressed: _generateCard,
              ),
              const SizedBox(height: 16),
              _buildHintText(context),
            ],
          ),
        ),
      );

  AppBar _buildAppBar(BuildContext context) => AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          context.l10n('瞬间文案'),
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.history, color: Theme.of(context).primaryColor),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HistoryScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.settings, color: Theme.of(context).primaryColor),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      );

  Widget _buildHintText(BuildContext context) => Text(
        context.l10n('AI将根据你的图片和选择的风格，生成独特的文案'),
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary),
        textAlign: TextAlign.center,
      );
}
