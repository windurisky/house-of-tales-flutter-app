import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../shared/models/story.dart';
import '../../../shared/models/subscription_status.dart';
import '../../../shared/widgets/language_toggle.dart';
import '../../../shared/widgets/parent_gate_card.dart';
import '../../../shared/widgets/state_views.dart';
import '../../../shared/widgets/story_text_panel.dart';

class ReaderScreen extends ConsumerStatefulWidget {
  const ReaderScreen({required this.storyId, super.key});

  final String storyId;

  @override
  ConsumerState<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends ConsumerState<ReaderScreen> {
  int _pageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final storyAsync = ref.watch(storyByIdProvider(widget.storyId));
    final language = ref.watch(uiLanguageProvider);
    final subscription = ref.watch(subscriptionProvider);
    final environment = ref.watch(appEnvironmentProvider);

    return storyAsync.when(
      data: (story) {
        final page = story.pages[_pageIndex];
        final hasFullAccess =
            subscription.hasFullAccess ||
            story.access.status == EntitlementStatus.fullAccess;
        final gatedAfterPartial = !hasFullAccess && page.isGatedAfterPartial;
        final blocked =
            !hasFullAccess && page.pageNumber > story.access.previewPages + 1;

        return Scaffold(
          appBar: AppBar(
            title: Text('${page.pageNumber}/${story.pageCount}'),
            actions: const [
              Padding(padding: EdgeInsets.all(8), child: LanguageToggle()),
            ],
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.page),
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadii.xl),
                  child: Container(
                    height: 280,
                    color: AppColors.surfaceParchment,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        const DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.surfaceParchment,
                                AppColors.brandSoft,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                        ),
                        Center(
                          child: Icon(
                            _iconForPage(page),
                            size: 90,
                            color: AppColors.brandPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                if (blocked)
                  ParentGateCard(
                    title: context.l10n.readerGateTitle,
                    body: context.l10n.readerGateBody,
                    paymentsEnabled: environment.paymentsEnabled,
                  )
                else ...[
                  StoryTextPanel(
                    text: page.text.inLanguage(language),
                    partial: gatedAfterPartial,
                  ),
                  if (gatedAfterPartial) ...[
                    const SizedBox(height: AppSpacing.md),
                    ParentGateCard(
                      title: context.l10n.readerGateTitle,
                      body: context.l10n.readerGateBody,
                      paymentsEnabled: environment.paymentsEnabled,
                    ),
                  ],
                ],
                const SizedBox(height: AppSpacing.lg),
                LinearProgressIndicator(
                  value: page.pageNumber / story.pageCount,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(999),
                  color: AppColors.actionPrimary,
                  backgroundColor: AppColors.borderSubtle,
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _pageIndex == 0
                            ? null
                            : () => setState(() => _pageIndex -= 1),
                        icon: const Icon(Icons.arrow_back_rounded),
                        label: const Text('Back'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _pageIndex >= story.pages.length - 1
                            ? null
                            : () => setState(() => _pageIndex += 1),
                        icon: const Icon(Icons.arrow_forward_rounded),
                        label: const Text('Next'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
      error: (error, stackTrace) => Scaffold(
        body: ErrorStateView(
          message: 'Reader could not open this story.',
          onRetry: () => ref.invalidate(storyByIdProvider(widget.storyId)),
        ),
      ),
      loading: () => const Scaffold(body: LoadingStateView()),
    );
  }

  static IconData _iconForPage(StoryPage page) {
    return switch (page.pageNumber % 4) {
      0 => Icons.waves_rounded,
      1 => Icons.nightlight_round,
      2 => Icons.park_rounded,
      _ => Icons.star_rounded,
    };
  }
}
