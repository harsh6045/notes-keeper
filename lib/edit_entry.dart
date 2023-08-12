import 'package:flutter/material.dart';

class Edit extends StatefulWidget {
  final Function(int, String) modify;
  final String str;
  int a;
  Edit(this.modify, this.str, this.a);

  @override
  State<Edit> createState() => _EditState();
}

class _EditState extends State<Edit> {
  TextEditingController? titleController;
  void initState() {
    titleController = TextEditingController(text: widget.str);
  }

  void submitData() {
    String? enteredTitle = "${titleController?.text.trim()}\n";
    if (enteredTitle.isEmpty) {
      return;
    }
    widget.modify(widget.a, enteredTitle);
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
              // decoration: InputDecoration(labelText: "Enter File name"),
              controller: titleController,
              onSubmitted: (_) => submitData(),
            ),
            ElevatedButton(
                onPressed: submitData,
                child: Text("Submit",
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
