import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../shared/widgets/language_toggle.dart';
import '../../../shared/widgets/read_primary_button.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.page),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Align(
                alignment: Alignment.centerRight,
                child: LanguageToggle(),
              ),
              const Spacer(),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  color: AppColors.surfaceParchment,
                  borderRadius: BorderRadius.circular(AppRadii.xl),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.auto_stories_rounded,
                      size: 56,
                      color: AppColors.brandPrimary,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      context.l10n.welcomeTitle,
                      style: Theme.of(context).textTheme.displayLarge,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(context.l10n.welcomeBody),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              ReadPrimaryButton(
                label: context.l10n.startMockSession,
                icon: Icons.login_rounded,
                onPressed: () {
                  ref.read(isSignedInProvider.notifier).state = true;
                  context.go('/onboarding');
                },
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                context.l10n.parentSignIn,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
