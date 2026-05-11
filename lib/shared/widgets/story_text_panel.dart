import 'package:flutter/material.dart';

import '../../core/theme/app_tokens.dart';

class StoryTextPanel extends StatelessWidget {
  const StoryTextPanel({required this.text, this.partial = false, super.key});

  final String text;
  final bool partial;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyLarge?.copyWith(
      color: AppColors.textReader,
      fontSize: 18,
      height: 1.62,
    );
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.bgReaderPaper,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Text(partial ? '$text\n\n…' : text, style: style),
    );
  }
}
