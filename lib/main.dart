import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';

import 'cubits/home_bloc.dart';
import 'cubits/notes_bloc.dart';
import 'cubits/search_bloc.dart';
import 'screens/home/home_screen.dart';
import 'screens/auth/auth_check_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'services/home_notes_service.dart';
import 'repositories/notes_repository.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final notesRepository = NotesRepository();
  final homeService = HomeNotesService(notesRepository: notesRepository);

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => HomeBloc(homeService: homeService),
        ),
        BlocProvider(
          create: (_) => SearchBloc(notesService: homeService),
        ),
        BlocProvider(
          create: (_) => NotesBloc(
            repository: notesRepository,
            homeService: homeService,
          ),
        ),
      ],
      child: const NotelyApp(),
    ),
  );
}


class NotelyApp extends StatelessWidget {

  const NotelyApp({super.key});



  @override
  Widget build(BuildContext context) {
    final baseTheme = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      useMaterial3: true,
    );

    return 
      MaterialApp(
        title: 'Notely',
        debugShowCheckedModeBanner: false,
        localizationsDelegates: const [
          FlutterQuillLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', 'US'),
        ],
        theme: baseTheme.copyWith(
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: baseTheme.appBarTheme.copyWith(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
          ),
        ),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/home': (context) => const HomeScreen(),
        },
        home: const AuthCheckScreen(),
      );
    
  }
}
