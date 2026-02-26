import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class NumericKeypad extends StatelessWidget {
  final Function(String) onKeyPressed;
  final VoidCallback onBackspace;

  const NumericKeypad({
    super.key,
    required this.onKeyPressed,
    required this.onBackspace,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: AppTheme.primaryColor.withValues(alpha: 0.1)),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildRow(['1', '2', '3']),
          const SizedBox(height: 8),
          _buildRow(['4', '5', '6']),
          const SizedBox(height: 8),
          _buildRow(['7', '8', '9']),
          const SizedBox(height: 8),
          _buildRow(['.', '0', 'backspace']),
        ],
      ),
    );
  }

  Widget _buildRow(List<String> keys) {
    return Row(
      children: keys.map((key) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: _buildKey(key),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildKey(String key) {
    final isBackspace = key == 'backspace';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (isBackspace) {
            onBackspace();
          } else {
            onKeyPressed(key);
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 56,
          alignment: Alignment.center,
          child: isBackspace
              ? Icon(
                  Icons.backspace_outlined,
                  size: 24,
                  color: AppTheme.textMuted,
                )
              : Text(
                  key,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textDark,
                  ),
                ),
        ),
      ),
    );
  }
}
