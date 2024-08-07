import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
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
  try {
    final response = await http.get(Uri.parse('https://us-central1-your-project-id.cloudfunctions.net/getSupabaseConfig'));
    if (response.statusCode == 200) {
      return Map<String, String>.from(json.decode(response.body));
    } else {
      throw Exception('Failed to load Supabase config: ${response.statusCode}');
    }
  } catch (e) {
    _log('Error fetching Supabase config: $e');
    rethrow;
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return MaterialApp(home: WebEntryPoint());
    } else {
      return MaterialApp(home: SplashScreen());
    }
  }
}

class WebEntryPoint extends StatefulWidget {
  @override
  _WebEntryPointState createState() => _WebEntryPointState();
}

class _WebEntryPointState extends State<WebEntryPoint> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      await initializeDateFormatting();
      await dotenv.load(fileName: "assets/.env");

      const supabaseUrl = 'https://vyghlzyacytdsjfihvux.supabase.co';
      String? supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

      if (supabaseAnonKey == null || supabaseAnonKey.isEmpty) {
        _log('SUPABASE_ANON_KEY not found in .env, fetching from Firebase Functions...');
        final config = await fetchSupabaseConfig();
        supabaseAnonKey = config['supabaseAnonKey'];
        if (supabaseAnonKey == null || supabaseAnonKey.isEmpty) {
          throw Exception('Failed to get SUPABASE_ANON_KEY from Firebase Functions');
        }
      }

      _log('Supabase URL: $supabaseUrl');
      _log('Supabase Anon Key length: ${supabaseAnonKey.length}');

      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
      );
      _log('Supabase initialized successfully');

      setState(() {
        _initialized = true;
      });
    } catch (e) {
      _log('Error initializing app: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return HomeScreen();
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      await dotenv.load(fileName: "assets/.env");
      _log('Env file loaded successfully');

      const supabaseUrl = 'https://vyghlzyacytdsjfihvux.supabase.co';
      String? supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

      if (supabaseAnonKey == null || supabaseAnonKey.isEmpty) {
        _log('SUPABASE_ANON_KEY not found in .env, fetching from Firebase Functions...');
        final config = await fetchSupabaseConfig();
        supabaseAnonKey = config['supabaseAnonKey'];
        if (supabaseAnonKey == null || supabaseAnonKey.isEmpty) {
          throw Exception('Failed to get SUPABASE_ANON_KEY from Firebase Functions');
        }
      }

      _log('Supabase URL: $supabaseUrl');
      _log('Supabase Anon Key length: ${supabaseAnonKey.length}');

      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
      );
      _log('Supabase initialized successfully');

      await initializeDateFormatting();
      _log('Date formatting initialized successfully');

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => HomeScreen()),
      );
    } catch (e, stackTrace) {
      _log('Error during initialization: $e');
      _log('Stack trace: $stackTrace');
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('An error occurred during initialization:'),
                  SizedBox(height: 10),
                  Text(e.toString()),
                  SizedBox(height: 20),
                  ElevatedButton(
                    child: Text('Retry'),
                    onPressed: _initializeApp,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await initializeDateFormatting();
  }
  runApp(MyApp());
}