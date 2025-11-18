import 'package:hive/hive.dart';
import 'note_model.dart';

class NoteModelAdapter extends TypeAdapter<NoteModel> {
  @override
  final int typeId = 0;

  @override
  NoteModel read(BinaryReader reader) {
    final len = reader.readByte();
    final map = <String, dynamic>{};
    for (int i = 0; i < len; i++) {
      final key = reader.readString();
      final value = reader.read();
      map[key] = value;
    }
    return NoteModel.fromMap(Map<String, dynamic>.from(map));
  }

  @override
  void write(BinaryWriter writer, NoteModel obj) {
    final map = obj.toMap();
    writer.writeByte(map.length);
    map.forEach((key, value) {
      writer.writeString(key);
      writer.write(value);
    });
  }
}
