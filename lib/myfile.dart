import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sdp_2/edit_entry.dart';
import 'package:sdp_2/notification.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'colors.dart';
import 'dart:io';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:path_provider/path_provider.dart';

class MyFile extends StatefulWidget {
  String fname;
  MyFile(this.fname);

  @override
  State<MyFile> createState() => _MyFileState();
}

class _MyFileState extends State<MyFile> {
  String user = FirebaseAuth.instance.currentUser!.email.toString();
  final List<String> list = [];
  List<String> _foundList = [];
  SpeechToText speechtotext = SpeechToText();
  var text = "";
  var msg = "Nothing to show";
  var isListening = false;
  NotificationServices notificationServices = NotificationServices();

  @override
  void initState() {
    _foundList = list;
    super.initState();
    notificationServices.initializeNotifications();
  }

  void applyModification(int a, String str) {
    setState(() {
      list[a] = str;
    });
  }

  void editNote(int id, BuildContext context) {
    String editstr = list[id];
    showModalBottomSheet(
        context: context,
        builder: (_) {
          return Edit(applyModification, editstr, id);
        });
  }

  void sendMail() async {
    String str = "";
    for (var element in list) {
      str += element;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: tdBGColor,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: AvatarGlow(
        endRadius: 75.0,
        glowColor: Colors.blue,
        repeat: true,
        repeatPauseDuration: Duration(microseconds: 100),
        showTwoGlows: true,
        animate: isListening,
        duration: Duration(milliseconds: 2000),
        child: GestureDetector(
          onTapDown: (details) async {
            if (!isListening) {
              var available = await speechtotext.initialize();
              if (available) {
                setState(() {
                  isListening = true;
                  speechtotext.listen(
                    onResult: (result) {
                      setState(() {
                        text = result.recognizedWords;
                      });
                    },
                  );
                });
              }
            }
          },
          onTapUp: ((details) {
            setState(() {
              isListening = false;
            });
            speechtotext.stop();
            if (!text.isEmpty) {
              String d = "• $text\n";
              setState(() {
                list.add(d);
                text = "";
              });
              notificationServices.scheduleNotification(
                  'msg from speech notes', text);
            }
          }),
          child: CircleAvatar(
            backgroundColor: bgColor,
            radius: 35,
            child: Icon(
              isListening ? Icons.mic : Icons.mic_none,
              color: Colors.white,
            ),
          ),
        ),
      ),
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 15,
            ),
            child: Column(
              children: [
                searchBox(),
                Container(
                  margin: EdgeInsets.only(
                    top: 30,
                    bottom: 10,
                    right: 160,
                  ),
                  child: Text(
                    'All ToDos',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  child: list.isEmpty
                      ? Container(
                          margin: EdgeInsets.only(
                            top: 150,
                          ),
                          child: Text(
                            msg,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: Colors.black54,
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemBuilder: (ctx, index) {
                            return Card(
                              child: ListTile(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                leading: IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () => editNote(index, context),
                                ),
                                title: Container(
                                  height: 50,
                                  child: Text(_foundList[index],
                                      style: TextStyle(
                                        fontSize: 20,
                                      )),
                                ),
                                trailing: Container(
                                  height: 35,
                                  width: 35,
                                  decoration: BoxDecoration(
                                    color: tdRed,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: IconButton(
                                    iconSize: 18,
                                    icon: Icon(
                                      Icons.delete,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        list.removeWhere((element) =>
                                            element == list[index]);
                                      });
                                    },
                                  ),
                                ),
                              ),
                            );
                          },
                          itemCount: _foundList.length),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: mytdBGColor,
      elevation: 0,
      actions: [
        IconButton(
            onPressed: sendMail,
            icon: Icon(
              Icons.mail,
              color: Colors.amber,
            )),
      ],
      centerTitle: true,
      title: Text(
        widget.fname,
        style: TextStyle(color: tdBlack, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget searchBox() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        onChanged: (value) => _runFilter(value),
        autofocus: false,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.all(0),
          prefixIcon: Icon(
            Icons.search,
            color: tdBlack,
            size: 20,
          ),
          prefixIconConstraints: BoxConstraints(
            maxHeight: 20,
            minWidth: 25,
          ),
          border: InputBorder.none,
          hintText: 'Search',
          hintStyle: TextStyle(color: tdGrey),
        ),
      ),
    );
  }

  void _runFilter(String enteredKeyword) {
    List<String> results = [];
    if (enteredKeyword.isEmpty) {
      results = list;
    } else {
      results = list
          .where((item) =>
              item.toLowerCase().contains(enteredKeyword.toLowerCase()))
          .toList();
    }
    setState(() {
      _foundList = results;
    });
  }
}



      //appbar :  AppBar(
      //   actions: [
      //     IconButton(
      //         onPressed: sendMail,
      //         icon: Icon(
      //           Icons.mail,
      //           color: Colors.amber,
      //         )),
      //   ],
      //   centerTitle: true,
      //   backgroundColor: bgColor,
      //   elevation: 0.0,
      //   title: Text(
      //     widget.fname,
      //     style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
      //   ),
      // ),

      // body :Container(
      //   alignment: Alignment.center,
      //   padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      //   margin: EdgeInsets.only(bottom: 150),
      //   child: list.isEmpty
      //       ? Text(
      //           msg,
      //           style: const TextStyle(
      //             fontSize: 24,
      //             fontWeight: FontWeight.w600,
      //             color: Colors.black54,
      //           ),
      //         )
      //       : ListView.builder(
      //           itemBuilder: (ctx, index) {
      //             return Container(
      //               // height: 75,
      //               decoration: BoxDecoration(
      //                 border: Border.all(width: 1.0),
      //                 borderRadius: BorderRadius.all(Radius.circular(2)),
      //               ),
      //               child: ListTile(
      //                 title: Text(list[index],
      //                     style: TextStyle(
      //                       fontSize: 20,
      //                     )),
      //                 trailing: IconButton(
      //                   icon: Icon(
      //                     Icons.delete,
      //                     color: Colors.red,
      //                   ),
      //                   onPressed: () {
      //                     setState(() {
      //                       list.removeWhere(
      //                           (element) => element == list[index]);
      //                     });
      //                   },
      //                 ),
      //               ),
      //             );
      //           },
      //           itemCount: list.length),
      // ),

