import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'providers/cart_provider.dart';
import 'screens/main_screen.dart';

// --- VOS INFORMATIONS SUPABASE ---
const String supabaseUrl = 'https://vmxzmxrvjozpvgfoeyom.supabase.co';
const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZteHpteHJ2am96cHZnZm9leW9tIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTE2MTk3MjcsImV4cCI6MjEwNzE5NTcyN30.zUySlOA8pdORYNb4zLIS8fk_WFTxrbN5uLR_Us1QLD0';
// ---------------------------------

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: MaterialApp(
        title: 'Ma Boutique',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.orange,
          scaffoldBackgroundColor: const Color(0xFFF5F5F5),
          useMaterial3: false,
        ),
        home: const MainScreen(),
      ),
    );
  }
}
