import 'package:flutter/material.dart';
import 'package:new_design_demo/core/constants/app_text_styles.dart';

class CommonButton extends StatelessWidget {
  final double width;
  final double height;
  final Color color;
  final String label;
  final VoidCallback onPressed;
  final Color? textColor;
  final Icon? icon;

  const CommonButton({
    super.key,
    required this.width,
    required this.height,
    required this.color,
    required this.label,
    required this.onPressed,
    this.textColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor:
              textColor ?? theme.colorScheme.onPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              icon!,
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.buttonText.copyWith(
                  color: textColor ??
                      theme.colorScheme.onPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}