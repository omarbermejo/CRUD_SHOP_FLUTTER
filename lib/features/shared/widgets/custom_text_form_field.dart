import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:teslo_shop/config/theme/app_theme.dart';

class CustomTextFormField extends StatelessWidget {
  final String? label;
  final String? hint;
  final String? errorMessage;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Function(String)? onChanged;
  final String? Function(String?)? validator;

  const CustomTextFormField({
    super.key,
    this.label,
    this.hint,
    this.errorMessage,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors =
        isDark ? AppColorsExtension.darkColors : AppColorsExtension.lightColors;
    final fontSize = ResponsiveHelper.responsiveFontSize(context,
        baseSize: 16, minSize: 14, maxSize: 18);

    if (PlatformHelper.isIOS) {
      // iOS: Input estilo Cupertino
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: colors['surface'],
          borderRadius: BorderRadius.circular(10),
        ),
        child: CupertinoTextField(
          placeholder: hint ?? label,
          obscureText: obscureText,
          keyboardType: keyboardType,
          onChanged: onChanged,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: colors['surface'],
            borderRadius: BorderRadius.circular(10),
            border: errorMessage != null
                ? Border.all(color: colors['error']!, width: 1)
                : Border.all(color: colors['border']!, width: 1),
          ),
          style: TextStyle(
            fontSize: fontSize,
            color: colors['text'],
            letterSpacing: -0.41,
          ),
          placeholderStyle: TextStyle(
            color: colors['textSecondary'],
            fontSize: fontSize,
          ),
        ),
      );
    } else {
      // Android: Input Material
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: colors['surface'],
          borderRadius: BorderRadius.circular(12),
          border: errorMessage != null
              ? Border.all(color: colors['error']!, width: 1)
              : Border.all(color: colors['border']!, width: 1),
        ),
        child: TextFormField(
          onChanged: onChanged,
          validator: validator,
          obscureText: obscureText,
          keyboardType: keyboardType,
          style: TextStyle(
            fontSize: fontSize,
            color: colors['text'],
          ),
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            errorText: errorMessage,
            filled: true,
            fillColor: colors['surface'],
            labelStyle: TextStyle(color: colors['textSecondary']),
            hintStyle: TextStyle(color: colors['textSecondary']),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colors['border']!, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colors['primary']!, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colors['error']!, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colors['error']!, width: 2),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      );
    }
  }
}
