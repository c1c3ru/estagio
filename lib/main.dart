import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/theme/theme_service.dart';
import 'core/utils/module_guard.dart';
import 'app_module.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final moduleGuard = ModuleGuard();

  // Load environment variables (protegido contra múltipla inicialização)
  await moduleGuard.executeServiceOnce('dotenv', () async {
    try {
      await dotenv.load(fileName: '.env');
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ .env file not found, using default values');
      }
    }
  });

  // Initialize Supabase with fallback values (protegido)
  await moduleGuard.executeServiceOnce('supabase', () async {
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL'] ?? 'https://abcdefghijklmnop.supabase.co',
      anonKey: dotenv.env['SUPABASE_ANON_KEY'] ??
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFiY2RlZmdoaWprbG1ub3AiLCJyb2xlIjoiYW5vbiIsImlhdCI6MTYzNjU0NzIwMCwiZXhwIjoxOTUyMTIzMjAwfQ.example',
    );
  });

  // Initialize Firebase with proper configuration (protegido)
  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    await moduleGuard.executeServiceOnce('firebase', () async {
      try {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
        if (kDebugMode) {
          print('✅ Firebase initialized successfully');
        }
      } catch (e) {
        if (kDebugMode) {
          print('⚠️ Firebase initialization error (ignored): $e');
        }
        // Re-throw para que o guard saiba que falhou
        throw e;
      }
    });
  }

  // Initialize ThemeService (protegido)
  await moduleGuard.executeServiceOnce('theme_service', () async {
    await ThemeService().initialize();
  });
  
  // Proteger inicialização do ModularApp
  await moduleGuard.executeOnce('modular_app', () async {
    // Esta função não retorna nada, mas protege contra múltipla inicialização
  });
  
  runApp(ModularApp(module: AppModule(), child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Sistema de Estágio',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      routeInformationParser: Modular.routeInformationParser,
      routerDelegate: Modular.routerDelegate,
      debugShowCheckedModeBanner: false,
    );
  }
}
