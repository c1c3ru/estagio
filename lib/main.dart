import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app_module.dart';
import 'app_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  // --- Inicialização do Supabase ---
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  // --- Inicialização do Módulo Principal com SharedPreferences ---
  // A lógica de SharedPreferences é tratada dentro do AppModule agora.
  // Isso garante que os binds ocorram antes de qualquer outra coisa.
  final sharedPreferences = await SharedPreferences.getInstance();
  if (kDebugMode) {
    print('Binds registrados!');
  }
  runApp(
    ModularApp(
      module: AppModule(sharedPreferences: sharedPreferences),
      child: const AppWidget(),
    ),
  );
}
