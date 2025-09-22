import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../providers/app_state.dart';
import '../providers/card_generator.dart';
import '../providers/history_manager.dart';
import '../services/speech_permission_service.dart';
import '../theme/app_theme.dart';
import '../widgets/image_selection_widget.dart';
import '../widgets/description_input_widget.dart';
import '../widgets/style_selector_widget.dart';
import '../widgets/generate_button_widget.dart';
import 'card_result_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<File> _selectedImages = [];
  bool _isGenerating = false;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _descriptionController = TextEditingController();
  stt.SpeechToText? _speech;
  bool _isListening = false;
  String _description = '';

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
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

  void _pickImage() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (images.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(images.map((image) => File(image.path)));
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('选择图片失败：$e')));
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _startListening() async {
    try {
      // 检查权限
      final permissionService = SpeechPermissionService();
      bool hasPermission = await permissionService.checkSpeechPermission();

      if (!hasPermission) {
        hasPermission = await permissionService.requestSpeechPermission();
        if (!hasPermission) {
          // 显示带操作按钮的提示
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('需要语音识别权限'),
              duration: const Duration(seconds: 5),
              action: SnackBarAction(
                label: '去设置',
                textColor: Colors.white,
                onPressed: () async {
                  await permissionService.openAppSettingsPage();
                },
              ),
            ),
          );
          return;
        }
      }

      // 检查语音识别是否可用
      bool isAvailable = await permissionService.isSpeechAvailable();
      if (!isAvailable) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('语音识别服务不可用'),
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: '去设置',
              textColor: Colors.white,
              onPressed: () async {
                await permissionService.openAppSettingsPage();
              },
            ),
          ),
        );
        return;
      }

      if (_speech == null) {
        _speech = stt.SpeechToText();
      }

      bool available = await _speech!.initialize(
        onError: (error) {
          print('语音识别错误: $error');
          setState(() {
            _isListening = false;
          });
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('语音识别错误: ${error.errorMsg}')));
        },
        onStatus: (status) {
          print('语音识别状态: $status');
          if (status == 'done' || status == 'notListening') {
            setState(() {
              _isListening = false;
            });
          }
        },
      );

      if (available) {
        setState(() {
          _isListening = true;
        });

        await _speech!.listen(
          onResult: (result) {
            setState(() {
              _description = result.recognizedWords;
              _descriptionController.text = _description;
            });
          },
          listenFor: const Duration(seconds: 30),
          pauseFor: const Duration(seconds: 3),
          partialResults: true,
          localeId: 'zh_CN',
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('语音识别初始化失败')));
      }
    } catch (e) {
      print('语音识别异常: $e');
      setState(() {
        _isListening = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('语音识别失败: $e')));
    }
  }

  void _stopListening() {
    try {
      if (_speech != null) {
        _speech!.stop();
        setState(() {
          _isListening = false;
        });
      }
    } catch (e) {
      print('停止语音识别异常: $e');
      setState(() {
        _isListening = false;
      });
    }
  }

  void _generateCard() async {
    if (_selectedImages.isEmpty) {
      _pickImage();
      return;
    }

    final cardGenerator = Provider.of<CardGenerator>(context, listen: false);
    final appState = Provider.of<AppState>(context, listen: false);

    setState(() {
      _isGenerating = true;
    });

    try {
      // 使用第一张图片生成卡片
      final card = await cardGenerator.generateCard(
        _selectedImages.first,
        appState.selectedStyle,
        userDescription: _description.isNotEmpty ? _description : null,
      );

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
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CardResultScreen(card: card)),
        );
      }
    } catch (e) {
      // 显示错误信息
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('生成失败：$e')));
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
          ImageSelectionWidget(
            selectedImages: _selectedImages,
            onPickImage: _pickImage,
            onRemoveImage: _removeImage,
          ),
          const SizedBox(height: 24),
          DescriptionInputWidget(
            controller: _descriptionController,
            description: _description,
            isListening: _isListening,
            onStartListening: _startListening,
            onStopListening: _stopListening,
            onClear: () => _descriptionController.clear(),
          ),
          const SizedBox(height: 24),
          const StyleSelectorWidget(),
          const SizedBox(height: 24),
          GenerateButtonWidget(
            isGenerating: _isGenerating,
            onPressed: _generateCard,
          ),
          const SizedBox(height: 16),
          _buildHintText(context),
        ],
      ),
    ),
  );

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Text(
        '诗意瞬间',
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
  }

  Widget _buildHintText(BuildContext context) {
    return Text(
      'AI将根据你的图片和选择的风格，生成独特的诗意文案',
      style: Theme.of(
        context,
      ).textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary),
      textAlign: TextAlign.center,
    );
  }
}
