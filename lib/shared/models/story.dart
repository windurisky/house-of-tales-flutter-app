import '../../core/config/app_environment.dart';
import 'subscription_status.dart';
import 'ui_language.dart';

class LocalizedText {
  const LocalizedText({required this.en, required this.id});
  final String en;
  final String id;
  String inLanguage(UiLanguage language) => language == UiLanguage.en ? en : id;
}

class StoryAccess {
  const StoryAccess({required this.status, required this.previewPages});

  final EntitlementStatus status;
  final int previewPages;

  bool get isPreview => status == EntitlementStatus.preview;
}

class Story {
  const Story({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.ageMin,
    required this.ageMax,
    required this.readTimeMin,
    required this.pageCount,
    required this.access,
    required this.safetyNote,
    required this.pages,
    this.progressPage = 0,
    this.isCompleted = false,
  });

  final String id;
  final LocalizedText title;
  final LocalizedText subtitle;
  final String category;
  final int ageMin;
  final int ageMax;
  final int readTimeMin;
  final int pageCount;
  final StoryAccess access;
  final LocalizedText safetyNote;
  final List<StoryPage> pages;
  final int progressPage;
  final bool isCompleted;

  String ageBand() => '$ageMin–$ageMax';
}

class StoryPage {
  const StoryPage({
    required this.id,
    required this.pageNumber,
    required this.text,
    required this.illustrationSeed,
    required this.totalPages,
    required this.access,
    this.isPreviewPage = false,
    this.isGatedAfterPartial = false,
  });

  final String id;
  final int pageNumber;
  final LocalizedText text;
  final String illustrationSeed;
  final int totalPages;
  final EntitlementStatus access;
  final bool isPreviewPage;
  final bool isGatedAfterPartial;
}

abstract class StoryRepository {
  Future<List<Story>> fetchStories();
  Future<Story> fetchStory(String id);
}

class MockStoryRepository implements StoryRepository {
  const MockStoryRepository({required this.environment});

  final AppEnvironment environment;

  @override
  Future<List<Story>> fetchStories() async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    return mockStories;
  }

  @override
  Future<Story> fetchStory(String id) async {
    final stories = await fetchStories();
    return stories.firstWhere((story) => story.id == id);
  }
}

final mockStories = <Story>[
  _story(
    id: 'moon-rabbit',
    titleEn: 'The Moon Rabbit Pillow',
    titleId: 'Bantal Kelinci Bulan',
    subtitleEn: 'A sleepy cloud learns to share moonlight.',
    subtitleId: 'Awan mengantuk belajar berbagi cahaya bulan.',
    category: 'bedtime',
    progressPage: 2,
    access: const StoryAccess(
      status: EntitlementStatus.fullAccess,
      previewPages: 2,
    ),
  ),
  _story(
    id: 'forest-lantern',
    titleEn: 'Lanterns in the Little Forest',
    titleId: 'Lentera di Hutan Kecil',
    subtitleEn: 'Tiny animals find the brave way home.',
    subtitleId: 'Hewan mungil menemukan jalan pulang yang berani.',
    category: 'animals',
    access: const StoryAccess(
      status: EntitlementStatus.preview,
      previewPages: 2,
    ),
  ),
  _story(
    id: 'grandma-kite',
    titleEn: 'Grandma’s Kite Soup',
    titleId: 'Sup Layangan Nenek',
    subtitleEn: 'A silly kitchen tale about patience.',
    subtitleId: 'Kisah dapur lucu tentang kesabaran.',
    category: 'family',
    access: const StoryAccess(
      status: EntitlementStatus.preview,
      previewPages: 2,
    ),
  ),
  _story(
    id: 'brave-coconut',
    titleEn: 'The Brave Coconut Boat',
    titleId: 'Perahu Kelapa Pemberani',
    subtitleEn: 'A riverside adventure with gentle waves.',
    subtitleId: 'Petualangan tepi sungai dengan ombak lembut.',
    category: 'adventure',
    access: const StoryAccess(
      status: EntitlementStatus.fullAccess,
      previewPages: 2,
    ),
    isCompleted: true,
  ),
];

Story _story({
  required String id,
  required String titleEn,
  required String titleId,
  required String subtitleEn,
  required String subtitleId,
  required String category,
  required StoryAccess access,
  int progressPage = 0,
  bool isCompleted = false,
}) {
  const pageCount = 6;
  final pages = List.generate(pageCount, (index) {
    final number = index + 1;
    final gatedPartial = access.isPreview && number == access.previewPages + 1;
    return StoryPage(
      id: '$id-page-$number',
      pageNumber: number,
      text: LocalizedText(
        en: 'Page $number: $titleEn opens like a warm book. A little friend pauses, listens, and chooses the kind next step.',
        id: 'Halaman $number: $titleId terbuka seperti buku hangat. Seorang teman kecil berhenti, mendengar, dan memilih langkah baik berikutnya.',
      ),
      illustrationSeed: '$category-$number',
      totalPages: pageCount,
      access: access.status,
      isPreviewPage: access.isPreview && number <= access.previewPages,
      isGatedAfterPartial: gatedPartial,
    );
  });

  return Story(
    id: id,
    title: LocalizedText(en: titleEn, id: titleId),
    subtitle: LocalizedText(en: subtitleEn, id: subtitleId),
    category: category,
    ageMin: 3,
    ageMax: 6,
    readTimeMin: 5,
    pageCount: pageCount,
    access: access,
    safetyNote: const LocalizedText(
      en: 'Parent-safe story: calm pacing, no ads, no surprise purchases.',
      id: 'Cerita aman untuk orang tua: alur tenang, tanpa iklan, tanpa pembelian mendadak.',
    ),
    pages: pages,
    progressPage: progressPage,
    isCompleted: isCompleted,
  );
}
