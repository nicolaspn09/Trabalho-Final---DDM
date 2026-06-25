import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

void main() async {
  print('Iniciando teste de login...');
  final supabase = SupabaseClient('https://epktvxijnkuulnixvyyz.supabase.co', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVwa3R2eGlqbmt1dWxuaXh2eXl6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODI0MTU0NzAsImV4cCI6MjA5Nzk5MTQ3MH0.IgG6QjqztNTRLEUKpFUfCSfntHiG0DMzzFDJ3Ugby58');

  try {
    final res = await supabase.auth.signInWithPassword(email: 'joao@email.com', password: 'equador');
    print('Login Response: \');
    print('Current Session: \');
  } catch (e) {
    print('Erro: \');
  }
  exit(0);
}

