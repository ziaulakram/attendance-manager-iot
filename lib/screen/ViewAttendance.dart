// import 'dart:io' as io;
// import 'package:pdf/widgets.dart' as pw;
import 'package:attendance/auth.dart';
import 'package:attendance/screen/login.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'imgViewer.dart';
import 'package:intl/intl.dart';
// import 'package:path_provider/path_provider.dart';
import 'pdfgen.dart';
// import 'package:attendance/auth.dart';


class ViewAttendancePage extends StatefulWidget {
  final String ename;
  final String edate;

  const ViewAttendancePage({Key? key, required this.ename, required this.edate})
      : super(key: key);

  @override
  State<ViewAttendancePage> createState() => _ViewAttendancePageState();
}

class _ViewAttendancePageState extends State<ViewAttendancePage> {
  // final TextEditingController _timeController = TextEditingController();
  final TextEditingController _rnoController = TextEditingController();
  // final TextEditingController _enameController = TextEditingController();
  // final TextEditingController _presentController = TextEditingController();
  final CollectionReference _data =
      FirebaseFirestore.instance.collection("attendance");
  Map<String, String> data = {};
  // List<String> data=[];
  // List<String> dataTime=[];
//   Future<void> generatePdf() async {
//     final pdf = pw.Document();
// // build your pdf view here
//     print(data);
//     pdf.addPage(
//       pw.Page(
//         build: (pw.Context context) => pw.Center(
//           child: pw.Text("Hello"),
//         ),
//       ),
//     );
// //save pdf
//     final output = await getExternalStorageDirectory();
//     final path = "${output?.path}/Report.pdf";
//     print(path);
//     final file = await io.File(path).writeAsBytes(await pdf.save());
//     final file = File("example.pdf");
//     await file.writeAsBytes(await pdf.save());
//   }
  Future<void> _createOrUpdate([DocumentSnapshot? documentSnapshot]) async {
    String action = 'create';

    if (documentSnapshot != null) {
      action = 'update';
      // _timeController.text = documentSnapshot['time'];
      _rnoController.text = documentSnapshot['rno'];
    }

    await showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext ctx) {
          return Padding(
            padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                // prevent the soft keyboard from covering text fields
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _rnoController,
                  decoration: const InputDecoration(labelText: 'ID No.'),
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  child: Text(action == 'create' ? 'Create' : 'Update'),
                  onPressed: () async {
                    final DateTime now = DateTime.now();
                    final DateFormat formatter = DateFormat('H:m');
                    final String formatted = formatter.format(now);
                    // final String? time = TimeOfDay.fromDateTime(DateTime.now()).format(context);
                    final String? rno = _rnoController.text;
                    final String? ename = widget.ename;
                    final String? isPresent = 'true';
                    final String? img = null;
                    //final user = FirebaseAuth.instance.currentUser!;
                    final edate = widget.edate;
                    if (rno != null) {
                      if (action == 'create') {
                        // Persist a new product to Firestore
                        // inputData(action);
                        await _data
                            .doc(widget.edate)
                            .collection(widget.ename)
                            .doc(rno)
                            .set({
                          "imgUrl": '',
                          "rno": rno,
                          "eventName": ename,
                          "isPresent": isPresent,
                          "time": formatted,
                          "id": "",
                          "uid": user.uid,
                        });
                      }

                      if (action == 'update') {
                        // Update the product
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Attendance Already Marked')));
                      }

                      // Clear the text fields

                      _rnoController.text = '';

                      // Hide the bottom sheet
                      Navigator.of(context).pop();
                    }
                  },
                )
              ],
            ),
          );
        });
  }

  // Deleteing
  Future<void> _delete(String participantName) async {
    await _data.doc(participantName).delete();

    // Show a snackbar
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Successfully deleted')));
  }

  final user = FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context) {
    final event = widget.ename;
    // final data=_data.doc(widget.edate).collection(widget.ename).where("eventName", isEqualTo: widget.ename).snapshots();
    //final eid = widget.eid;
    // final user = FirebaseAuth.instance.currentUser!;
    return Scaffold(
        appBar: AppBar(
          title: Text(event.toUpperCase()),
          backgroundColor: Colors.indigo[900],
          actions: [
            IconButton(
              onPressed: () {
                FirebaseAuth.instance.signOut();
                // Navigator.of(context).pushAndRemoveUntil(
                //     MaterialPageRoute(
                //         builder: (context) => AuthPage()),
                //         (route) => false);
              },
              icon: const Icon(Icons.logout),
            )
          ],
        ),
        body: StreamBuilder(
          stream: _data
              .doc(widget.edate)
              .collection(widget.ename)
              .where("eventName", isEqualTo: widget.ename).where("uid", isEqualTo: user.uid)
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
            if (streamSnapshot.hasData) {
              return ListView.builder(
                itemCount: streamSnapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final DocumentSnapshot documentSnapshot =
                      streamSnapshot.data!.docs[index];
                  data.putIfAbsent(documentSnapshot['rno'], () => documentSnapshot['time']);
                  // data.add(documentSnapshot['rno']);
                  // dataTime.add(documentSnapshot['time']);
                  return Card(
                    margin: const EdgeInsets.all(10),
                    child: Column(
                      children: [
                        ListTile(
                          leading: GestureDetector(
                            child: Hero(
                              tag: documentSnapshot['rno'],
                              child: documentSnapshot['imgUrl'].toString() != ''
                                  ? Image.network(
                                      documentSnapshot['imgUrl'],
                                      width: 100,
                                      height: 100,
                                    )
                                  : Image.asset(
                                      'assets/images/unavailable.gif',
                                      width: 100,
                                      height: 100,
                                    ),
                            ),
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => FullScreenImagePage(
                                            imgUrl: documentSnapshot['imgUrl']
                                                        .toString() !=
                                                    ''
                                                ? documentSnapshot['imgUrl']
                                                : '',
                                          )));
                            },
                          ),
                          title: Text(
                            "Roll No: " +
                                documentSnapshot['rno']
                                    .toString()
                                    .toUpperCase(),
                            style: const TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Text("Time: " + documentSnapshot['time']),
                          //  trailing: IconButton(
                          //   icon: const Icon(Icons.check, color: Colors.grey,),
                          //   onPressed: () {
                          //     setState(() {
                          //       ScaffoldMessenger.of(context)
                          //           .showSnackBar(const SnackBar(content: Text('Attendance Marked')));
                          //     });
                          //   },
                          // ),
                        ),
                      ],
                    ),
                  );
                },
              );
            }

            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              FloatingActionButton(
                backgroundColor: Colors.deepPurpleAccent[100],
                onPressed: () {
                  _createOrUpdate();
                },
                child: Icon(Icons.add),
              ),
              SizedBox.square(
                dimension: 15,
              ),
              FloatingActionButton(
                // backgroundColor: Colors.deepPurpleAccent[100],
                onPressed: () {
                  Future<int> flag=generatePdf(data,widget.ename,widget.edate);
                  if(flag==1) {
                    data.clear();
                    // dataTime.clear();
                  }
                },
                child: Icon(Icons.download),
              )
            ],
          ),
        )
        // floatingActionButton: FloatingActionButton(
        //   backgroundColor: Colors.deepPurpleAccent[100],
        //   onPressed: () => _createOrUpdate(),
        //   child: const Icon(Icons.add),
        // ),
        );
  }
}

