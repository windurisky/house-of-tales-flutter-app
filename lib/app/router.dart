import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/login_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/onboarding/presentation/onboarding_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/story/presentation/reader_screen.dart';
import '../features/story/presentation/story_detail_screen.dart';
import 'providers.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/login',
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/stories/:storyId',
        builder: (context, state) =>
            StoryDetailScreen(storyId: state.pathParameters['storyId']!),
      ),
      GoRoute(
        path: '/stories/:storyId/read',
        builder: (context, state) =>
            ReaderScreen(storyId: state.pathParameters['storyId']!),
      ),
    ],
    redirect: (context, state) {
      final signedIn = ref.read(isSignedInProvider);
      final onboarded = ref.read(onboardingCompleteProvider);
      final location = state.matchedLocation;
      if (!signedIn && location != '/login') {
        return '/login';
      }
      if (signedIn && !onboarded && location != '/onboarding') {
        return '/onboarding';
      }
      if (signedIn && onboarded && location == '/login') {
        return '/home';
      }
      return null;
    },
  );
});
