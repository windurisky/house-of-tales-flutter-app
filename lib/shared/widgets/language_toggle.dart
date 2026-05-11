import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/theme/app_tokens.dart';
import '../models/ui_language.dart';

class LanguageToggle extends ConsumerWidget {
  const LanguageToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(uiLanguageProvider);
    return SegmentedButton<UiLanguage>(
      showSelectedIcon: false,
      segments: UiLanguage.values
          .map(
            (value) => ButtonSegment<UiLanguage>(
              value: value,
              label: Text(value.label),
            ),
          )
          .toList(),
      selected: {language},
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? AppColors.brandSoft
              : AppColors.surfaceCard;
        }),
        foregroundColor: const WidgetStatePropertyAll(AppColors.brandPrimary),
      ),
      onSelectionChanged: (selection) {
        ref.read(uiLanguageProvider.notifier).state = selection.first;
      },
    );
  }
}
