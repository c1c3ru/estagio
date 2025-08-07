// lib/core/accessibility/accessibility_service.dart
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';

/// Configurações de acessibilidade
class AccessibilityConfig {
  final bool announceScreenChanges;
  final bool enableSemanticLabels;
  final bool useHighContrastFocus;
  final bool enableKeyboardNavigation;
  final bool announceFormErrors;
  final bool enableHapticFeedback;
  final double semanticFontScale;
  final bool enableScreenReaderSupport;

  const AccessibilityConfig({
    this.announceScreenChanges = true,
    this.enableSemanticLabels = true,
    this.useHighContrastFocus = false,
    this.enableKeyboardNavigation = true,
    this.announceFormErrors = true,
    this.enableHapticFeedback = true,
    this.semanticFontScale = 1.0,
    this.enableScreenReaderSupport = true,
  });

  AccessibilityConfig copyWith({
    bool? announceScreenChanges,
    bool? enableSemanticLabels,
    bool? useHighContrastFocus,
    bool? enableKeyboardNavigation,
    bool? announceFormErrors,
    bool? enableHapticFeedback,
    double? semanticFontScale,
    bool? enableScreenReaderSupport,
  }) {
    return AccessibilityConfig(
      announceScreenChanges: announceScreenChanges ?? this.announceScreenChanges,
      enableSemanticLabels: enableSemanticLabels ?? this.enableSemanticLabels,
      useHighContrastFocus: useHighContrastFocus ?? this.useHighContrastFocus,
      enableKeyboardNavigation: enableKeyboardNavigation ?? this.enableKeyboardNavigation,
      announceFormErrors: announceFormErrors ?? this.announceFormErrors,
      enableHapticFeedback: enableHapticFeedback ?? this.enableHapticFeedback,
      semanticFontScale: semanticFontScale ?? this.semanticFontScale,
      enableScreenReaderSupport: enableScreenReaderSupport ?? this.enableScreenReaderSupport,
    );
  }
}

/// Serviço de acessibilidade
class AccessibilityService extends ChangeNotifier {
  static final AccessibilityService _instance = AccessibilityService._internal();
  factory AccessibilityService() => _instance;
  AccessibilityService._internal();

  AccessibilityConfig _config = const AccessibilityConfig();
  bool _isScreenReaderEnabled = false;
  bool _isHighContrastEnabled = false;
  bool _isLargeTextEnabled = false;

  AccessibilityConfig get config => _config;
  bool get isScreenReaderEnabled => _isScreenReaderEnabled;
  bool get isHighContrastEnabled => _isHighContrastEnabled;
  bool get isLargeTextEnabled => _isLargeTextEnabled;

  /// Inicializar serviço de acessibilidade
  Future<void> initialize() async {
    await _detectSystemAccessibilitySettings();
    _configureSemantics();
  }

  /// Atualizar configurações de acessibilidade
  Future<void> updateConfig(AccessibilityConfig newConfig) async {
    _config = newConfig;
    _configureSemantics();
    notifyListeners();
  }

  /// Anunciar mudança de tela para leitores de tela
  void announceScreenChange(String screenName, {String? description}) {
    if (!_config.announceScreenChanges || !_isScreenReaderEnabled) return;

    final announcement = description != null 
        ? '$screenName. $description'
        : 'Navegou para $screenName';

    SemanticsService.announce(
      announcement,
      TextDirection.ltr,
      assertiveness: Assertiveness.polite,
    );
  }

  /// Anunciar ação realizada
  void announceAction(String action, {bool isImportant = false}) {
    if (!_config.enableSemanticLabels || !_isScreenReaderEnabled) return;

    SemanticsService.announce(
      action,
      TextDirection.ltr,
      assertiveness: isImportant ? Assertiveness.assertive : Assertiveness.polite,
    );
  }

  /// Anunciar erro de formulário
  void announceFormError(String fieldName, String error) {
    if (!_config.announceFormErrors || !_isScreenReaderEnabled) return;

    SemanticsService.announce(
      'Erro no campo $fieldName: $error',
      TextDirection.ltr,
      assertiveness: Assertiveness.assertive,
    );
  }

  /// Anunciar sucesso de operação
  void announceSuccess(String message) {
    if (!_isScreenReaderEnabled) return;

    SemanticsService.announce(
      'Sucesso: $message',
      TextDirection.ltr,
      assertiveness: Assertiveness.polite,
    );
  }

  /// Fornecer feedback háptico
  void provideFeedback(HapticFeedbackType type) {
    if (!_config.enableHapticFeedback) return;

    switch (type) {
      case HapticFeedbackType.lightImpact:
        HapticFeedback.lightImpact();
        break;
      case HapticFeedbackType.mediumImpact:
        HapticFeedback.mediumImpact();
        break;
      case HapticFeedbackType.heavyImpact:
        HapticFeedback.heavyImpact();
        break;
      case HapticFeedbackType.selectionClick:
        HapticFeedback.selectionClick();
        break;
      case HapticFeedbackType.vibrate:
        HapticFeedback.vibrate();
        break;
    }
  }

  /// Obter rótulo semântico para um elemento
  String getSemanticLabel(String baseLabel, {
    String? hint,
    String? value,
    bool isButton = false,
    bool isSelected = false,
    bool isExpanded = false,
  }) {
    if (!_config.enableSemanticLabels) return baseLabel;

    final parts = <String>[baseLabel];

    if (value != null && value.isNotEmpty) {
      parts.add(value);
    }

    if (isButton) {
      parts.add('botão');
    }

    if (isSelected) {
      parts.add('selecionado');
    }

    if (isExpanded) {
      parts.add('expandido');
    } else if (isExpanded == false) {
      parts.add('recolhido');
    }

    if (hint != null && hint.isNotEmpty) {
      parts.add(hint);
    }

    return parts.join(', ');
  }

  /// Criar widget com foco acessível
  Widget buildAccessibleFocus({
    required Widget child,
    required String semanticLabel,
    VoidCallback? onTap,
    String? hint,
    bool autofocus = false,
  }) {
    return Focus(
      autofocus: autofocus,
      child: Builder(
        builder: (context) {
          final hasFocus = Focus.of(context).hasFocus;
          
          return Container(
            decoration: _config.useHighContrastFocus && hasFocus
                ? BoxDecoration(
                    border: Border.all(
                      color: Colors.yellow,
                      width: 3,
                    ),
                  )
                : null,
            child: Semantics(
              label: semanticLabel,
              hint: hint,
              button: onTap != null,
              focusable: true,
              child: GestureDetector(
                onTap: onTap != null
                    ? () {
                        provideFeedback(HapticFeedbackType.selectionClick);
                        onTap();
                      }
                    : null,
                child: child,
              ),
            ),
          );
        },
      ),
    );
  }

  /// Criar widget de navegação por teclado
  Widget buildKeyboardNavigable({
    required Widget child,
    required VoidCallback onActivate,
    String? semanticLabel,
    bool autofocus = false,
  }) {
    if (!_config.enableKeyboardNavigation) {
      return child;
    }

    return Focus(
      autofocus: autofocus,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.enter ||
              event.logicalKey == LogicalKeyboardKey.space) {
            onActivate();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: Builder(
        builder: (context) {
          final hasFocus = Focus.of(context).hasFocus;
          
          return Container(
            decoration: hasFocus && _config.useHighContrastFocus
                ? BoxDecoration(
                    border: Border.all(
                      color: Colors.yellow,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  )
                : null,
            child: Semantics(
              label: semanticLabel,
              button: true,
              focusable: true,
              child: child,
            ),
          );
        },
      ),
    );
  }

  /// Criar widget de formulário acessível
  Widget buildAccessibleFormField({
    required Widget child,
    required String label,
    String? error,
    String? hint,
    bool isRequired = false,
  }) {
    final semanticLabel = getSemanticLabel(
      label,
      hint: isRequired ? 'campo obrigatório' : null,
    );

    return Semantics(
      label: semanticLabel,
      hint: hint,
      textField: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          child,
          if (error != null) ...[
            const SizedBox(height: 4),
            Semantics(
              liveRegion: true,
              child: Text(
                error,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Criar widget de lista acessível
  Widget buildAccessibleList({
    required List<Widget> children,
    required String listLabel,
    String? description,
  }) {
    return Semantics(
      label: listLabel,
      hint: description,
      child: Column(
        children: children.asMap().entries.map((entry) {
          final index = entry.key;
          final child = entry.value;
          
          return Semantics(
            label: 'Item ${index + 1} de ${children.length}',
            child: child,
          );
        }).toList(),
      ),
    );
  }

  /// Verificar se deve usar descrições estendidas
  bool shouldUseExtendedDescriptions() {
    return _isScreenReaderEnabled && _config.enableSemanticLabels;
  }

  /// Obter instruções de navegação
  String getNavigationInstructions() {
    if (!_config.enableKeyboardNavigation) return '';
    
    return 'Use Tab para navegar, Enter ou Espaço para ativar, Escape para voltar';
  }

  // Métodos privados

  Future<void> _detectSystemAccessibilitySettings() async {
    // Simular detecção de configurações do sistema
    // Em produção, usaria platform channels para detectar configurações reais
    _isScreenReaderEnabled = false; // Detectar TalkBack/VoiceOver
    _isHighContrastEnabled = false; // Detectar alto contraste do sistema
    _isLargeTextEnabled = false; // Detectar texto grande do sistema
  }

  void _configureSemantics() {
    // Configurar serviços de semântica baseado na configuração
    if (_config.enableScreenReaderSupport) {
      SemanticsBinding.instance.ensureSemantics();
    }
  }
}

/// Tipos de feedback háptico
enum HapticFeedbackType {
  lightImpact,
  mediumImpact,
  heavyImpact,
  selectionClick,
  vibrate,
}

/// Widget helper para acessibilidade
class AccessibleWidget extends StatelessWidget {
  final Widget child;
  final String semanticLabel;
  final String? hint;
  final VoidCallback? onTap;
  final bool isButton;
  final bool excludeSemantics;

  const AccessibleWidget({
    super.key,
    required this.child,
    required this.semanticLabel,
    this.hint,
    this.onTap,
    this.isButton = false,
    this.excludeSemantics = false,
  });

  @override
  Widget build(BuildContext context) {
    final accessibilityService = AccessibilityService();
    
    if (excludeSemantics) {
      return ExcludeSemantics(child: child);
    }

    final label = accessibilityService.getSemanticLabel(
      semanticLabel,
      hint: hint,
      isButton: isButton,
    );

    return Semantics(
      label: label,
      hint: hint,
      button: isButton || onTap != null,
      excludeSemantics: excludeSemantics,
      child: GestureDetector(
        onTap: onTap != null
            ? () {
                accessibilityService.provideFeedback(HapticFeedbackType.selectionClick);
                onTap!();
              }
            : null,
        child: child,
      ),
    );
  }
}

/// Mixin para widgets que precisam de recursos de acessibilidade
mixin AccessibilityMixin {
  AccessibilityService get accessibility => AccessibilityService();

  void announceToScreenReader(String message, {bool isImportant = false}) {
    accessibility.announceAction(message, isImportant: isImportant);
  }

  void announceError(String fieldName, String error) {
    accessibility.announceFormError(fieldName, error);
  }

  void announceSuccess(String message) {
    accessibility.announceSuccess(message);
  }

  void provideFeedback([HapticFeedbackType type = HapticFeedbackType.selectionClick]) {
    accessibility.provideFeedback(type);
  }
}

/// Extensão para facilitar uso de acessibilidade
extension AccessibilityExtension on BuildContext {
  AccessibilityService get accessibility => AccessibilityService();
  
  void announceScreenChange(String screenName, {String? description}) {
    accessibility.announceScreenChange(screenName, description: description);
  }
}
