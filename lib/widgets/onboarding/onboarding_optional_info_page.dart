import 'package:flutter/material.dart';

class OnboardingOptionalInfoPage extends StatelessWidget {
  final String? occupation;
  final String? location;
  final Function(String) onOccupationChanged;
  final Function(String) onLocationChanged;

  const OnboardingOptionalInfoPage({
    super.key,
    required this.occupation,
    required this.location,
    required this.onOccupationChanged,
    required this.onLocationChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '其他信息（可选）',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            '这些信息将帮助我们生成更精准的文案',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: Column(
              children: [
                _buildTextField(
                  context: context,
                  label: '职业',
                  hint: '例如：设计师、教师、程序员',
                  value: occupation,
                  onChanged: onOccupationChanged,
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  context: context,
                  label: '所在地区',
                  hint: '例如：北京、上海、深圳',
                  value: location,
                  onChanged: onLocationChanged,
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.blue.shade600,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '这些信息是可选的，您可以随时跳过',
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required BuildContext context,
    required String label,
    required String hint,
    required String? value,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        TextField(
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Theme.of(context).primaryColor),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }
}
