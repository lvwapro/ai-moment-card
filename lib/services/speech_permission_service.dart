import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechPermissionService {
  static final SpeechPermissionService _instance =
      SpeechPermissionService._internal();
  factory SpeechPermissionService() => _instance;
  SpeechPermissionService._internal();

  /// 检查语音识别权限
  Future<bool> checkSpeechPermission() async {
    try {
      // 检查麦克风权限
      var microphoneStatus = await Permission.microphone.status;
      if (!microphoneStatus.isGranted) {
        microphoneStatus = await Permission.microphone.request();
      }

      // 检查语音识别权限
      var speechStatus = await Permission.speech.status;
      if (!speechStatus.isGranted) {
        speechStatus = await Permission.speech.request();
      }

      return microphoneStatus.isGranted && speechStatus.isGranted;
    } catch (e) {
      print('检查语音权限异常: $e');
      return false;
    }
  }

  /// 请求语音识别权限
  Future<bool> requestSpeechPermission() async {
    try {
      // 请求麦克风权限
      var microphoneStatus = await Permission.microphone.request();

      // 请求语音识别权限
      var speechStatus = await Permission.speech.request();

      return microphoneStatus.isGranted && speechStatus.isGranted;
    } catch (e) {
      print('请求语音权限异常: $e');
      return false;
    }
  }

  /// 检查语音识别是否可用
  Future<bool> isSpeechAvailable() async {
    try {
      final speech = stt.SpeechToText();
      return await speech.initialize();
    } catch (e) {
      print('检查语音识别可用性异常: $e');
      return false;
    }
  }

  /// 打开应用设置页面
  Future<void> openAppSettingsPage() async {
    try {
      await openAppSettings();
    } catch (e) {
      print('打开设置页面失败: $e');
    }
  }

  /// 获取权限状态描述
  Future<String> getPermissionStatus() async {
    try {
      final microphoneStatus = await Permission.microphone.status;
      final speechStatus = await Permission.speech.status;

      if (microphoneStatus.isGranted && speechStatus.isGranted) {
        return '已授权';
      } else if (microphoneStatus.isDenied || speechStatus.isDenied) {
        return '未授权';
      } else if (microphoneStatus.isPermanentlyDenied ||
          speechStatus.isPermanentlyDenied) {
        return '永久拒绝';
      } else {
        return '未知状态';
      }
    } catch (e) {
      return '检查失败';
    }
  }
}
