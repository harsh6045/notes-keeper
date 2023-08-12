import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:sdp_2/file_list.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddNote extends StatefulWidget {
  final String id;
  final String title;
  final String description;

  AddNote({required this.id, required this.title,required this.description});

  @override
  State<AddNote> createState() => _AddNoteState();
}

class _AddNoteState extends State<AddNote> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  var databaseref = FirebaseDatabase.instance.reference().child("notes");

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.title);
    _descriptionController = TextEditingController(text: widget.description);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> saveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('title', _titleController.text);
    await prefs.setString('description', _descriptionController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('Add Note'),
        backgroundColor: Color.fromARGB(255, 151, 156, 194),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _titleController,
              maxLines: 1,
              decoration: InputDecoration(labelText: 'Enter your note'),
            ),
            TextFormField(
              controller: _descriptionController,
              maxLines: 5,
              decoration: InputDecoration(labelText: 'Enter your note'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {

                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => File()),
                );

                await saveData();
                await databaseref.child(widget.id).set({
                  "id": widget.id,
                  "title": _titleController.text,
                  "description": _descriptionController.text,
                });
              },
              style: ElevatedButton.styleFrom(
                primary: Color.fromARGB(255, 151, 156, 194),
              ),
              child: Text('Save'),
            ),

          ],
        ),
      ),
    );
  }
}
