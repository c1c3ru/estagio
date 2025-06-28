import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app_module.dart';
import 'app_widget.dart';
import 'core/constants/app_constants.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kDebugMode) {
    print('🟡 main: Iniciando aplicação...');
  }

  try {
    // Carregar variáveis de ambiente
    await dotenv.load(fileName: ".env");
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
    // Inicializar Supabase com as constantes
    await Supabase.initialize(
      url: AppConstants.supabaseUrl,
      anonKey: AppConstants.supabaseAnonKey,
    );
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

  if (kDebugMode) {
    print('🟡 main: Executando app...');
  }

  runApp(ModularApp(module: AppModule(), child: const AppWidget()));
}
