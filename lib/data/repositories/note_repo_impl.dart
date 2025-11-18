import '../datasources/local_note_source.dart';
import '../datasources/remote_note_api.dart';
import '../models/note_model.dart';
import '../../domain/entities/note_entity.dart';
import 'dart:async';

class NoteRepoImpl {
  final LocalNoteSource local;
  final RemoteNoteApi remote;
  Timer? _retryTimer;
  final Map<String, int> _backoffSeconds = {};
  bool _running = false;

  NoteRepoImpl({required this.local, required this.remote}) {
    _startRetryLoop();
  }

  // 🔥 MODEL → ENTITY
  NoteEntity _toEntity(NoteModel m) {
    return NoteEntity(
      id: m.id,
      title: m.title,
      content: m.content,
      colorValue: m.colorValue,
      syncStatus: m.syncStatus,
      updatedAt: m.updatedAt,
      isDeleted: m.isDeleted,
    );
  }

  // 🔥 ENTITY → MODEL
  NoteModel _toModel(NoteEntity e) {
    return NoteModel(
      id: e.id,
      title: e.title,
      content: e.content,
      colorValue: e.colorValue,
      syncStatus: e.syncStatus,
      updatedAt: e.updatedAt,
      isDeleted: e.isDeleted,
    );
  }

  // ✔ FIXED: GET ALL NOTES
  Future<List<NoteEntity>> getNotes() async {
    final models = await local.getAll();
    final filtered = models.where((n) => !n.isDeleted).toList();
    return filtered.map(_toEntity).toList();
  }

  // ✔ FIXED: ADD NOTE
  Future<void> addNote(NoteEntity note, {bool trySyncIfOnline = true}) async {

    final model = _toModel(note);
    await local.addOrUpdate(model);

    if (trySyncIfOnline) {
      final ok = await remote.uploadNote(
        title: model.title,
        body: model.content,
        localId: model.id,
      );

      final updated = model.copyWith(
        syncStatus: ok ? SyncStatus.synced : SyncStatus.pending,
      );

      await local.addOrUpdate(updated);

      if (!ok) _backoffSeconds.putIfAbsent(model.id, () => 2);
    } else {
      _backoffSeconds.putIfAbsent(model.id, () => 2);
    }
  }

  // ✔ FIXED: UPDATE NOTE
  Future<void> updateNote(NoteEntity note, {bool trySyncIfOnline = true}) async {
    // always force convert
    await addNote(note, trySyncIfOnline: trySyncIfOnline);
  }

  // ✔ FIXED: DELETE NOTE
  Future<void> deleteNote(String id) async {
    final all = await local.getAll();
    final m = all.firstWhere((n) => n.id == id);

    final deleted = m.copyWith(
      isDeleted: true,
      syncStatus: SyncStatus.pending,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );

    await local.addOrUpdate(deleted);
    _backoffSeconds.remove(id);
  }

  // ✔ FIXED: SYNC PENDING
  Future<void> syncPending({required Future<bool> Function() isOnline}) async {
    if (!await isOnline()) return;

    final pending = await local.getPending();

    for (final m in pending) {
      if (m.isDeleted) {
        final ok = await remote.deleteNote(m.id);
        if (ok) await local.delete(m.id);
        continue;
      }

      await local.addOrUpdate(m.copyWith(syncStatus: SyncStatus.syncing));

      final ok = await remote.uploadNote(
        title: m.title,
        body: m.content,
        localId: m.id,
      );

      final updated = m.copyWith(
        syncStatus: ok ? SyncStatus.synced : SyncStatus.failed,
      );

      await local.addOrUpdate(updated);
    }
  }

  // RETRY LOOP (unchanged)
  void _startRetryLoop() {
    if (_running) return;
    _running = true;

    _retryTimer = Timer.periodic(const Duration(seconds: 10), (_) async {
      try {
        final pending = await local.getPending();

        for (final m in pending) {
          if (m.isDeleted) {
            final ok = await remote.deleteNote(m.id);
            if (ok) {
              await local.delete(m.id);
              _backoffSeconds.remove(m.id);
            }
            continue;
          }

          final ok = await remote.uploadNote(
            title: m.title,
            body: m.content,
            localId: m.id,
          );

          if (ok) {
            await local.addOrUpdate(
              m.copyWith(syncStatus: SyncStatus.synced),
            );
            _backoffSeconds.remove(m.id);
          } else {
            final next = (_backoffSeconds[m.id] ?? 2) * 2;
            _backoffSeconds[m.id] = next.clamp(2, 300);
          }
        }
      } catch (_) {}
    });
  }

  void dispose() {
    _retryTimer?.cancel();
    _running = false;
  }
}
