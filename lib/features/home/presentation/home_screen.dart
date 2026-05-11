import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../shared/widgets/language_toggle.dart';
import '../../../shared/widgets/parent_trust_bar.dart';
import '../../../shared/widgets/state_views.dart';
import '../../../shared/widgets/story_shelf_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stories = ref.watch(storiesProvider);
    final language = ref.watch(uiLanguageProvider);
    final child = ref.watch(childProfileProvider);
    final subscription = ref.watch(subscriptionProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.appName),
        actions: const [
          Padding(padding: EdgeInsets.all(8), child: LanguageToggle()),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => ref.invalidate(storiesProvider),
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.page),
            children: [
              Text(
                context.l10n.homeTitle,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: AppSpacing.md),
              ParentTrustBar(profile: child, subscription: subscription),
              const SizedBox(height: AppSpacing.lg),
              stories.when(
                data: (items) {
                  if (items.isEmpty) {
                    return const EmptyStateView(
                      title: 'No stories yet',
                      body:
                          'Your shelf will fill up after story fixtures sync.',
                    );
                  }
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: items.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: AppSpacing.md,
                          crossAxisSpacing: AppSpacing.md,
                          childAspectRatio: 0.66,
                        ),
                    itemBuilder: (context, index) {
                      final story = items[index];
                      return StoryShelfCard(
                        story: story,
                        language: language,
                        onTap: () => context.go('/stories/${story.id}'),
                      );
                    },
                  );
                },
                error: (error, stackTrace) => ErrorStateView(
                  message: 'The shelf could not load. Please try again.',
                  onRetry: () => ref.invalidate(storiesProvider),
                ),
                loading: () => const LoadingStateView(),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: (index) {
          if (index == 1) context.go('/profile');
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.auto_stories_outlined),
            selectedIcon: const Icon(Icons.auto_stories_rounded),
            label: context.l10n.stories,
          ),
          NavigationDestination(
            icon: const Icon(Icons.family_restroom_outlined),
            selectedIcon: const Icon(Icons.family_restroom_rounded),
            label: context.l10n.profile,
          ),
        ],
      ),
    );
  }
}
