import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../shared/widgets/language_toggle.dart';
import '../../../shared/widgets/parent_gate_card.dart';
import '../../../shared/widgets/parent_trust_bar.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final child = ref.watch(childProfileProvider);
    final subscription = ref.watch(subscriptionProvider);
    final environment = ref.watch(appEnvironmentProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.profile),
        actions: const [
          Padding(padding: EdgeInsets.all(8), child: LanguageToggle()),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.page),
          children: [
            ParentTrustBar(profile: child, subscription: subscription),
            const SizedBox(height: AppSpacing.lg),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Child profile',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      '${child.name} • ${child.ageLabel} • ${child.avatarId}',
                    ),
                    const Divider(height: AppSpacing.xl),
                    const Text(
                      'Talecoin balance: shown here when Roger’s API contract is available.',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            ParentGateCard(
              title: 'Family access',
              body: context.l10n.subscriptionExplainer,
              paymentsEnabled: environment.paymentsEnabled,
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 1,
        onDestinationSelected: (index) {
          if (index == 0) context.go('/home');
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
