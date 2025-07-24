import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'app_module.dart';
import 'app_widget.dart';
import 'core/constants/app_constants.dart';
import 'core/services/notification_service.dart';
import 'core/services/reminder_service.dart';
import 'core/services/performance_service.dart';
import 'core/theme/theme_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar serviços de performance primeiro
  final performanceService = PerformanceService();
  performanceService.initialize();
  
  // Inicializar serviço de temas
  final themeService = ThemeService();
  await themeService.initialize();

  if (kDebugMode) {
    print('🟡 main: Iniciando aplicação...');
    if (!kIsWeb) {
      print('🟡 main: Platform: ${Platform.operatingSystem}');
    } else {
      print('🟡 main: Platform: Web');
    }
    print('🟡 main: Web: $kIsWeb');
  }

  try {
    // Carregar variáveis de ambiente
    await performanceService.measureOperation('load_env', () async {
      await dotenv.load(fileName: ".env");
    });
    if (kDebugMode) {
      print('✅ Variáveis de ambiente carregadas');
    }
  } catch (e) {
    if (kDebugMode) {
      print('⚠️ Erro ao carregar .env: $e');
      print('⚠️ Tentando continuar sem arquivo .env...');
    }
  }

  try {
    // Configuração específica para web
    if (kIsWeb) {
      if (kDebugMode) {
        print('🌐 Configurando para web...');
      }
    }

    // Inicializar Supabase
    await performanceService.measureOperation('init_supabase', () async {
      await Supabase.initialize(
        url: AppConstants.supabaseUrl,
        anonKey: AppConstants.supabaseAnonKey,
      );
    });
    if (kDebugMode) {
      print('✅ Supabase inicializado com sucesso');
    }
  } catch (e) {
    if (kDebugMode) {
      print('⚠️ Erro ao inicializar Supabase: $e');
    }
    if (kDebugMode) {
      print(
          '⚠️ Verifique se as credenciais do Supabase estão configuradas corretamente');
    }
    // Não vamos parar a execução do app por causa do erro do Supabase
    // O app deve funcionar mesmo sem Supabase configurado
  }

  try {
    // Initialize SharedPreferences
    await SharedPreferences.getInstance();
    if (kDebugMode) {
      print('✅ SharedPreferences inicializado com sucesso');
    }
  } catch (e) {
    if (kDebugMode) {
      print('⚠️ Erro ao inicializar SharedPreferences: $e');
    }
  }

  try {
    // Initialize Notification Service
    if (!kIsWeb) { // Notificações push não funcionam na web
      final notificationService = NotificationService();
      final initialized = await notificationService.initialize();
      if (kDebugMode) {
        if (initialized) {
          print('✅ Serviço de notificações inicializado com sucesso');
        } else {
          print('⚠️ Falha ao inicializar serviço de notificações');
        }
      }

      // Initialize Reminder Service
      if (initialized) {
        final reminderService = ReminderService();
        final reminderInitialized = await reminderService.initialize();
        if (kDebugMode) {
          if (reminderInitialized) {
            print('✅ Serviço de lembretes inicializado com sucesso');
          } else {
            print('⚠️ Falha ao inicializar serviço de lembretes');
          }
        }
      }
    } else {
      if (kDebugMode) {
        print('🌐 Notificações push não suportadas na web');
      }
    }
  } catch (e) {
    if (kDebugMode) {
      print('⚠️ Erro ao inicializar serviços de notificação: $e');
    }
  }

  try {
    // Initialize date formatting
    await initializeDateFormatting('pt_BR', null);
    if (kDebugMode) {
      print('✅ Formatação de data inicializada com sucesso');
    }
  } catch (e) {
    if (kDebugMode) {
      print('⚠️ Erro ao inicializar formatação de data: $e');
    }
  }

  // Pré-carregar dados críticos se usuário estiver logado
  final currentUser = Supabase.instance.client.auth.currentUser;
  if (currentUser != null) {
    await performanceService.preloadCriticalData(
      userId: currentUser.id,
      userType: 'student', // Determinar tipo baseado nos dados do usuário
    );
  }

  // Configurar otimizações de UI
  performanceService.configureUIOptimizations();

  if (kDebugMode) {
    print('🟡 main: Executando app...');
  }

  runApp(
    ListenableBuilder(
      listenable: ThemeService(),
      builder: (context, child) {
        final themeService = ThemeService();
        
        return MaterialApp.router(
          title: 'Sistema de Estágio',
          theme: themeService.lightTheme,
          darkTheme: themeService.darkTheme,
          themeMode: themeService.themeMode,
          routerConfig: Modular.routerConfig,
          debugShowCheckedModeBanner: false,
          builder: (context, child) {
            // Configurar otimizações de performance para a UI
            return child ?? const SizedBox();
          },
        );
      },
    ),
  );
}
