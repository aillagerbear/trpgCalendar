import 'package:flutter/material.dart';
import 'package:calendar_trpg/screen/home_screen.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
    throw Exception('Supabase URL or Anon Key not found. Please check your environment variables.');
  }

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