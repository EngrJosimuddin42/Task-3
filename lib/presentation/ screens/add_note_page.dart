import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/note_provider.dart';
import '../../domain/entities/note_entity.dart';

class AddNotePage extends StatefulWidget {
  final NoteEntity? editNote;
  const AddNotePage({super.key, this.editNote});

  @override
  State<AddNotePage> createState() => _AddNotePageState();
}

class _AddNotePageState extends State<AddNotePage> {
  final _title = TextEditingController();
  final _content = TextEditingController();
  int _color = 0xFFFFF59D;
  bool _isSaving = false;

  final List<int> _colors = [
    0xFFFFF59D, 0xFFFFCC80, 0xFFB39DDB,
    0xFF80DEEA, 0xFFB2DFDB, 0xFFFFCDD2, 0xFFFFFFFF,
  ];

  @override
  void initState() {
    super.initState();
    if (widget.editNote != null) {
      _title.text = widget.editNote!.title;
      _content.text = widget.editNote!.content;
      _color = widget.editNote!.colorValue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<NoteProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.editNote == null ? 'Add Note' : 'Edit Note'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            TextField(controller: _title, decoration: const InputDecoration(labelText: 'Title')),
            const SizedBox(height: 8),
            TextField(controller: _content, decoration: const InputDecoration(labelText: 'Content'), minLines: 4, maxLines: null),
            const SizedBox(height: 12),
            SizedBox(
              height: 48,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemBuilder: (_, i) {
                  final c = _colors[i];
                  return GestureDetector(
                    onTap: () => setState(() => _color = c),
                    child: Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        color: Color(c),
                        shape: BoxShape.circle,
                        border: _color == c ? Border.all(width: 3, color: Colors.black) : null,
                      ),
                    ),
                  );
                },
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemCount: _colors.length,
              ),
            ),

            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: _isSaving ? null : () async {
                final title = _title.text.trim();
                final content = _content.text.trim();
                if(title.isEmpty && content.isEmpty){
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Empty note')));
                  return;
                }

                setState(() => _isSaving = true);

                if(widget.editNote == null){
                  await provider.addNote(title, content, _color);
                } else {
                  final updated = widget.editNote!.copyWith(
                    title: title, content: content, colorValue: _color,
                    updatedAt: DateTime.now().millisecondsSinceEpoch,
                    syncStatus: SyncStatus.pending,
                  );
                  await provider.updateNote(updated);
                }

                if(!mounted) return;

                Navigator.pop(context,true);
              },
              child: _isSaving
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
