import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'app_module.dart';
import 'app_widget.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  SharedPreferences? sharedPreferences;
  if (!kIsWeb) {
    try {
      sharedPreferences = await SharedPreferences.getInstance();
    } catch (_) {
      sharedPreferences = null;
    }
  }

  runApp(
    ModularApp(
      module: AppModule(sharedPreferences: sharedPreferences),
      child: const AppWidget(),
    ),
  );
}
