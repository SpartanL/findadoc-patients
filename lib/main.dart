import 'package:flutter/material.dart';
import 'rdv_page.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FindADoc',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      	title: Text('FindADoc'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            DocSection(),
          ],
        ),
      ),
    );
  }
}

class DocSection extends StatefulWidget {
  @override
  _DocState createState() => _DocState();
}

class _DocState extends State<DocSection> {
  List _docData = [];

  @override
  void initState() {
    super.initState();
    _getDataFromFirestore();
  }

  void _getDataFromFirestore() async {
    QuerySnapshot querySnapshot =
      await FirebaseFirestore.instance.collection('doctors').get();
      List dataList = querySnapshot.docs.map((documentSnapshot) => documentSnapshot.data()).toList();

    setState(() {
      _docData = dataList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      child: Column(
        children: [
          Column(
            children: _docData.map((doc) {
              return DocCard(doc);
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class DocCard extends StatelessWidget {
  final Map docData;
  DocCard(this.docData);
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10),
      height: 120,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(
          Radius.circular(18),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            spreadRadius: 4,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            docData['prenom'] + ' ' + docData['nom'],
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 25
              ),
          ),
          Text(docData['domaine']),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: Colors.blue, // background
              onPrimary: Colors.white, // foreground
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RdvPage(doc: docData)),
              );
            },
            child: const Text('Prendre RDV'),
          )
      ]),
    );
  }
}