import 'package:flutter/material.dart';

import '../../core/theme/app_tokens.dart';
import '../models/child_profile.dart';
import '../models/subscription_status.dart';

class ParentTrustBar extends StatelessWidget {
  const ParentTrustBar({
    required this.profile,
    required this.subscription,
    super.key,
  });

  final ChildProfile profile;
  final SubscriptionAccess subscription;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.brandSoft.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: AppColors.surfaceCard,
            foregroundColor: AppColors.brandPrimary,
            child: Icon(Icons.verified_user_rounded),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${profile.name} • ${profile.ageLabel}',
                  style: textTheme.labelLarge,
                ),
                Text(
                  '${subscription.plainLabel} • no ads • parent-safe',
                  style: textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
