import 'package:fl_umeng/fl_umeng.dart';

/// 友盟统计服务
class UmengService {
  static final FlUMeng _umeng = FlUMeng();
  static bool _initialized = false;

  /// 初始化友盟统计
  static Future<bool> init() async {
    if (_initialized) {
      return true;
    }

    try {
      final result = await _umeng.init(
        androidAppKey: '6909ad6f8560e34872debb3f',
        iosAppKey: '6909ad8a8560e34872debb58',
        channel: 'default',
      );

      if (result == true) {
        _initialized = true;
        print('友盟统计初始化成功');
        return true;
      } else {
        print('友盟统计初始化失败');
        return false;
      }
    } catch (e) {
      print('友盟统计初始化异常: $e');
      return false;
    }
  }

  /// 记录页面开始（用于统计DAU）
  static void onPageStart(String pageName) {
    if (!_initialized) return;
    try {
      _umeng.onPageStart(pageName);
    } catch (e) {
      print('友盟记录页面开始失败: $e');
    }
  }

  /// 记录页面结束
  static void onPageEnd(String pageName) {
    if (!_initialized) return;
    try {
      _umeng.onPageEnd(pageName);
    } catch (e) {
      print('友盟记录页面结束失败: $e');
    }
  }

  /// 记录应用启动（用于统计DAU）
  /// 注意：友盟SDK会自动统计应用启动和会话，此方法主要用于确保初始化完成
  static void onAppStart() {
    if (!_initialized) return;
    // 友盟SDK会自动统计应用启动和会话，无需手动调用
    // DAU统计会在应用启动时自动进行
  }
}

