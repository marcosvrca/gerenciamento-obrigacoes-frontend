class ApiConfig {
  /// Android emulator: 10.0.2.2 maps to host localhost.
  /// Windows/web/desktop: localhost works when API runs on the host.
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080',
  );
}
