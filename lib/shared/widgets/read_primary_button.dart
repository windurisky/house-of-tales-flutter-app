import 'package:flutter/material.dart';

class ReadPrimaryButton extends StatelessWidget {
  const ReadPrimaryButton({
    required this.label,
    required this.onPressed,
    this.icon = Icons.menu_book_rounded,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
      ),
    );
  }
}
