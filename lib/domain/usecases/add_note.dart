import '../entities/note_entity.dart';
import '../repositories/note_repository.dart';

class AddNoteUseCase {
  final NoteRepository repo;
  AddNoteUseCase(this.repo);

  Future<void> call(NoteEntity note) async {
    await repo.addNote(note);
  }
}
