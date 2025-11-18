import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../domain/entities/note_entity.dart';
import 'package:task_3/data/repositories/note_repo_impl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class NoteProvider extends ChangeNotifier {
  final NoteRepoImpl repo;
  final _uuid = const Uuid();

  List<NoteEntity> notes = [];
  bool isSyncing = false;
  bool isDarkMode = false;
  StreamSubscription<List<ConnectivityResult>>? _connectSub;

  NoteProvider(this.repo) {
    _init();
  }

  Future<void> _init() async {
    await loadSettings();
    await loadNotes();
    _connectSub = Connectivity().onConnectivityChanged.listen((events) async {
      if (events.any((e) => e != ConnectivityResult.none)) {
        await syncPending();
      }
    });
  }

  Future<void> loadSettings() async {
    final sp = await SharedPreferences.getInstance();
    isDarkMode = sp.getBool('dark_mode') ?? false;
    notifyListeners();
  }

  Future<void> toggleDarkMode() async {
    final sp = await SharedPreferences.getInstance();
    isDarkMode = !isDarkMode;
    await sp.setBool('dark_mode', isDarkMode);
    notifyListeners();
  }

  Future<void> loadNotes() async {
    final list = await repo.getNotes();
    notes = list;

    // sort by updatedAt desc
    notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    notifyListeners();
  }

  Future<void> addNote(String title, String content, int colorValue) async {

    // 🔹 Check for duplicate by title and content
    bool exists = notes.any((n) => n.title == title && n.content == content);
    if (exists) return; // duplicate, save হবে না

    final n = NoteEntity(
      id: 'n_${DateTime.now().millisecondsSinceEpoch}_${_uuid.v4().substring(0, 6)}',
      title: title,
      content: content,
      colorValue: colorValue,
      syncStatus: SyncStatus.pending,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );

    // Repo তে save
    await repo.addNote(n, trySyncIfOnline: await _isOnline());

    // UI instant update
    notes.insert(0, n);
    notifyListeners();
  }

  Future<void> updateNote(NoteEntity note) async {
    final updated = note.copyWith(
      updatedAt: DateTime.now().millisecondsSinceEpoch,
      syncStatus: SyncStatus.pending,
    );
    await repo.updateNote(updated, trySyncIfOnline: await _isOnline());
    await loadNotes();
  }

  Future<void> deleteNote(String id) async {
    try {
      // 1️⃣ UI থেকে remove
      notes.removeWhere((n) => n.id == id);
      notifyListeners();

      // 2️⃣ Local DB থেকে remove (mark deleted নয়)
      await repo.local.delete(id);

      // 3️⃣ Online হলে remote delete try
      if (await _isOnline()) {
        try {
          await repo.remote.deleteNote(id);
        } catch (_) {}
      }
    } catch (e) {
      debugPrint("Delete failed: $e");
    }
  }

  Future<bool> _isOnline() async {
    final res = await Connectivity().checkConnectivity();
    return res != ConnectivityResult.none;
  }

  Future<void> syncPending() async {
    isSyncing = true;
    notifyListeners();
    await repo.syncPending(isOnline: _isOnline);
    await loadNotes();
    isSyncing = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _connectSub?.cancel();
    repo.dispose();
    super.dispose();
  }
}
