import 'package:flutter/material.dart';
import 'package:calendar_trpg/screen/home_screen.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from .env file if it exists
  await dotenv.load(fileName: '.env');

  // Use environment variables from .env or from Vercel
  final supabaseUrl = dotenv.env['SUPABASE_URL'] ?? const String.fromEnvironment('SUPABASE_URL', defaultValue: '');
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? const String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  await initializeDateFormatting();

  runApp(
    const MaterialApp(
      home: HomeScreen(),
    ),
  );
}

// Supabase 클라이언트 참조
final supabase = Supabase.instance.client;
