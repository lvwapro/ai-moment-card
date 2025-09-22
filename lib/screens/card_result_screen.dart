import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:ai_poetry_card/models/poetry_card.dart';
import 'package:ai_poetry_card/widgets/poetry_card_widget.dart';
import 'package:ai_poetry_card/providers/history_manager.dart';
import 'package:ai_poetry_card/services/image_save_service.dart';
import 'package:provider/provider.dart';

class CardResultScreen extends StatefulWidget {
  final PoetryCard card;

  const CardResultScreen({
    super.key,
    required this.card,
  });

  @override
  State<CardResultScreen> createState() => _CardResultScreenState();
}

class _CardResultScreenState extends State<CardResultScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  final GlobalKey _cardKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
    ));

    _animationController.forward();

    // 保存到历史记录
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HistoryManager>(context, listen: false).addCard(widget.card);
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('生成完成'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareCard,
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _saveCard,
          ),
        ],
      ),
      body: Column(
        children: [
          // 成功提示
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.green.shade600,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '卡片生成成功！',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.green.shade800,
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                      Text(
                        'AI为你的瞬间配上了诗意的文字',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.green.shade700,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 卡片展示
          Expanded(
            child: Center(
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: RepaintBoundary(
                        key: _cardKey,
                        child: PoetryCardWidget(
                          card: widget.card,
                          showControls: false,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // 底部操作按钮
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _shareCard,
                        icon: const Icon(Icons.share),
                        label: const Text('分享'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _saveCard,
                        icon: const Icon(Icons.download),
                        label: const Text('保存'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                    onPressed: _createAnother,
                    icon: const Icon(Icons.add),
                    label: const Text('再创作一张'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _shareCard() async {
    try {
      // 这里应该生成卡片的图片文件然后分享
      // 暂时显示分享选项
      await Share.share(
        '我刚刚用AI诗意瞬间卡片生成器创作了一张卡片：\n\n"${widget.card.poetry}"\n\n快来试试吧！',
        subject: '我的诗意瞬间',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('分享失败：$e')),
      );
    }
  }

  void _saveCard() async {
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

  void _createAnother() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/',
      (route) => false,
    );
  }
}
