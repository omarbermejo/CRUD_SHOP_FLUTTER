import 'package:flutter/material.dart';

/// Widget que muestra los criterios de contraseña y los marca en verde cuando se cumplen
class PasswordRequirements extends StatelessWidget {
  final String password;

  const PasswordRequirements({
    super.key,
    required this.password,
  });

  @override
  Widget build(BuildContext context) {
    if (password.isEmpty) {
      return const SizedBox.shrink();
    }

    final hasMinLength = password.length >= 6;
    final hasUpperCase = password.contains(RegExp(r'[A-Z]'));
    final hasLowerCase = password.contains(RegExp(r'[a-z]'));
    final hasNumber = password.contains(RegExp(r'[0-9]'));

    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _RequirementItem(
            text: 'Mínimo 6 caracteres',
            isMet: hasMinLength,
          ),
          const SizedBox(height: 4),
          _RequirementItem(
            text: 'Al menos una mayúscula',
            isMet: hasUpperCase,
          ),
          const SizedBox(height: 4),
          _RequirementItem(
            text: 'Al menos una minúscula',
            isMet: hasLowerCase,
          ),
          const SizedBox(height: 4),
          _RequirementItem(
            text: 'Al menos un número',
            isMet: hasNumber,
          ),
        ],
      ),
    );
  }
}

class _RequirementItem extends StatelessWidget {
  final String text;
  final bool isMet;

  const _RequirementItem({
    required this.text,
    required this.isMet,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          isMet ? Icons.check_circle : Icons.circle_outlined,
          size: 16,
          color: isMet ? Colors.green : Colors.grey,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: isMet ? Colors.green : Colors.grey,
            fontWeight: isMet ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}

