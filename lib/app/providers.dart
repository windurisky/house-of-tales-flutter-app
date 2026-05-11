import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/config/app_environment.dart';
import '../shared/models/child_profile.dart';
import '../shared/models/story.dart';
import '../shared/models/subscription_status.dart';
import '../shared/models/ui_language.dart';

final appEnvironmentProvider = Provider<AppEnvironment>((ref) {
  return const AppEnvironment.mock();
});

final uiLanguageProvider = StateProvider<UiLanguage>((ref) => UiLanguage.en);
final isSignedInProvider = StateProvider<bool>((ref) => false);
final onboardingCompleteProvider = StateProvider<bool>((ref) => false);

final childProfileProvider = StateProvider<ChildProfile>((ref) {
  return const ChildProfile(
    id: 'mock-child-1',
    name: 'Kirana',
    ageLabel: '4 years',
    avatarId: 'moon-rabbit',
  );
});

final subscriptionProvider = StateProvider<SubscriptionAccess>((ref) {
  return SubscriptionAccess.trialActive(trialEndsAt: DateTime.utc(2026, 5, 14));
});

final storyRepositoryProvider = Provider<StoryRepository>((ref) {
  final environment = ref.watch(appEnvironmentProvider);
  return MockStoryRepository(environment: environment);
});

final storiesProvider = FutureProvider<List<Story>>((ref) async {
  return ref.watch(storyRepositoryProvider).fetchStories();
});

final storyByIdProvider = FutureProvider.family<Story, String>((ref, id) async {
  return ref.watch(storyRepositoryProvider).fetchStory(id);
});
