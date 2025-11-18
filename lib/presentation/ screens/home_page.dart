import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/note_provider.dart';
import 'add_note_page.dart';
import '../../domain/entities/note_entity.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NoteProvider>(context, listen: false).loadNotes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NoteProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: const Text('Offline Note-Taking'),
            actions: [
              IconButton(
                iconSize: 28,
                padding: const EdgeInsets.all(4),
                onPressed: provider.isSyncing ? null : () async {
                  await provider.syncPending();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Sync attempted',textAlign: TextAlign.center),backgroundColor: Colors.green),
                    );
                  }
                },
                icon: provider.isSyncing
                    ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
                    : const Icon(Icons.sync),
              ),

              // 🔥 Theme toggle FIXED
              IconButton(
                iconSize: 28,
                padding: const EdgeInsets.all(4),
                icon: Icon(
                  provider.isDarkMode
                      ? Icons.dark_mode
                      : Icons.light_mode,
                ),
                onPressed: () => provider.toggleDarkMode(),
              ),
            ],
          ),

          body: RefreshIndicator(
            onRefresh: () async => await provider.loadNotes(),
            child: provider.notes.isEmpty
                ? ListView(
              children: const [
                SizedBox(height: 200),
                Center(child: Text('No notes')),
              ],
            )
                : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: provider.notes.length,
              itemBuilder: (context, i) {
                final NoteEntity n = provider.notes[i];
                return Card(
                  color: Color(n.colorValue),
                  child: ListTile(
                    leading: _statusIcon(n.syncStatus),

                    title: Text(
                      n.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      n.content,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    trailing: PopupMenuButton<String>(
                      iconSize: 28,
                      padding: EdgeInsets.zero,
                      onSelected: (v) async {
                        if (v == 'edit') {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AddNotePage(editNote: n),
                            ),
                          );
                          await provider.loadNotes();
                        } else if (v == 'delete') {
                          await provider.deleteNote(n.id);
                        }
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: 'edit', child: Text('Edit')),
                        PopupMenuItem(value: 'delete', child: Text('Delete')),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddNotePage()),
              );

              if (result == true && mounted) {
                await Provider.of<NoteProvider>(context, listen: false).loadNotes();
              }
            },
            child: const Icon(Icons.add, size: 28),
          ),

        );
      },
    );
  }

  // 🔥 Status icon FIXED
  Widget _statusIcon(SyncStatus status) {
    const double size = 28;
    switch (status) {
      case SyncStatus.synced:
        return const Icon(Icons.cloud_done, color: Colors.green, size: size);
      case SyncStatus.syncing:
        return const Icon(Icons.cloud_upload, color: Colors.blue, size: size);
      case SyncStatus.pending:
        return const Icon(Icons.cloud_off, color: Colors.orange, size: size);
      case SyncStatus.failed:
        return const Icon(Icons.error, color: Colors.red, size: size);
    }
  }
}
