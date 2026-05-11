import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(text: 'Kirana');
  final _pinController = TextEditingController();
  final _confirmPinController = TextEditingController();
  final _pinFocusNode = FocusNode();
  final _confirmPinFocusNode = FocusNode();

  String _avatarId = 'moon-rabbit';
  int _birthMonth = DateTime.may;
  int _birthYear = 2022;
  String? _pinMismatchError;

  static const _avatars = ['moon-rabbit', 'forest-fox', 'ocean-turtle'];

  @override
  void dispose() {
    _nameController.dispose();
    _pinController.dispose();
    _confirmPinController.dispose();
    _pinFocusNode.dispose();
    _confirmPinFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final birthYears = List.generate(
      10,
      (index) => DateTime.now().year - index,
    );
    final derivedAgeLabel = _ageLabelFromBirthDate(
      month: _birthMonth,
      year: _birthYear,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.onboardingTitle),
        actions: const [
          Padding(padding: EdgeInsets.all(8), child: LanguageToggle()),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.page),
            children: [
              Text(
                'Tell us about your little reader',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.sm),
              const Text(
                'We only need a nickname, reading age range, avatar, and a parent PIN for grown-up actions.',
              ),
              const SizedBox(height: AppSpacing.lg),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: context.l10n.childName),
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Add a child nickname';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Pick their reading age range',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text('Estimated age: $derivedAgeLabel'),
              const SizedBox(height: AppSpacing.sm),
              Column(
                children: [
                  DropdownButtonFormField<int>(
                    initialValue: _birthMonth,
                    decoration: const InputDecoration(labelText: 'Birth month'),
                    isExpanded: true,
                    items: List.generate(12, (index) {
                      final month = index + 1;
                      return DropdownMenuItem(
                        value: month,
                        child: Text(_monthName(month)),
                      );
                    }),
                    onChanged: (value) =>
                        setState(() => _birthMonth = value ?? _birthMonth),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  DropdownButtonFormField<int>(
                    initialValue: _birthYear,
                    decoration: const InputDecoration(labelText: 'Birth year'),
                    isExpanded: true,
                    items: birthYears.map((year) {
                      return DropdownMenuItem(
                        value: year,
                        child: Text('$year'),
                      );
                    }).toList(),
                    onChanged: (value) =>
                        setState(() => _birthYear = value ?? _birthYear),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                context.l10n.chooseAvatar,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: _avatars.map((avatar) {
                  final selected = avatar == _avatarId;
                  return ChoiceChip(
                    avatar: Icon(_iconForAvatar(avatar), size: 18),
                    label: Text(avatar.replaceAll('-', ' ')),
                    selected: selected,
                    onSelected: (_) => setState(() => _avatarId = avatar),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Set your Parent PIN',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.xs),
              const Text(
                'Use 4 digits. We keep this local in mock mode and never log child profile details.',
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _pinController,
                      focusNode: _pinFocusNode,
                      decoration: const InputDecoration(labelText: 'Enter PIN'),
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      maxLength: 4,
                      textInputAction: TextInputAction.next,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (_) => _clearPinMismatch(),
                      onFieldSubmitted: (_) =>
                          _confirmPinFocusNode.requestFocus(),
                      validator: _validatePin,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: TextFormField(
                      controller: _confirmPinController,
                      focusNode: _confirmPinFocusNode,
                      decoration: const InputDecoration(
                        labelText: 'Confirm PIN',
                      ),
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      maxLength: 4,
                      textInputAction: TextInputAction.done,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (_) => _clearPinMismatch(),
                      validator: _validatePin,
                    ),
                  ),
                ],
              ),
              if (_pinMismatchError != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  _pinMismatchError!,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppColors.error),
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              Card(
                color: AppColors.brandSoft.withValues(alpha: 0.6),
                child: const Padding(
                  padding: EdgeInsets.all(AppSpacing.md),
                  child: Text(
                    'Mock mode will create the child profile, parent PIN boundary, and trial state without calling live payment systems.',
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              ReadPrimaryButton(
                label: context.l10n.finishOnboarding,
                onPressed: () => _finishOnboarding(context, derivedAgeLabel),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _clearPinMismatch() {
    if (_pinMismatchError != null) {
      setState(() => _pinMismatchError = null);
    }
  }

  String? _validatePin(String? value) {
    if (value == null || value.length != 4) {
      return 'Use 4 digits';
    }
    return null;
  }

  void _finishOnboarding(BuildContext context, String derivedAgeLabel) {
    final formIsValid = _formKey.currentState?.validate() ?? false;
    final pinsMatch = _pinController.text == _confirmPinController.text;

    if (!formIsValid || !pinsMatch) {
      setState(() {
        _pinMismatchError = pinsMatch ? null : 'PINs do not match. Try again.';
      });
      return;
    }

    ref.read(childProfileProvider.notifier).state = ChildProfile(
      id: 'mock-child-1',
      name: _nameController.text.trim(),
      ageLabel: derivedAgeLabel,
      avatarId: _avatarId,
    );
    ref.read(onboardingCompleteProvider.notifier).state = true;
    context.go('/home');
  }

  static String _ageLabelFromBirthDate({
    required int month,
    required int year,
  }) {
    final now = DateTime.now();
    var age = now.year - year;
    if (now.month < month) {
      age -= 1;
    }
    if (age <= 0) {
      return 'Under 1 year';
    }
    return age == 1 ? '1 year' : '$age years';
  }

  static String _monthName(int month) {
    const names = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return names[month - 1];
  }

  static IconData _iconForAvatar(String avatar) {
    return switch (avatar) {
      'forest-fox' => Icons.pets_rounded,
      'ocean-turtle' => Icons.water_rounded,
      _ => Icons.nightlight_round,
    };
  }
}
