import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uas_ambw/models/note.dart';

import 'home_page.dart';

class NoteEditor extends StatefulWidget {
  final Note? note;

  NoteEditor({this.note});

  @override
  _NoteEditorState createState() => _NoteEditorState();
}

class _NoteEditorState extends State<NoteEditor> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  late Box<Note> noteBox;

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      titleController.text = widget.note!.title;
      contentController.text = widget.note!.content;
    }
    Hive.openBox<Note>('notes').then((box) {
      setState(() {
        noteBox = box;
      });
    });
  }

  void saveNote() {
    final title = titleController.text;
    final content = contentController.text;

    if (widget.note != null) {
      widget.note!.title = title;
      widget.note!.content = content;
      widget.note!.updatedAt = DateTime.now();
      widget.note!.save();
    } else {
      final newNote = Note(
        title: title,
        content: content,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      noteBox.add(newNote);
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note == null ? 'New Note' : 'Edit Note'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: saveNote,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                labelStyle: TextStyle(fontSize: 18),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.grey.shade200,
              ),
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 16),
            Expanded(
              child: TextField(
                controller: contentController,
                decoration: InputDecoration(
                  labelText: 'Content',
                  labelStyle: TextStyle(fontSize: 18),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade200,
                ),
                style: TextStyle(fontSize: 18),
                maxLines: null,
                expands: false,
                minLines: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
