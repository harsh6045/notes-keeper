import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:sdp_2/myfile.dart';
import 'package:sdp_2/newfile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'addNotes.dart';
import 'file_entry.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'colors.dart';
import 'package:firebase_database/firebase_database.dart';

class File extends StatefulWidget {
  const File({super.key});

  @override
  State<File> createState() => _FileState();
}

class _FileState extends State<File> {
  int id = 1;
  String user = FirebaseAuth.instance.currentUser!.email.toString();
  final List<FileEntry> list = [];
  SpeechToText speechtotext = SpeechToText();
  var text = "";
  var msg = "Nothing to Show";
  var isListening = false;

// function to send Email.

  Future<Map<String, String>> getSharedPrefData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String title = prefs.getString('title') ?? "";
    String description = prefs.getString('description') ?? "";
    return {"title": title, "description": description};

    print("sssss"+title.toString());
  }
  void sendMail(int a) async {
    String str = "";
    for (var element in list) {
      if (element.id == a) {
        str = element.fname;
      }
    }

    try {
      final Email email = Email(
        body: str,
        subject: 'You got a note !',
        recipients: [user],
        cc: [],
        bcc: [],
        attachmentPaths: [],
        isHTML: false,
      );
      await FlutterEmailSender.send(email);
    } catch (e) {
      debugPrint('error sending email');
      print(e);
    }
  }

  // Function to add File.
  void addNewFile(int id, String name) {
    final FileEntry f = FileEntry(id, name);
    setState(() {
      list.add(f);
    });
  }

  // Function to Show Bottom Modal Sheet.
  void startAddingNewFile(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (_) {
          return NewFile(addNewFile);
        });
  }

  @override
  Widget build(BuildContext context) {
    var databaseref = FirebaseDatabase.instance.ref("notes");
    return Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            FloatingActionButton(
              onPressed: () => startAddingNewFile(context),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Icon(Icons.add),
                  ),
                  Text("Voice",style: TextStyle(fontSize: 12)),
                ],
              ),
              backgroundColor: bgColor,
            ),

            SizedBox(width: 5,),
            FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AddNote(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        title: "",
                        description: "",
                      )),
                );
              },
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Icon(Icons.add),
                  ),
                  Text("Text",style: TextStyle(fontSize: 12)),
                ],
              ),
              backgroundColor: bgColor,
            ),
            SizedBox(width: 5,),
          ],
        ),


        appBar: _buildAppBar(),
        // AppBar(
        //   actions: [
        //     IconButton(
        //         onPressed: () {
        //           FirebaseAuth.instance.signOut();
        //         },
        //         icon: Icon(Icons.logout)),
        //   ],
        //   centerTitle: true,
        //   backgroundColor: bgColor,
        //   elevation: 0.0,
        //   title: const Text(
        //     "Speech to Text",
        //     style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
        //   ),
        // ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                margin: EdgeInsets.only(bottom: 150),
                child: list.isEmpty
                    ? Text(
                        msg,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Colors.black54,
                        ),
                      )
                    : Column(
                      children: [
                        ListView.builder(
                            itemBuilder: (ctx, index) {
                              return Column(
                                children: [
                                  Container(
                                    height: 75,
                                    child: Card(
                                      elevation: 6.0,
                                      child: InkWell(
                                        child: ListTile(
                                          title: Text(list[index].fname),
                                          trailing: IconButton(
                                            onPressed: () => sendMail(list[index].id),
                                            icon: Icon(Icons.mail),
                                            color: Colors.amber,
                                          ),
                                        ),
                                        onTap: () {
                                          print("File is being tap");
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      MyFile(list[index].fname)));
                                        },
                                      ),
                                    ),
                                  ),

                                  Expanded(
                                    child: StreamBuilder(
                                        stream: databaseref.onValue,
                                        builder: (context, snapshot) {
                                          if (!snapshot.hasData ||
                                              snapshot.connectionState == ConnectionState.waiting) {
                                            return CircularProgressIndicator();
                                          } else {
                                            Map<dynamic, dynamic> map =
                                            snapshot.data!.snapshot.value as dynamic;

                                            List<dynamic> notes = [];
                                            notes.clear();
                                            notes = map.values.toList();
                                            return ListView.builder(
                                              itemCount: snapshot.data!.snapshot.children.length,
                                              itemBuilder: (context, index) {
                                                return GestureDetector(
                                                  onTap: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) => AddNote(
                                                            id: notes[index]["id"],
                                                            title: notes[index]["title"],
                                                            description: notes[index]["description"],
                                                          )),
                                                    );
                                                  },
                                                  child: Container(
                                                    height: 100,
                                                    margin: EdgeInsets.all(10),
                                                    padding: EdgeInsets.all(10),
                                                    decoration: BoxDecoration(
                                                        border:
                                                        Border.all(color: Colors.black.withOpacity(0.4)),
                                                        borderRadius: BorderRadius.circular(10)),
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          notes[index]["title"],
                                                          style: TextStyle(
                                                              fontSize: 16, fontWeight: FontWeight.bold),
                                                        ),
                                                        SizedBox(
                                                          height: 10,
                                                        ),
                                                        Text(
                                                          notes[index]['description'],
                                                          maxLines: 2,
                                                          overflow: TextOverflow.ellipsis,
                                                          style: TextStyle(
                                                              fontSize: 14, fontWeight: FontWeight.w500),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              },
                                            );
                                          }
                                        }),
                                  ),
                                ],
                              );
                            },
                            itemCount: list.length),
                        FutureBuilder<Map<String, String>>(
                          future: getSharedPrefData(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            } else if (snapshot.hasData) {
                              return Container(
                                height: 100,
                                margin: EdgeInsets.all(10),
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black.withOpacity(0.4)),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      snapshot.data!["title"]!,
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      snapshot.data!["description"]!,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                              );
                            } else {
                              return Container(); // Handle error or no data case
                            }
                          },
                        ),

                        // Your existing ListView.builder for Firebase data
                      ],
                    ),
              ),
            ],
          ),
        ));
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: mytdBGColor,
      elevation: 0,
      actions: [
        IconButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
            icon: Icon(
              Icons.logout,
              color: tdBlack,
            )),
      ],
      centerTitle: true,
      title: Text(
        'Speech to text',
        style: TextStyle(color: tdBlack, fontWeight: FontWeight.w600),
      ),
    );
  }
}
