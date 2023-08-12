import 'package:flutter/material.dart';

class NewFile extends StatefulWidget {
  final Function(int, String) addf;
  NewFile(this.addf);
  
  @override
  State<NewFile> createState() => _NewFileState();
}

class _NewFileState extends State<NewFile> {
  final titleController = TextEditingController();
  int id = 1;
  void submitData() {
    String enteredTitle = titleController.text.trim();
    if (enteredTitle.isEmpty) {
      return;
    }
    enteredTitle = titleController.text + '.txt';
    widget.addf(id, enteredTitle);
    setState(() {
      id++;
    });
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            TextField(
              decoration: InputDecoration(labelText: "Enter File name"),
              controller: titleController,
              onSubmitted: (_) => submitData(),
            ),
            ElevatedButton(
                onPressed: submitData,
                child: Text("Create new File",
                    style: TextStyle(
                      color: Colors.white,
                    )),
                style: ButtonStyle(
                  foregroundColor:
                      MaterialStateProperty.all(Theme.of(context).primaryColor),
                ))
          ],
        ),
      ),
    );
  }
}
