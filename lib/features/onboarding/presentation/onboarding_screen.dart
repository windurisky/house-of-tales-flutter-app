import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../shared/models/child_profile.dart';
import '../../../shared/widgets/language_toggle.dart';
import '../../../shared/widgets/read_primary_button.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _nameController = TextEditingController(text: 'Kirana');
  final _ageController = TextEditingController(text: '4 years');
  String _avatarId = 'moon-rabbit';

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final avatars = ['moon-rabbit', 'forest-fox', 'ocean-turtle'];
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.onboardingTitle),
        actions: const [
          Padding(padding: EdgeInsets.all(8), child: LanguageToggle()),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.page),
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: context.l10n.childName),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _ageController,
              decoration: InputDecoration(labelText: context.l10n.childAge),
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              context.l10n.chooseAvatar,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              children: avatars.map((avatar) {
                final selected = avatar == _avatarId;
                return ChoiceChip(
                  label: Text(avatar.replaceAll('-', ' ')),
                  selected: selected,
                  onSelected: (_) => setState(() => _avatarId = avatar),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.xl),
            Card(
              color: AppColors.brandSoft.withValues(alpha: 0.6),
              child: const Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: Text(
                  'PIN setup and Clerk token exchange are held behind mock/local/API boundaries for Roger’s API handoff.',
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            ReadPrimaryButton(
              label: context.l10n.finishOnboarding,
              onPressed: () {
                ref.read(childProfileProvider.notifier).state = ChildProfile(
                  id: 'mock-child-1',
                  name: _nameController.text.trim().isEmpty
                      ? 'Little reader'
                      : _nameController.text.trim(),
                  ageLabel: _ageController.text.trim().isEmpty
                      ? '4 years'
                      : _ageController.text.trim(),
                  avatarId: _avatarId,
                );
                ref.read(onboardingCompleteProvider.notifier).state = true;
                context.go('/home');
              },
            ),
          ],
        ),
      ),
    );
  }
}
