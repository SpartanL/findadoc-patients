import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_field/date_field.dart';

class RdvPage extends StatelessWidget {
  const RdvPage({super.key, required this.doc});
  final doc;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            MyForm(doc)
          ],
        ),
      ),
    );
  }
}

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  Size get preferredSize => new Size.fromHeight(60);
  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: Colors.white,
          size: 20,
        ),
        onPressed: () {
          Navigator.of(context, rootNavigator: true).pop(context);
        },
      ),
      title: Text('Prendre un RDV'),
    );
  }
}

class MyForm extends StatefulWidget {
  final doc;
  MyForm(this.doc);

  @override
  _MyFormState createState() => _MyFormState();
}

class _MyFormState extends State<MyForm> {
  final _formKey = GlobalKey<FormState>();
  String _firstName = '';
  String _lastName = '';
  int _age = 0;
  String _gender = 'Homme';
  DateTime _date = DateTime.now();

  final List<String> _genders = ['Homme', 'Femme'];

  final CollectionReference appointmentsCollection = FirebaseFirestore.instance.collection('appointments');

  Future<void> addAppointment(String firstName, String lastName, int age, String gender, DateTime date) {
    // Ajoutez un document à la collection users
    return appointmentsCollection
        .add({
          'prenom': firstName,
          'nom': lastName,
          'age': age,
          'sexe': gender,
          'doctor': {
            'prenom': widget.doc['prenom'],
            'nom': widget.doc['nom'],
            'domaine': widget.doc['domaine']
          },
          'date': date
        })
        .then((value) => Navigator.pop(context))
        .catchError((error) => print('Erreur lors de l\'ajout du rdv : $error'));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Prénom',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer votre prénom.';
                }
                return null;
              },
              onSaved: (value) {
                _firstName = value!;
              },
            ),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Nom',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer votre nom.';
                }
                return null;
              },
              onSaved: (value) {
                _lastName = value!;
              },
            ),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Âge',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer votre âge.';
                }
                if (int.tryParse(value) == null) {
                  return 'Veuillez entrer un nombre valide.';
                }
                return null;
              },
              onSaved: (value) {
                _age = int.parse(value!);
              },
            ),
            DropdownButtonFormField(
              decoration: InputDecoration(
                labelText: 'Sexe',
              ),
              items: _genders.map((gender) {
                return DropdownMenuItem(
                  value: gender,
                  child: Text(gender),
                );
              }).toList(),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez choisir votre sexe.';
                }
                return null;
              },
              onChanged: (value) {
                setState(() {
                  _gender = value as String;
                });
              },
              onSaved: (value) {
                _gender = value as String;
              },
              value: _gender,
            ),
            Container(
              margin: EdgeInsets.only(top: 20),
              child: DateTimeFormField(
                decoration: const InputDecoration(
                  hintStyle: TextStyle(color: Colors.black45),
                  errorStyle: TextStyle(color: Colors.redAccent),
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.event_note),
                  labelText: 'Choisir une date',
                ),
                firstDate: DateTime.now(),
                validator: (value) {
                  if (value == null) {
                    return 'Veuillez choisir une date.';
                  }
                  return null;
                },
                onDateSelected: (DateTime value) {
                  setState(() {
                    _date = value;
                  });
                },
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  // Enregistrer les données dans Firestore
                  addAppointment(_firstName, _lastName, _age, _gender, _date);
                }
              },
              child: Text('Valider'),
            ),
          ],
        ),
      ),
    );
  }
}