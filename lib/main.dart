import 'package:flutter/material.dart';
import 'package:calendar_trpg/screen/home_screen.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  String supabaseUrl = '';
  String supabaseAnonKey = '';

  try {
    // 로컬 환경에서 .env 파일 로드 시도
    await dotenv.load(fileName: '.env');
    supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
    supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  } catch (e) {
    // .env 파일 로딩 실패 시 (주로 배포 환경에서) 기본값 사용
    print('Failed to load .env file. Using environment variables.');
  }

  // .env에서 로드 실패 시 환경 변수에서 직접 로드
  if (supabaseUrl.isEmpty) {
    supabaseUrl = const String.fromEnvironment('SUPABASE_URL', defaultValue: '');
  }
  if (supabaseAnonKey.isEmpty) {
    supabaseAnonKey = const String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');
  }

  if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
    throw Exception('Supabase URL or Anon Key not found. Please check your environment variables or .env file.');
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