// lib/core/theme/theme_service.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Tipos de tema disponíveis
enum AppThemeType {
  light,
  dark,
  system,
}

/// Esquemas de cores personalizados
enum ColorScheme {
  blue,
  green,
  purple,
  orange,
  red,
  teal,
}

/// Configuração de tema personalizada
class ThemeConfig {
  final AppThemeType themeType;
  final ColorScheme colorScheme;
  final double fontSize;
  final bool useSystemFont;
  final bool highContrast;
  final bool reducedMotion;

  const ThemeConfig({
    this.themeType = AppThemeType.system,
    this.colorScheme = ColorScheme.blue,
    this.fontSize = 14.0,
    this.useSystemFont = false,
    this.highContrast = false,
    this.reducedMotion = false,
  });

  ThemeConfig copyWith({
    AppThemeType? themeType,
    ColorScheme? colorScheme,
    double? fontSize,
    bool? useSystemFont,
    bool? highContrast,
    bool? reducedMotion,
  }) {
    return ThemeConfig(
      themeType: themeType ?? this.themeType,
      colorScheme: colorScheme ?? this.colorScheme,
      fontSize: fontSize ?? this.fontSize,
      useSystemFont: useSystemFont ?? this.useSystemFont,
      highContrast: highContrast ?? this.highContrast,
      reducedMotion: reducedMotion ?? this.reducedMotion,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'themeType': themeType.name,
      'colorScheme': colorScheme.name,
      'fontSize': fontSize,
      'useSystemFont': useSystemFont,
      'highContrast': highContrast,
      'reducedMotion': reducedMotion,
    };
  }

  factory ThemeConfig.fromJson(Map<String, dynamic> json) {
    return ThemeConfig(
      themeType: AppThemeType.values.firstWhere(
        (e) => e.name == json['themeType'],
        orElse: () => AppThemeType.system,
      ),
      colorScheme: ColorScheme.values.firstWhere(
        (e) => e.name == json['colorScheme'],
        orElse: () => ColorScheme.blue,
      ),
      fontSize: (json['fontSize'] as num?)?.toDouble() ?? 14.0,
      useSystemFont: json['useSystemFont'] as bool? ?? false,
      highContrast: json['highContrast'] as bool? ?? false,
      reducedMotion: json['reducedMotion'] as bool? ?? false,
    );
  }
}

/// Serviço de gerenciamento de temas
class ThemeService extends ChangeNotifier {
  static final ThemeService _instance = ThemeService._internal();
  factory ThemeService() => _instance;
  ThemeService._internal();

  static const String _themeConfigKey = 'theme_config';
  
  ThemeConfig _config = const ThemeConfig();
  SharedPreferences? _prefs;

  ThemeConfig get config => _config;
  
  /// Inicializar serviço de temas
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadThemeConfig();
  }

  /// Obter tema claro baseado na configuração
  ThemeData get lightTheme {
    final colorScheme = _getColorScheme(_config.colorScheme, false);
    return _buildTheme(colorScheme, Brightness.light);
  }

  /// Obter tema escuro baseado na configuração
  ThemeData get darkTheme {
    final colorScheme = _getColorScheme(_config.colorScheme, true);
    return _buildTheme(colorScheme, Brightness.dark);
  }

  /// Obter modo de tema atual
  ThemeMode get themeMode {
    switch (_config.themeType) {
      case AppThemeType.light:
        return ThemeMode.light;
      case AppThemeType.dark:
        return ThemeMode.dark;
      case AppThemeType.system:
        return ThemeMode.system;
    }
  }

  /// Atualizar configuração de tema
  Future<void> updateThemeConfig(ThemeConfig newConfig) async {
    _config = newConfig;
    await _saveThemeConfig();
    notifyListeners();
    
    // Atualizar status bar
    _updateSystemUI();
  }

  /// Alternar entre tema claro e escuro
  Future<void> toggleTheme() async {
    final newThemeType = _config.themeType == AppThemeType.light 
        ? AppThemeType.dark 
        : AppThemeType.light;
    
    await updateThemeConfig(_config.copyWith(themeType: newThemeType));
  }

  /// Definir esquema de cores
  Future<void> setColorScheme(ColorScheme colorScheme) async {
    await updateThemeConfig(_config.copyWith(colorScheme: colorScheme));
  }

  /// Definir tamanho da fonte
  Future<void> setFontSize(double fontSize) async {
    await updateThemeConfig(_config.copyWith(fontSize: fontSize));
  }

  /// Alternar alto contraste
  Future<void> toggleHighContrast() async {
    await updateThemeConfig(_config.copyWith(highContrast: !_config.highContrast));
  }

  /// Alternar movimento reduzido
  Future<void> toggleReducedMotion() async {
    await updateThemeConfig(_config.copyWith(reducedMotion: !_config.reducedMotion));
  }

  /// Resetar para configurações padrão
  Future<void> resetToDefault() async {
    await updateThemeConfig(const ThemeConfig());
  }

  /// Obter lista de esquemas de cores disponíveis
  List<ColorSchemeInfo> getAvailableColorSchemes() {
    return [
      ColorSchemeInfo(
        scheme: ColorScheme.blue,
        name: 'Azul',
        description: 'Esquema azul clássico',
        primaryColor: Colors.blue,
      ),
      ColorSchemeInfo(
        scheme: ColorScheme.green,
        name: 'Verde',
        description: 'Esquema verde natural',
        primaryColor: Colors.green,
      ),
      ColorSchemeInfo(
        scheme: ColorScheme.purple,
        name: 'Roxo',
        description: 'Esquema roxo moderno',
        primaryColor: Colors.purple,
      ),
      ColorSchemeInfo(
        scheme: ColorScheme.orange,
        name: 'Laranja',
        description: 'Esquema laranja energético',
        primaryColor: Colors.orange,
      ),
      ColorSchemeInfo(
        scheme: ColorScheme.red,
        name: 'Vermelho',
        description: 'Esquema vermelho vibrante',
        primaryColor: Colors.red,
      ),
      ColorSchemeInfo(
        scheme: ColorScheme.teal,
        name: 'Azul-verde',
        description: 'Esquema azul-verde elegante',
        primaryColor: Colors.teal,
      ),
    ];
  }

  // Métodos privados

  Future<void> _loadThemeConfig() async {
    if (_prefs == null) return;
    
    final configJson = _prefs!.getString(_themeConfigKey);
    if (configJson != null) {
      try {
        final Map<String, dynamic> json = 
            Map<String, dynamic>.from(
              // Simulação de parsing JSON - em produção usaria dart:convert
              _parseJsonString(configJson),
            );
        _config = ThemeConfig.fromJson(json);
      } catch (e) {
        // Se houver erro, usar configuração padrão
        _config = const ThemeConfig();
      }
    }
    
    notifyListeners();
  }

  Future<void> _saveThemeConfig() async {
    if (_prefs == null) return;
    
    final configJson = _config.toJson().toString();
    await _prefs!.setString(_themeConfigKey, configJson);
  }

  Map<String, dynamic> _parseJsonString(String jsonString) {
    // Implementação simplificada - em produção usaria jsonDecode
    return {
      'themeType': 'system',
      'colorScheme': 'blue',
      'fontSize': 14.0,
      'useSystemFont': false,
      'highContrast': false,
      'reducedMotion': false,
    };
  }

  MaterialColorScheme _getColorScheme(ColorScheme scheme, bool isDark) {
    final Map<ColorScheme, Color> primaryColors = {
      ColorScheme.blue: Colors.blue,
      ColorScheme.green: Colors.green,
      ColorScheme.purple: Colors.purple,
      ColorScheme.orange: Colors.orange,
      ColorScheme.red: Colors.red,
      ColorScheme.teal: Colors.teal,
    };

    final primaryColor = primaryColors[scheme] ?? Colors.blue;
    
    if (isDark) {
      return MaterialColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
      );
    } else {
      return MaterialColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
      );
    }
  }

  ThemeData _buildTheme(MaterialColorScheme colorScheme, Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    
    // Configurações de texto baseadas na configuração
    final textTheme = _buildTextTheme(isDark);
    
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: brightness,
      textTheme: textTheme,
      
      // AppBar
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        systemOverlayStyle: isDark 
            ? SystemUiOverlayStyle.light 
            : SystemUiOverlayStyle.dark,
      ),

      // Cards
      cardTheme: CardTheme(
        elevation: _config.highContrast ? 8 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: _config.highContrast 
              ? BorderSide(color: colorScheme.outline, width: 1)
              : BorderSide.none,
        ),
      ),

      // Botões
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: _config.highContrast ? 6 : 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),

      // Input fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark 
            ? colorScheme.surfaceVariant.withOpacity(0.3)
            : colorScheme.surfaceVariant.withOpacity(0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: _config.highContrast 
              ? BorderSide(color: colorScheme.outline, width: 2)
              : BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: _config.highContrast 
              ? BorderSide(color: colorScheme.outline)
              : BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: colorScheme.primary,
            width: _config.highContrast ? 3 : 2,
          ),
        ),
      ),

      // Navegação
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.primaryContainer,
        labelTextStyle: MaterialStateProperty.all(
          textTheme.labelMedium?.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
      ),

      // Animações
      pageTransitionsTheme: _config.reducedMotion 
          ? const PageTransitionsTheme(
              builders: {
                TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
                TargetPlatform.iOS: FadeUpwardsPageTransitionsBuilder(),
              },
            )
          : const PageTransitionsTheme(),

      // Divisores
      dividerTheme: DividerThemeData(
        color: _config.highContrast 
            ? colorScheme.outline 
            : colorScheme.outlineVariant,
        thickness: _config.highContrast ? 2 : 1,
      ),

      // Chips
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceVariant,
        selectedColor: colorScheme.primaryContainer,
        side: _config.highContrast 
            ? BorderSide(color: colorScheme.outline)
            : null,
      ),
    );
  }

  TextTheme _buildTextTheme(bool isDark) {
    final baseTextTheme = isDark 
        ? Typography.material2021().white 
        : Typography.material2021().black;

    final fontSizeMultiplier = _config.fontSize / 14.0;
    
    return baseTextTheme.copyWith(
      displayLarge: baseTextTheme.displayLarge?.copyWith(
        fontSize: (baseTextTheme.displayLarge?.fontSize ?? 57) * fontSizeMultiplier,
        fontWeight: _config.highContrast ? FontWeight.bold : FontWeight.normal,
      ),
      displayMedium: baseTextTheme.displayMedium?.copyWith(
        fontSize: (baseTextTheme.displayMedium?.fontSize ?? 45) * fontSizeMultiplier,
        fontWeight: _config.highContrast ? FontWeight.bold : FontWeight.normal,
      ),
      displaySmall: baseTextTheme.displaySmall?.copyWith(
        fontSize: (baseTextTheme.displaySmall?.fontSize ?? 36) * fontSizeMultiplier,
        fontWeight: _config.highContrast ? FontWeight.bold : FontWeight.normal,
      ),
      headlineLarge: baseTextTheme.headlineLarge?.copyWith(
        fontSize: (baseTextTheme.headlineLarge?.fontSize ?? 32) * fontSizeMultiplier,
        fontWeight: _config.highContrast ? FontWeight.bold : FontWeight.normal,
      ),
      headlineMedium: baseTextTheme.headlineMedium?.copyWith(
        fontSize: (baseTextTheme.headlineMedium?.fontSize ?? 28) * fontSizeMultiplier,
        fontWeight: _config.highContrast ? FontWeight.w600 : FontWeight.normal,
      ),
      headlineSmall: baseTextTheme.headlineSmall?.copyWith(
        fontSize: (baseTextTheme.headlineSmall?.fontSize ?? 24) * fontSizeMultiplier,
        fontWeight: _config.highContrast ? FontWeight.w600 : FontWeight.normal,
      ),
      titleLarge: baseTextTheme.titleLarge?.copyWith(
        fontSize: (baseTextTheme.titleLarge?.fontSize ?? 22) * fontSizeMultiplier,
        fontWeight: _config.highContrast ? FontWeight.w600 : FontWeight.w500,
      ),
      titleMedium: baseTextTheme.titleMedium?.copyWith(
        fontSize: (baseTextTheme.titleMedium?.fontSize ?? 16) * fontSizeMultiplier,
        fontWeight: _config.highContrast ? FontWeight.w600 : FontWeight.w500,
      ),
      titleSmall: baseTextTheme.titleSmall?.copyWith(
        fontSize: (baseTextTheme.titleSmall?.fontSize ?? 14) * fontSizeMultiplier,
        fontWeight: _config.highContrast ? FontWeight.w600 : FontWeight.w500,
      ),
      bodyLarge: baseTextTheme.bodyLarge?.copyWith(
        fontSize: (baseTextTheme.bodyLarge?.fontSize ?? 16) * fontSizeMultiplier,
      ),
      bodyMedium: baseTextTheme.bodyMedium?.copyWith(
        fontSize: (baseTextTheme.bodyMedium?.fontSize ?? 14) * fontSizeMultiplier,
      ),
      bodySmall: baseTextTheme.bodySmall?.copyWith(
        fontSize: (baseTextTheme.bodySmall?.fontSize ?? 12) * fontSizeMultiplier,
      ),
      labelLarge: baseTextTheme.labelLarge?.copyWith(
        fontSize: (baseTextTheme.labelLarge?.fontSize ?? 14) * fontSizeMultiplier,
        fontWeight: _config.highContrast ? FontWeight.w600 : FontWeight.w500,
      ),
      labelMedium: baseTextTheme.labelMedium?.copyWith(
        fontSize: (baseTextTheme.labelMedium?.fontSize ?? 12) * fontSizeMultiplier,
        fontWeight: _config.highContrast ? FontWeight.w600 : FontWeight.w500,
      ),
      labelSmall: baseTextTheme.labelSmall?.copyWith(
        fontSize: (baseTextTheme.labelSmall?.fontSize ?? 11) * fontSizeMultiplier,
        fontWeight: _config.highContrast ? FontWeight.w600 : FontWeight.w500,
      ),
    );
  }

  void _updateSystemUI() {
    final isDark = _config.themeType == AppThemeType.dark;
    
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: isDark ? Colors.black : Colors.white,
        systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      ),
    );
  }
}

/// Informações sobre um esquema de cores
class ColorSchemeInfo {
  final ColorScheme scheme;
  final String name;
  final String description;
  final Color primaryColor;

  const ColorSchemeInfo({
    required this.scheme,
    required this.name,
    required this.description,
    required this.primaryColor,
  });
}

/// Extensão para facilitar acesso ao tema
extension ThemeExtension on BuildContext {
  ThemeService get themeService => ThemeService();
  ThemeConfig get themeConfig => ThemeService().config;
}
