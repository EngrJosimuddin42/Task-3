import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'presentation/providers/note_provider.dart';
import 'package:task_3/data/repositories/note_repo_impl.dart';
import 'data/datasources/local_note_source.dart';
import 'data/datasources/remote_note_api.dart';
import 'package:task_3/presentation/ screens/home_page.dart';
import 'package:task_3/data/models/note_model_adapter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Hive init
  await Hive.initFlutter();
  Hive.registerAdapter(NoteModelAdapter());
  await Hive.openBox('notes_box');

  final repo = NoteRepoImpl(
    local: LocalNoteSource(),
    remote: RemoteNoteApi(),
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => NoteProvider(repo),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _dark = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<NoteProvider>(context, listen: false);
      provider.loadSettings().then((_) {
        setState(() => _dark = provider.isDarkMode);
      });
      provider.addListener(() {
        setState(() => _dark = provider.isDarkMode);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Notes (Task 3)',
      theme: ThemeData(
        brightness: Brightness.light,
        useMaterial3: false,
        iconTheme: const IconThemeData(size: 28),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: false,
        iconTheme: const IconThemeData(size: 28),
      ),
      themeMode: _dark ? ThemeMode.dark : ThemeMode.light,
      home:  HomePage(),
    );
  }
}
