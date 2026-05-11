import 'package:flutter/material.dart';

import '../../core/theme/app_tokens.dart';
import '../models/story.dart';
import '../models/subscription_status.dart';
import '../models/ui_language.dart';

class StoryShelfCard extends StatelessWidget {
  const StoryShelfCard({
    required this.story,
    required this.language,
    required this.onTap,
    super.key,
  });

  final Story story;
  final UiLanguage language;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPreview = story.access.status == EntitlementStatus.preview;
    return Semantics(
      button: true,
      label: story.title.inLanguage(language),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.lg),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.surfaceCard,
            borderRadius: BorderRadius.circular(AppRadii.lg),
            border: Border.all(color: AppColors.borderSubtle),
            boxShadow: const [
              BoxShadow(
                color: Color(0x12000000),
                blurRadius: 18,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceParchment,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(AppRadii.lg),
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned.fill(child: _StoryArt(seed: story.category)),
                      Positioned(
                        top: AppSpacing.sm,
                        right: AppSpacing.sm,
                        child: _AccessBadge(
                          label: isPreview ? 'Preview' : 'Full access',
                          isPreview: isPreview,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      story.title.inLanguage(language),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Ages ${story.ageBand()} • ${story.readTimeMin} min',
                      style: theme.textTheme.bodySmall,
                    ),
                    if (story.progressPage > 0) ...[
                      const SizedBox(height: AppSpacing.sm),
                      LinearProgressIndicator(
                        value: story.progressPage / story.pageCount,
                        minHeight: 6,
                        borderRadius: BorderRadius.circular(999),
                        backgroundColor: AppColors.borderSubtle,
                        color: AppColors.actionPrimary,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StoryArt extends StatelessWidget {
  const _StoryArt({required this.seed});

  final String seed;

  @override
  Widget build(BuildContext context) {
    final icon = switch (seed) {
      'animals' => Icons.pets_rounded,
      'family' => Icons.soup_kitchen_rounded,
      'adventure' => Icons.sailing_rounded,
      _ => Icons.nightlight_round,
    };
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.surfaceParchment, AppColors.actionPrimarySoft],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(child: Icon(icon, size: 56, color: AppColors.brandPrimary)),
    );
  }
}

class _AccessBadge extends StatelessWidget {
  const _AccessBadge({required this.label, required this.isPreview});

  final String label;
  final bool isPreview;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isPreview ? AppColors.actionPrimarySoft : AppColors.brandSoft,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label, style: Theme.of(context).textTheme.labelSmall),
    );
  }
}
