import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:gestao_de_estagio/core/theme/theme_service.dart';
import 'package:gestao_de_estagio/core/services/cache_service.dart';
import 'package:gestao_de_estagio/core/services/sync_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'test_app_module.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Persistence and State Recovery Integration Tests', () {
    late ThemeService themeService;
    late CacheService cacheService;
    late SyncService syncService;

    setUp(() async {
      // Initialize the TestAppModule for dependency injection
      Modular.bindModule(TestAppModule());
      
      // Get services from Modular after binding the module
      themeService = Modular.get<ThemeService>();
      await themeService.initialize();
      
      cacheService = Modular.get<CacheService>();
      await cacheService.initialize();
      
      syncService = Modular.get<SyncService>();
      await syncService.initialize();
    });

    tearDown(() async {
      // Clean up Modular bindings
      cleanModular(); // This properly resets the Modular injector between tests
    });

    group('Theme Persistence Tests', () {
      testWidgets('should save and restore theme configuration',
          (tester) async {
        // Get initial theme type
        final initialThemeType = themeService.config.themeType;
        
        // Act - Change theme and save
        await themeService.toggleTheme(); // toggle from initial state
        await themeService.setColorScheme(AppColorScheme.green);
        // Theme config is automatically saved when changed

        // Create a new instance to test theme recovery
        final newThemeService = ThemeService();
        await newThemeService.initialize();

        // Assert
        final restoredConfig = newThemeService.config;
        // Expect the toggled theme, not specifically light
        expect(restoredConfig.themeType, isNot(initialThemeType));
        expect(restoredConfig.colorScheme, AppColorScheme.green);
      });

      testWidgets('should maintain theme settings across app sessions',
          (tester) async {
        // Arrange
        await themeService.initialize(); // Initialize ThemeService

        // Set theme to light
        if (themeService.config.themeType != AppThemeType.light) {
          await themeService.toggleTheme(); // system -> light
        }
        await themeService.setColorScheme(AppColorScheme.purple);
        // Theme config is automatically saved when changed

        // Simulate app restart
        final newThemeService = ThemeService();
        await newThemeService.initialize();

        // Assert
        expect(newThemeService.config.themeType, AppThemeType.light);
        expect(newThemeService.config.colorScheme, AppColorScheme.purple);
      });
    });

    group('Cache Service Tests', () {
      testWidgets('should cache and retrieve data correctly', (tester) async {
        // Arrange
        const cacheKey = 'test_data_key';
        const testData = {'name': 'John Doe', 'age': 30};

        // Act - Cache data
        await cacheService.cacheData(
          key: cacheKey,
          data: testData,
          entityType: 'test',
        );

        // Retrieve cached data
        final cachedData = await cacheService.getCachedData(cacheKey);

        // Assert
        expect(cachedData, isNotNull);
        expect(cachedData!['name'], equals('John Doe'));
        expect(cachedData['age'], equals(30));
      });

      testWidgets('should expire cached data after timeout', (tester) async {
        // Arrange
        const cacheKey = 'expiring_data_key';
        const testData = {'value': 'temporary'};

        // Act - Cache data with short expiry
        await cacheService.cacheData(
          key: cacheKey,
          data: testData,
          entityType: 'test',
          expiresIn: const Duration(milliseconds: 100),
        );

        // Wait for expiration
        await Future.delayed(const Duration(milliseconds: 150));

        // Try to retrieve expired data
        final cachedData = await cacheService.getCachedData(cacheKey);

        // Assert
        expect(cachedData, isNull);
      });
    });

    group('Sync Service Tests', () {
      testWidgets('should handle offline data synchronization', (tester) async {
        // Arrange
        const syncKey = 'sync_test_key';
        const testData = {'id': '123', 'content': 'offline data'};

        // Simulate offline scenario
        // Act - Save pending operation
        await syncService.addOfflineOperation(
          operationType: 'create',
          entityType: 'test',
          entityId: syncKey,
          data: testData,
        );

        // Assert
        final pendingOps = await cacheService.getPendingOperations();
        expect(pendingOps, isNotEmpty);
        expect(pendingOps.length, equals(1));
        expect(pendingOps.first['entity_id'], equals(syncKey));
        expect(pendingOps.first['operation_type'], equals('create'));
      });
    });

    group('SharedPreferences Tests', () {
      testWidgets('should persist user preferences across sessions',
          (tester) async {
        // Arrange
        const prefKey = 'user_preference_test';
        const prefValue = 'preference_value';

        // Act - Save preference
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(prefKey, prefValue);

        // Simulate app restart
        final newPrefs = await SharedPreferences.getInstance();
        final retrievedValue = newPrefs.getString(prefKey);

        // Assert
        expect(retrievedValue, equals(prefValue));
      });
    });
  });
}
