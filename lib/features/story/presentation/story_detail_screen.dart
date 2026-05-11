import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../shared/models/subscription_status.dart';
import '../../../shared/widgets/language_toggle.dart';
import '../../../shared/widgets/read_primary_button.dart';
import '../../../shared/widgets/state_views.dart';

class StoryDetailScreen extends ConsumerWidget {
  const StoryDetailScreen({required this.storyId, super.key});

  final String storyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storyAsync = ref.watch(storyByIdProvider(storyId));
    final language = ref.watch(uiLanguageProvider);
    final subscription = ref.watch(subscriptionProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.appName),
        actions: const [
          Padding(padding: EdgeInsets.all(8), child: LanguageToggle()),
        ],
      ),
      body: storyAsync.when(
        data: (story) {
          final fullAccess =
              subscription.hasFullAccess ||
              story.access.status == EntitlementStatus.fullAccess;
          return SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.page),
              children: [
                Container(
                  height: 260,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceParchment,
                    borderRadius: BorderRadius.circular(AppRadii.xl),
                  ),
                  child: const Icon(
                    Icons.landscape_rounded,
                    size: 96,
                    color: AppColors.brandPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  story.title.inLanguage(language),
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(story.subtitle.inLanguage(language)),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    Chip(label: Text('Ages ${story.ageBand()}')),
                    Chip(label: Text('${story.readTimeMin} min')),
                    Chip(
                      label: Text(
                        fullAccess
                            ? context.l10n.fullAccess
                            : context.l10n.preview,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                Card(
                  color: AppColors.brandSoft.withValues(alpha: 0.55),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Row(
                      children: [
                        const Icon(Icons.verified_user_rounded),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Text(story.safetyNote.inLanguage(language)),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                ReadPrimaryButton(
                  label: story.isCompleted
                      ? context.l10n.readAgain
                      : story.progressPage > 0
                      ? context.l10n.continueReading
                      : context.l10n.read,
                  onPressed: () => context.go('/stories/${story.id}/read'),
                ),
              ],
            ),
          );
        },
        error: (error, stackTrace) => ErrorStateView(
          message: 'This story could not load.',
          onRetry: () => ref.invalidate(storyByIdProvider(storyId)),
        ),
        loading: () => const LoadingStateView(),
      ),
    );
  }
}
