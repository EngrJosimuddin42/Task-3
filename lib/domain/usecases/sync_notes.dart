import '../repositories/note_repository.dart';

class SyncNotesUseCase {
  final NoteRepository repo;

  SyncNotesUseCase(this.repo);

  Future<void> call() async {
    await repo.syncNotes();
  }
}
