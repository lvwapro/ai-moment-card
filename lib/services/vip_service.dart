import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'network_service.dart';

/// VIP状态类型
enum SubscriptionType {
  free,
  premium,
}

/// VIP订阅状态
class SubscriptionStatus {
  factory SubscriptionStatus.fromJson(Map<String, dynamic> json) =>
      SubscriptionStatus(
        type: json['type'] == 'SubscriptionType.premium'
            ? SubscriptionType.premium
            : SubscriptionType.free,
        expiryDate: json['expiryDate'] != null
            ? DateTime.fromMillisecondsSinceEpoch(json['expiryDate'])
            : null,
        isActive: json['isActive'] ?? false,
      );
  final SubscriptionType type;
  final DateTime? expiryDate;
  final bool isActive;

  SubscriptionStatus({
    required this.type,
    this.expiryDate,
    required this.isActive,
  });

  bool get isPremium => type == SubscriptionType.premium && isActive;
  bool get isExpired =>
      expiryDate != null && expiryDate!.isBefore(DateTime.now());

  Map<String, dynamic> toJson() => {
        'type': type.toString(),
        'expiryDate': expiryDate?.millisecondsSinceEpoch,
        'isActive': isActive,
      };
}

/// VIP会员服务
class VipService {
  static final VipService _instance = VipService._internal();
  factory VipService() => _instance;
  VipService._internal();

  final NetworkService _networkService = NetworkService();

  /// 从后端API获取VIP状态（包括白名单状态）
  Future<SubscriptionStatus?> getVipStatusFromAPI() async {
    try {
      final response = await _networkService.get('/api/user/vip/status');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;

        // 转换为SubscriptionStatus对象
        final status = SubscriptionStatus(
          type: data['isPremium']
              ? SubscriptionType.premium
              : SubscriptionType.free,
          expiryDate: data['expiryDate'] != null
              ? DateTime.fromMillisecondsSinceEpoch(data['expiryDate'])
              : null,
          isActive: data['isActive'] ?? false,
        );

        // 保存到本地存储
        await saveVipStatus(status);

        return status;
      } else {
        print('获取VIP状态失败: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('获取VIP状态异常: $e');
      return null;
    }
  }

  /// 保存VIP状态到本地存储
  Future<void> saveVipStatus(SubscriptionStatus status) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final statusJson = jsonEncode(status.toJson());
      await prefs.setString('vip_status', statusJson);
    } catch (e) {
      print('保存VIP状态失败: $e');
    }
  }

  /// 从本地存储获取VIP状态
  Future<SubscriptionStatus?> getVipStatusFromLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final statusJson = prefs.getString('vip_status');

      if (statusJson != null) {
        final data = jsonDecode(statusJson);
        return SubscriptionStatus.fromJson(data);
      }

      return null;
    } catch (e) {
      print('获取本地VIP状态失败: $e');
      return null;
    }
  }

  /// 刷新VIP状态（从API获取最新状态）
  Future<SubscriptionStatus?> refreshVipStatus() async {
    try {
      print('开始刷新会员状态...');

      // 从API获取最新状态
      final apiStatus = await getVipStatusFromAPI();

      if (apiStatus != null) {
        print('会员状态刷新成功: isPremium=${apiStatus.isPremium}');
        return apiStatus;
      }

      // 如果API获取失败，返回本地状态
      print('API获取失败，使用本地状态');
      return await getVipStatusFromLocal();
    } catch (e) {
      print('刷新VIP状态失败: $e');
      return await getVipStatusFromLocal();
    }
  }
}
