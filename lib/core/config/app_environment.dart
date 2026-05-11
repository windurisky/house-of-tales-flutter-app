enum AppMode { mock, localApi, api }

class AppEnvironment {
  const AppEnvironment({
    required this.mode,
    required this.apiBaseUrl,
    this.paymentsEnabled = false,
  });

  const AppEnvironment.mock()
    : mode = AppMode.mock,
      apiBaseUrl = 'mock://house-of-tales',
      paymentsEnabled = false;

  const AppEnvironment.fromDartDefine()
    : mode =
          const String.fromEnvironment('APP_ENV', defaultValue: 'mock') == 'api'
          ? AppMode.api
          : const String.fromEnvironment('APP_ENV', defaultValue: 'mock') ==
                'localApi'
          ? AppMode.localApi
          : AppMode.mock,
      apiBaseUrl = const String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: 'http://localhost:8080/api/v1',
      ),
      paymentsEnabled = const bool.fromEnvironment(
        'PAYMENTS_ENABLED',
        defaultValue: false,
      );

  final AppMode mode;
  final String apiBaseUrl;
  final bool paymentsEnabled;

  bool get usesMockData => mode == AppMode.mock;
}
