import 'network_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// VIP会员服务
class VipService {
  static final VipService _instance = VipService._internal();
  factory VipService() => _instance;
  VipService._internal();

  final NetworkService _networkService = NetworkService();

  static const String _vipStatusKey = 'vip_status';
  static const String _vipExpireTimeKey = 'vip_expire_time';

  /// 刷新会员状态（从服务器获取）
  Future<bool> refreshVipStatus() async {
    try {
      print('开始刷新会员状态...');

      final response = await _networkService.get('/api/user/vip/status');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final isVip = data['isVip'] as bool? ?? false;
        final expireTime = data['expireTime'] as String?;

        // 保存到本地
        await _saveVipStatus(isVip, expireTime);

        print('会员状态刷新成功: isVip=$isVip, expireTime=$expireTime');
        return isVip;
      } else {
        print('会员状态刷新失败: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('会员状态刷新异常: $e');
      return false;
    }
  }

  /// 保存会员状态到本地
  Future<void> _saveVipStatus(bool isVip, String? expireTime) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_vipStatusKey, isVip);
      if (expireTime != null) {
        await prefs.setString(_vipExpireTimeKey, expireTime);
      }
      print('会员状态已保存到本地');
    } catch (e) {
      print('保存会员状态失败: $e');
    }
  }

  /// 获取本地保存的会员状态
  Future<bool> getLocalVipStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_vipStatusKey) ?? false;
    } catch (e) {
      print('获取本地会员状态失败: $e');
      return false;
    }
  }

  /// 获取会员到期时间
  Future<String?> getVipExpireTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_vipExpireTimeKey);
    } catch (e) {
      print('获取会员到期时间失败: $e');
      return null;
    }
  }

  /// 清除会员状态
  Future<void> clearVipStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_vipStatusKey);
      await prefs.remove(_vipExpireTimeKey);
      print('会员状态已清除');
    } catch (e) {
      print('清除会员状态失败: $e');
    }
  }
}
