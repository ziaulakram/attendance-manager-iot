import 'package:attendance/screen/ViewAttendance.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MarkAttendancePage extends StatefulWidget {
  final String ename;
  final String eid;


  const MarkAttendancePage({Key? key, required this.ename, required this.eid})
      : super(key: key);

  @override
  State<MarkAttendancePage> createState() => _MarkAttendancePageState();
}

class _MarkAttendancePageState extends State<MarkAttendancePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _rnoController = TextEditingController();
  final CollectionReference _data =
      FirebaseFirestore.instance.collection("attendance");

  Future<void> _createOrUpdate([DocumentSnapshot? documentSnapshot]) async {
    String action = 'create';

    if (documentSnapshot != null) {
      action = 'update';
      _nameController.text = documentSnapshot['name'];
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
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                const SizedBox(
                  height: 10,
                ),
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
                    final String? name = _nameController.text;
                    final String? rno = _rnoController.text;
                    //final user = FirebaseAuth.instance.currentUser!;
                    final eid = widget.eid;
                    if (name != null && rno != null) {
                      if (action == 'create') {
                        // Persist a new product to Firestore
                        // inputData(action);
                        await _data
                            .add({"name": name, "rno": rno, "eventid": eid});
                      }

                      if (action == 'update') {
                        // Update the product
                        await _data
                            .doc(documentSnapshot!.id)
                            .update({"name": name, "rno": rno});
                      }

                      // Clear the text fields
                      _nameController.text = '';
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
    final eid = widget.eid;
    // final user = FirebaseAuth.instance.currentUser!;
    return Scaffold(
      appBar: AppBar(
        title: Text(event.toUpperCase()),
        backgroundColor: Colors.indigo[900],
        actions: [
          IconButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: StreamBuilder(
        stream: _data.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
          if (streamSnapshot.hasData) {
            return ListView.builder(
              itemCount: streamSnapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final DocumentSnapshot documentSnapshot =
                    streamSnapshot.data!.docs[index];
                return Card(

                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (context)=>ViewAttendancePage(ename: widget.ename,edate: documentSnapshot.id)));
                      // navigatorKey.currentState!.pushNamed('/event',
                      //     arguments: documentSnapshot.id);
                    },
                    title: Text(documentSnapshot.id, style: const TextStyle(fontSize: 16, ),),
                    // subtitle: Text(documentSnapshot['rno']),
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
                );
              },
            );
          }

          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
      // floatingActionButton: FloatingActionButton(
      //   backgroundColor: Colors.deepPurpleAccent[100],
      //   onPressed: () => _createOrUpdate(),
      //   child: const Icon(Icons.add),
      // ),
    );
  }
}
