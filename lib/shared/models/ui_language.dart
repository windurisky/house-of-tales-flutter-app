enum UiLanguage { en, id }

extension UiLanguageX on UiLanguage {
  String get label => switch (this) {
    UiLanguage.en => 'EN',
    UiLanguage.id => 'ID',
  };
}
