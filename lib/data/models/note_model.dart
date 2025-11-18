import 'package:hive/hive.dart';
import '../../domain/entities/note_entity.dart';
part 'note_model.g.dart';

@HiveType(typeId: 0)
class NoteModel extends NoteEntity {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String content;

  @HiveField(3)
  final int colorValue;

  @HiveField(4)
  final SyncStatus syncStatus;

  @HiveField(5)
  final int updatedAt;

  @HiveField(6)
  final bool isDeleted;

  NoteModel({
    required this.id,
    required this.title,
    required this.content,
    required this.colorValue,
    required this.syncStatus,
    required this.updatedAt,
    this.isDeleted = false,
  }) : super(
    id: id,
    title: title,
    content: content,
    colorValue: colorValue,
    syncStatus: syncStatus,
    updatedAt: updatedAt,
    isDeleted: isDeleted,
  );

  factory NoteModel.fromMap(Map<String, dynamic> m) => NoteModel(
    id: m['id'] as String,
    title: m['title'] as String,
    content: m['content'] as String,
    colorValue: m['colorValue'] as int,
    syncStatus: SyncStatus.values[m['syncStatus'] as int],
    updatedAt: m['updatedAt'] as int,
    isDeleted: m['isDeleted'] as bool? ?? false,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'content': content,
    'colorValue': colorValue,
    'syncStatus': syncStatus.index,
    'updatedAt': updatedAt,
    'isDeleted': isDeleted,
  };

  NoteModel copyWith({
    String? id,
    String? title,
    String? content,
    int? colorValue,
    SyncStatus? syncStatus,
    int? updatedAt,
    bool? isDeleted,
  }) {
    return NoteModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      colorValue: colorValue ?? this.colorValue,
      syncStatus: syncStatus ?? this.syncStatus,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}
