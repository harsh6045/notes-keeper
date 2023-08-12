// Only for reference for how to implement Speech to text
// Not used anywhere in the application
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'entry.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'colors.dart';
import 'package:avatar_glow/avatar_glow.dart';

class SpeechScreen extends StatefulWidget {
  const SpeechScreen({super.key});

  @override
  State<SpeechScreen> createState() => _SpeechScreenState();
}

class _SpeechScreenState extends State<SpeechScreen> {
  int id = 1;
  String user = FirebaseAuth.instance.currentUser!.email.toString();
  final List<DataEntry> list = [];
  SpeechToText speechtotext = SpeechToText();
  var text = "";
  var msg = "hold the button to speak";
  var isListening = false;

// function to send Email.
  void sendMail(int a) async {
    String str = "";
    for (var element in list) {
      if (element.id == a) {
        str = element.data;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: AvatarGlow(
          endRadius: 75.0,
          glowColor: bgColor,
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
                final d = DataEntry(id, text);
                setState(() {
                  list.add(d);
                  text = "";
                  id++;
                });
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
        appBar: AppBar(
          actions: [
            IconButton(
                onPressed: () {
                  FirebaseAuth.instance.signOut();
                },
                icon: Icon(Icons.logout)),
          ],
          centerTitle: true,
          backgroundColor: bgColor,
          elevation: 0.0,
          title: const Text(
            "Speech to Text",
            style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
          ),
        ),
        body: Container(
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
              : ListView.builder(
                  itemBuilder: (ctx, index) {
                    return Container(
                      height: 75,
                      child: Card(
                        elevation: 6.0,
                        child: InkWell(
                          child: ListTile(
                            title: Text(list[index].data),
                            trailing: IconButton(
                              onPressed: () => sendMail(list[index].id),
                              icon: Icon(Icons.mail),
                              color: Colors.amber,
                            ),
                          ),
                          onTap: () {
                            print("The file is being tapped");
                          },
                        ),
                      ),
                    );
                  },
                  itemCount: list.length),
        ));
  }
}
