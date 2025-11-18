import '../entities/note_entity.dart';
import '../repositories/note_repository.dart';

class UpdateNoteUseCase {
  final NoteRepository repo;

  UpdateNoteUseCase(this.repo);

  Future<void> call(NoteEntity note) async {
    await repo.updateNote(note);
  }
}
