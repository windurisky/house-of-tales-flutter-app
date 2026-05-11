import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:house_of_tales_flutter_app/app/app.dart';
import 'package:house_of_tales_flutter_app/app/providers.dart';
import 'package:house_of_tales_flutter_app/core/config/app_environment.dart';
import 'package:house_of_tales_flutter_app/shared/models/subscription_status.dart';
import 'package:house_of_tales_flutter_app/shared/models/ui_language.dart';
import 'package:house_of_tales_flutter_app/shared/widgets/story_shelf_card.dart';
import 'package:house_of_tales_flutter_app/shared/models/story.dart';

Widget _app({List<Override> overrides = const []}) {
  return ProviderScope(
    overrides: [
      appEnvironmentProvider.overrideWithValue(const AppEnvironment.mock()),
      ...overrides,
    ],
    child: const HouseOfTalesApp(),
  );
}

Future<void> _completeOnboarding(WidgetTester tester) async {
  await tester.tap(find.text('Start mock session'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Start reading'));
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  Future<void> usePhonePortrait(WidgetTester tester) async {
    tester.view.physicalSize = const Size(430, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  testWidgets('app shell reaches the story shelf in mock mode', (tester) async {
    await usePhonePortrait(tester);
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    expect(find.text('Gentle stories for families'), findsOneWidget);

    await _completeOnboarding(tester);

    expect(find.text('Today’s story shelf'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('The Moon Rabbit Pillow'), findsOneWidget);
  });

  testWidgets('story shelf card exposes preview/full access state', (
    tester,
  ) async {
    await usePhonePortrait(tester);
    final story = mockStories.firstWhere((item) => item.id == 'forest-lantern');
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 220,
            height: 340,
            child: StoryShelfCard(
              story: story,
              language: UiLanguage.en,
              onTap: () {},
            ),
          ),
        ),
      ),
    );

    expect(find.text('Lanterns in the Little Forest'), findsOneWidget);
    expect(find.text('Preview'), findsOneWidget);
  });

  testWidgets('reader shows preview paywall when family access is not active', (
    tester,
  ) async {
    await usePhonePortrait(tester);
    await tester.pumpWidget(
      _app(
        overrides: [
          subscriptionProvider.overrideWith(
            (ref) => SubscriptionAccess.preview(),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();
    await _completeOnboarding(tester);

    await tester.ensureVisible(find.text('Lanterns in the Little Forest'));
    await tester.tap(find.text('Lanterns in the Little Forest'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Read'));
    await tester.tap(find.text('Read'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text('Continue with family access'), findsOneWidget);
    expect(find.text('Payments not enabled'), findsOneWidget);
  });
}
