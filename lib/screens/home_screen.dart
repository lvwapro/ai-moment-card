import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/poetry_card.dart';
import '../models/nearby_place.dart';
import '../providers/app_state.dart';
import '../providers/card_generator.dart';
import '../providers/history_manager.dart';
import '../theme/app_theme.dart';
import 'package:ai_poetry_card/services/language_service.dart';
import '../services/mood_tag_service.dart';
import '../services/location_service.dart';
import '../widgets/enhanced_image_selection_widget.dart';
import '../widgets/description_input_widget.dart';
import '../widgets/mood_tag_selector_widget.dart';
import '../widgets/generate_button_widget.dart';
import '../widgets/loading_overlay.dart';
import '../widgets/place_selector_widget.dart';
import 'card_detail_screen.dart';

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

  // 地址相关状态
  List<NearbyPlace> _nearbyPlaces = []; // 附近地点列表
  NearbyPlace? _selectedPlace; // 选中的地点
  bool _isLoadingPlaces = false; // 是否正在加载地点
  bool _placesError = false; // 地点加载是否出错

  // 情绪标签相关状态
  List<String> _moodTags = []; // 情绪标签列表
  bool _isLoadingMoodTags = false; // 是否正在加载情绪标签
  bool _moodTagsError = false; // 情绪标签加载是否出错

  @override
  void initState() {
    super.initState();
    _descriptionController.addListener(() {
      setState(() {
        _description = _descriptionController.text;
      });
    });
    // 加载附近地点和情绪标签
    _loadNearbyPlaces();
    _loadMoodTags();
  }

  /// 加载附近地点
  Future<void> _loadNearbyPlaces() async {
    setState(() {
      _isLoadingPlaces = true;
      _placesError = false;
    });

    try {
      final cardGenerator = Provider.of<CardGenerator>(context, listen: false);
      final places = await cardGenerator.fetchNearbyPlaces();

      if (mounted) {
        setState(() {
          if (places != null && places.isNotEmpty) {
            _nearbyPlaces = places;
            _placesError = false;
          } else {
            _nearbyPlaces = [];
            _placesError = true;
          }
          _isLoadingPlaces = false;
        });
      }
    } catch (e) {
      print('❌ 加载附近地点失败: $e');
      if (mounted) {
        setState(() {
          _nearbyPlaces = [];
          _placesError = true;
          _isLoadingPlaces = false;
        });
      }
    }
  }

  /// 加载情绪标签
  Future<void> _loadMoodTags() async {
    setState(() {
      _isLoadingMoodTags = true;
      _moodTagsError = false;
    });

    // 开始重新加载时，清除当前选中的标签
    final appState = Provider.of<AppState>(context, listen: false);
    appState.setSelectedMoodTags([]);

    try {
      // 获取当前位置
      final locationService = LocationService();
      final location = await locationService.getCurrentLocation();

      if (location != null) {
        // 调用 mood tags API
        final moodTagService = MoodTagService();
        final response = await moodTagService.getMoodTags(
          longitude: location.longitude,
          latitude: location.latitude,
        );

        if (mounted) {
          setState(() {
            if (response != null && response.moodTags.isNotEmpty) {
              _moodTags = response.moodTags;
              _moodTagsError = false;
            } else {
              _moodTags = [];
              _moodTagsError = true;
            }
            _isLoadingMoodTags = false;
          });
        }
      } else {
        // 获取位置失败
        if (mounted) {
          setState(() {
            _moodTags = [];
            _moodTagsError = true;
            _isLoadingMoodTags = false;
          });
        }
      }
    } catch (e) {
      print('❌ 加载情绪标签失败: $e');
      if (mounted) {
        setState(() {
          _moodTags = [];
          _moodTagsError = true;
          _isLoadingMoodTags = false;
        });
      }
    }
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
          PoetryStyle.blindBox, // 使用默认盲盒风格
          userDescription: _description.isNotEmpty ? _description : null,
          localImagePaths: _localImagePaths,
          cloudImageUrls: _uploadedUrls,
          selectedPlace: _selectedPlace, // 传递选中的地点
          moodTag: appState.selectedMoodTags.isNotEmpty
              ? appState.selectedMoodTags.join(',')
              : null, // 传递选中的情绪标签（逗号分隔）
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
        // 生成卡片后清空图片数组和重置选择状态
        setState(() {
          _uploadedUrls.clear();
          _localImagePaths.clear();
          _selectedPlace = null; // 重置位置选择
          _description = ''; // 重置描述
        });
        // 重置氛围标签选择
        appState.setSelectedMoodTags([]);
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
        body: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                  16.0, 16.0, 16.0, 100.0), // 底部留100空间给导航栏
              child: Column(
                children: [
                  EnhancedImageSelectionWidget(
                    onDataChanged: _onDataChanged,
                    onUploadFailed: _onUploadFailed,
                  ),
                  const SizedBox(height: 24),
                  MoodTagSelectorWidget(
                    moodTags: _moodTags,
                    isLoading: _isLoadingMoodTags,
                    hasError: _moodTagsError,
                    onRetry: _loadMoodTags,
                  ),
                  const SizedBox(height: 24),
                  // 地址选择组件
                  PlaceSelectorWidget(
                    places: _nearbyPlaces,
                    selectedPlace: _selectedPlace,
                    onPlaceSelected: (place) {
                      setState(() {
                        _selectedPlace = place;
                      });
                    },
                    isLoading: _isLoadingPlaces,
                    hasError: _placesError,
                    onRetry: _loadNearbyPlaces,
                  ),
                  const SizedBox(height: 16),
                  DescriptionInputWidget(
                    controller: _descriptionController,
                    description: _description,
                    onClear: () => _descriptionController.clear(),
                  ),
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
            // 全屏loading动画
            if (_isGenerating) const LoadingOverlay(),
          ],
        ),
      );

  AppBar _buildAppBar(BuildContext context) => AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(
          context.l10n('瞬间文案'),
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      );

  Widget _buildHintText(BuildContext context) => Text(
        context.l10n('AI将根据你的图片和选择的风格，生成独特的文案'),
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary),
        textAlign: TextAlign.center,
      );
}
