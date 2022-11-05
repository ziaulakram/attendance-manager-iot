import 'package:attendance/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'event.dart';
import 'markattendance.dart';



class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();

}

class _HomeState extends State<Home> {
  int selectedIndex = 0;
  PageController pgController = PageController();

  // final FirebaseAuth auth = FirebaseAuth.instance;
  // final User? user = auth.currentUser;
  // final uid = user?.uid;
  // void inputData(String action) async {
  //   final User? user = auth.currentUser;
  //   final uid = user?.uid;
  //   // here you write the codes to input the data into firestore
  //   final CollectionReference _data = FirebaseFirestore.instance.collection('users').doc(uid).collection("events");
  //   if (action == 'create') {
  //     // Persist a new product to Firestore
  //     // await _data.add({"name": name});
  //   }
  //   if (action == 'update') {
  //     // Update the product
  //     // await _data
  //     //     .doc(documentSnapshot!.id)
  //     //     .update({"name": name});
  //   }
  // }
  // text fields' controllers
  final TextEditingController _nameController = TextEditingController();
  final user = FirebaseAuth.instance.currentUser!;
  // final uid = FirebaseAuth.instance.currentUser!.uid;
  // final CollectionReference _data = FirebaseFirestore.instance.collection('users').doc('user').collection("events");
  final CollectionReference _data = FirebaseFirestore.instance.collection("events");
  // This function is triggered when the floating button or one of the edit buttons is pressed
  // Adding a product if no documentSnapshot is passed
  // If documentSnapshot != null then update an existing product
  Future<void> _createOrUpdate([DocumentSnapshot? documentSnapshot]) async {
    String action = 'create';
    // final User? user = auth.currentUser;
    // final uid = user?.uid;
    if (documentSnapshot != null) {
      action = 'update';
      _nameController.text = documentSnapshot['name'];
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
                  height: 20,
                ),
                ElevatedButton(
                  child: Text(action == 'create' ? 'Create' : 'Update'),
                  onPressed: () async {
                    final String? name = _nameController.text;
                    final user = FirebaseAuth.instance.currentUser!;
                    // final User? user = auth.currentUser;
                    // final uid = user?.uid;
                    if (name != null) {
                      if (action == 'create') {
                        // Persist a new product to Firestore
                        // inputData(action);
                        await _data.add({"name": name, "coordinator": user.uid});
                      }

                      if (action == 'update') {
                        // Update the product
                        await _data
                            .doc(documentSnapshot!.id)
                            .update({"name": name});
                      }

                      // Clear the text fields
                      _nameController.text = '';

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

  // Deleteing a product by id
  Future<void> _delete(String eventName) async {
    // final User? user = auth.currentUser;
    // final uid = user?.uid;
    await _data.doc(eventName).delete();

    // Show a snackbar
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Successfully deleted')));
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Manager'),
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
      body:
      PageView(
        controller: pgController,
        children: [

          Scaffold(
            body: StreamBuilder(
              stream: _data.where("coordinator", isEqualTo: user.uid).snapshots(),
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
                            Navigator.of(context).push(MaterialPageRoute(builder: (context)=>MarkAttendancePage(ename: documentSnapshot['name'],eid: documentSnapshot.id,)));
                            // navigatorKey.currentState!.pushNamed('/event',
                            //     arguments: documentSnapshot.id);
                          },
                          title: Text(documentSnapshot['name'].toString().toUpperCase()),
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
          ),
          Scaffold(
            body: StreamBuilder(
              stream: _data.where("coordinator", isEqualTo: user.uid).snapshots(),
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
                          // onTap: () {
                          //   Navigator.of(context).push(MaterialPageRoute(builder: (context)=>EventPage(ename: documentSnapshot['name'],eid: documentSnapshot.id,)));
                          //   // navigatorKey.currentState!.pushNamed('/event',
                          //   //     arguments: documentSnapshot.id);
                          // },
                          title: Text(documentSnapshot['name'].toString().toUpperCase()),
                          trailing: SizedBox(
                            width: 100,
                            child: Row(
                              children: [
                                // Press this button to edit
                                IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () =>
                                        _createOrUpdate(documentSnapshot)),
                                IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () => _delete(documentSnapshot.id)),
                              ],
                            ),
                          ),
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
            floatingActionButton: FloatingActionButton(
              backgroundColor: Colors.deepPurpleAccent[100],
              onPressed: () => _createOrUpdate(),
              child: const Icon(Icons.add),
            ),
          ),
          // Container(
          //   child: const Center(
          //     child: Text('Page 3'),
          //   ),
          // ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) {
          setState(() {
            selectedIndex = index;
            pgController.animateToPage(index,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeIn);
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'Add Event',
          ),
          // BottomNavigationBarItem(
          //     icon: Icon(Icons.person_add),
          //     label: 'Add Participants'
          // ),
        ],
        selectedItemColor: Colors.indigo[900],
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
      ),
    );
  }


}
