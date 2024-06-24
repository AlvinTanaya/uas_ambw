import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uas_ambw/models/note.dart';
import 'package:uas_ambw/services/pin_handler.dart';

import 'note_detail.dart';
import 'note_editor.dart';
import 'pin_change.dart';
import 'pin_login.dart';
import 'pin_setup.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<Box<Note>> noteBoxFuture;

  @override
  void initState() {
    super.initState();
    noteBoxFuture = Hive.openBox<Note>('notes');
  }

  void _logout(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => PinLogin()),
      (route) => false,
    );
  }

  void _deletePin(BuildContext context) async {
    await PinHandler.deletePin();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => PinSetup()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notes'),
        automaticallyImplyLeading: false,
        actions: [
          PopupMenuButton<String>(
            onSelected: (String value) {
              switch (value) {
                case 'edit_pin':
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PinChange()),
                  );
                  break;
                case 'delete_pin':
                  _deletePin(context);
                  break;
                case 'logout':
                  _logout(context);
                  break;
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<String>(
                  value: 'edit_pin',
                  child: Text('Edit PIN'),
                ),
                PopupMenuItem<String>(
                  value: 'delete_pin',
                  child: Text('Delete PIN'),
                ),
                PopupMenuItem<String>(
                  value: 'logout',
                  child: Text('Logout'),
                ),
              ];
            },
          ),
        ],
      ),
      body: FutureBuilder<Box<Note>>(
        future: noteBoxFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final noteBox = snapshot.data!;
            return ValueListenableBuilder(
              valueListenable: noteBox.listenable(),
              builder: (context, Box<Note> notes, _) {
                if (notes.isEmpty) {
                  return Center(child: Text('No notes yet.'));
                }
                return GridView.builder(
                  padding: EdgeInsets.all(10),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1,
                  ),
                  itemCount: notes.length,
                  itemBuilder: (context, index) {
                    Note? note = notes.getAt(index);
                    if (note == null) {
                      return Container();
                    }
                    return GestureDetector(
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NoteDetail(
                              note: note,
                              onDelete: () {
                                notes.deleteAt(index);
                              },
                            ),
                          ),
                        );
                        if (result == true) {
                          setState(() {});
                        }
                      },
                      child: Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        color: Colors.purpleAccent.shade200,
                        child: Padding(
                          padding: EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                note.title,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 5),
                              Expanded(
                                child: Text(
                                  note.content,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 4,
                                  style: TextStyle(fontSize: 14),
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                'Created: ${note.createdAt.day}/${note.createdAt.month}/${note.createdAt.year} ${note.createdAt.hour}:${note.createdAt.minute}:${note.createdAt.second}',
                                style: TextStyle(
                                    fontSize: 11, color: Colors.white),
                              ),
                              Text(
                                'Updated: ${note.updatedAt.day}/${note.updatedAt.month}/${note.updatedAt.year} ${note.updatedAt.hour}:${note.updatedAt.minute}:${note.updatedAt.second}',
                                style: TextStyle(
                                    fontSize: 11, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NoteEditor(),
            ),
          );
          if (result == true) {
            setState(() {});
          }
        },
        child: Icon(Icons.add),
        backgroundColor: Color.fromARGB(255, 208, 11, 169),
      ),
    );
  }
}
