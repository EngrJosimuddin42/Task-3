enum SyncStatus { pending, syncing, synced, failed }

class NoteEntity {
  final String id;
  final String title;
  final String content;
  final int colorValue;
  final SyncStatus syncStatus;
  final int updatedAt;
  final bool isDeleted;

  NoteEntity({
    required this.id,
    required this.title,
    required this.content,
    required this.colorValue,
    required this.syncStatus,
    required this.updatedAt,
    this.isDeleted = false,
  });

  NoteEntity copyWith({
    String? id,
    String? title,
    String? content,
    int? colorValue,
    SyncStatus? syncStatus,
    int? updatedAt,
    bool? isDeleted,
  }) {
    return NoteEntity(
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
