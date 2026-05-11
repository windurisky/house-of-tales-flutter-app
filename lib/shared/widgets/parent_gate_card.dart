import 'package:flutter/material.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_tokens.dart';
import 'read_primary_button.dart';

class ParentGateCard extends StatelessWidget {
  const ParentGateCard({
    required this.title,
    required this.body,
    required this.paymentsEnabled,
    super.key,
  });

  final String title;
  final String body;
  final bool paymentsEnabled;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.surfaceParchment,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.lock_rounded, color: AppColors.brandPrimary),
            const SizedBox(height: AppSpacing.sm),
            Text(title, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: AppSpacing.sm),
            Text(body),
            const SizedBox(height: AppSpacing.lg),
            ReadPrimaryButton(
              label: paymentsEnabled ? 'Continue' : context.l10n.unlockDisabled,
              icon: Icons.family_restroom_rounded,
              onPressed: paymentsEnabled ? () {} : null,
            ),
          ],
        ),
      ),
    );
  }
}
