import 'package:dio/dio.dart';
import 'network_service.dart';

class InviteService {
  static final NetworkService _networkService = NetworkService();

  /// 兑换邀请码
  /// 返回 true 表示兑换成功
  static Future<bool> redeemInviteCode(String inviteCode) async {
    try {
      final response = await _networkService.post(
        '/api/invite/redeem',
        data: {'inviteCode': inviteCode},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
      return false;
    } catch (e) {
      print('兑换邀请码失败: $e');
      if (e is DioException) {
        // 可以根据需要抛出具体错误信息
        if (e.response != null && e.response!.data != null) {
          // 如果后端返回具体错误消息，可以在这里处理
          print('后端错误: ${e.response!.data}');
        }
      }
      rethrow;
    }
  }
}
