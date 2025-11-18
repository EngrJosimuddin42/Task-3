import 'dart:convert';
import 'package:hive/hive.dart';
import '../models/note_model.dart';
import '../../domain/entities/note_entity.dart';

class LocalNoteSource {
  static const String boxName = 'notes_box';

  Box get _box => Hive.box(boxName);

  Future<List<NoteModel>> getAll() async {
    final out = <NoteModel>[];

    for (var item in _box.values) {
      try {
        if (item is Map) {
          out.add(NoteModel.fromMap(Map<String, dynamic>.from(item)));
        } else if (item is NoteModel) {
          out.add(item);
        } else if (item is String) {

          // fallback for stored JSON string
          final Map<String, dynamic> map = json.decode(item) as Map<String, dynamic>;
          out.add(NoteModel.fromMap(map));
        } else if (item is Map<String, dynamic>) {
          out.add(NoteModel.fromMap(item));
        }
      } catch (_) {
      }
    }

    return out;
  }

  Future<void> saveAll(List<NoteModel> notes) async {
    await _box.clear();
    final Map<String, dynamic> toPut = {};
    for (final n in notes) {
      toPut[n.id] = n.toMap();
    }
    await _box.putAll(toPut);
  }

  Future<void> addOrUpdate(NoteModel note) async {
    await _box.put(note.id, note.toMap());
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  Future<List<NoteModel>> getPending() async {
    final all = await getAll();
    return all.where((n) => n.syncStatus != SyncStatus.synced).toList();
  }
}
