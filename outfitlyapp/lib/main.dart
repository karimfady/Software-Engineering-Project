import 'package:flutter/material.dart';
import 'package:outfitlyapp/login_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  await Supabase.initialize(
    url: 'https://rrnoyixhigxoaykoxhgi.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJybm95aXhoaWd4b2F5a294aGdpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDM3Njk3MjUsImV4cCI6MjA1OTM0NTcyNX0.8drvbmZMq4jkpcQZmeKc5ps1jo_rPREpQOThAOTRtnU',
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
