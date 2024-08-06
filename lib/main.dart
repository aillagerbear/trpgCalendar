import 'package:flutter/material.dart';
import 'package:calendar_trpg/screen/home_screen.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void _log(String message) {
  print('DEBUG: $message');
}

Future<Map<String, String>> fetchSupabaseConfig() async {
  final response = await http.get(Uri.parse('https://us-central1-your-project-id.cloudfunctions.net/getSupabaseConfig'));
  if (response.statusCode == 200) {
    return Map<String, String>.from(json.decode(response.body));
  } else {
    throw Exception('Failed to load Supabase config');
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  _log('WidgetsFlutterBinding initialized');

  try {
    const supabaseUrl = 'https://vyghlzyacytdsjfihvux.supabase.co';
    String? supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

    if (supabaseAnonKey == null || supabaseAnonKey.isEmpty) {
      _log('Fetching Supabase configuration from Firebase Functions...');
      final config = await fetchSupabaseConfig();
      supabaseAnonKey = config['supabaseAnonKey'];
    }

    _log('Supabase URL: $supabaseUrl');
    _log('Supabase Anon Key length: ${supabaseAnonKey?.length}');

    _log('Initializing Supabase...');
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey!,
    );
    _log('Supabase initialized successfully');

    _log('Initializing date formatting...');
    await initializeDateFormatting();
    _log('Date formatting initialized successfully');

    _log('Running app...');
    runApp(
      const MaterialApp(
        home: HomeScreen(),
      ),
    );
  } catch (e, stackTrace) {
    _log('Error during initialization: $e');
    _log('Stack trace: $stackTrace');
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('An error occurred: $e'),
          ),
        ),
      ),
    );
  }
}
