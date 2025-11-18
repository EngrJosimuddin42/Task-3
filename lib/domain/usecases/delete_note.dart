import '../repositories/note_repository.dart';

class DeleteNoteUseCase {
  final NoteRepository repo;

  DeleteNoteUseCase(this.repo);

  Future<void> call(String id) async {
    await repo.deleteNote(id);
  }
}
