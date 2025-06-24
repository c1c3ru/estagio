import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_module.dart';
import 'app_widget.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Carregar variáveis de ambiente
  await dotenv.load(fileName: ".env");

  // Verificar se as credenciais foram carregadas
  final supabaseUrl = dotenv.env['SUPABASE_URL'];
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

  print('🔧 Configuração Supabase:');
  print('URL: ${supabaseUrl != null ? '✅ Carregada' : '❌ Não encontrada'}');
  print(
      'AnonKey: ${supabaseAnonKey != null ? '✅ Carregada' : '❌ Não encontrada'}');

  // Mostrar parte da URL para verificar se está correta
  if (supabaseUrl != null) {
    print(
        'URL (primeiros 30 chars): ${supabaseUrl.substring(0, supabaseUrl.length > 30 ? 30 : supabaseUrl.length)}...');
  }
  if (supabaseAnonKey != null) {
    print(
        'AnonKey (primeiros 20 chars): ${supabaseAnonKey.substring(0, supabaseAnonKey.length > 20 ? 20 : supabaseAnonKey.length)}...');
  }

  if (supabaseUrl == null || supabaseAnonKey == null) {
    print('❌ ERRO: Credenciais do Supabase não encontradas no arquivo .env');
    print('Certifique-se de que o arquivo .env existe e contém:');
    print('SUPABASE_URL=sua_url_aqui');
    print('SUPABASE_ANON_KEY=sua_chave_aqui');
  }

  // Inicializar Supabase
  await Supabase.initialize(
    url: supabaseUrl!,
    anonKey: supabaseAnonKey!,
  );

  print('✅ Supabase inicializado com sucesso');

  SharedPreferences? sharedPreferences;
  if (!kIsWeb) {
    try {
      sharedPreferences = await SharedPreferences.getInstance();
    } catch (_) {
      sharedPreferences = null;
    }
  }

  runApp(ModularApp(
    module: AppModule(sharedPreferences: sharedPreferences),
    child: const AppWidget(),
  ));
}
