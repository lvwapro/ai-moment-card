import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// 手机状态栏组件
/// 显示时间、信号、电量等手机状态
class PhoneStatusBar extends StatelessWidget {
  /// 文字和图标的颜色（默认白色）
  final Color textColor;

  const PhoneStatusBar({
    super.key,
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final timeString = DateFormat('HH:mm').format(now);

    return Container(
      height: 44, // iPhone 状态栏高度
      padding:
          const EdgeInsets.only(left: 32, right: 26), // 右侧减小padding，让右侧图标整体往右移
      // 完全透明，与图片背景融为一体
      color: Colors.transparent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 时间显示（左侧）
          Text(
            timeString,
            style: TextStyle(
              fontSize: 15,
              color: textColor,
              fontWeight: FontWeight.bold,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),

          // 刘海区域占位
          const Spacer(),

          // 右侧状态图标
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 信号强度
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildSignalBar(6),
                  const SizedBox(width: 2),
                  _buildSignalBar(8),
                  const SizedBox(width: 2),
                  _buildSignalBar(10),
                  const SizedBox(width: 2),
                  _buildSignalBar(12),
                ],
              ),

              const SizedBox(width: 4),

              // 5G 标识
              Text(
                '5G',
                style: TextStyle(
                  fontSize: 12,
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(width: 4),

              // 电池电量
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 电池图标
                  Container(
                    width: 20, // 从24改为20，减小宽度
                    height: 11,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: textColor,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(1.5),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: 0.85, // 85% 电量
                        child: Container(
                          decoration: BoxDecoration(
                            color: textColor,
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // 电池头
                  Container(
                    width: 2,
                    height: 4,
                    decoration: BoxDecoration(
                      color: textColor,
                      borderRadius: const BorderRadius.horizontal(
                        right: Radius.circular(1),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建单个信号条
  Widget _buildSignalBar(double height) {
    return Container(
      width: 3,
      height: height,
      decoration: BoxDecoration(
        color: textColor,
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }
}
