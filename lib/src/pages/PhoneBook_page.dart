import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PhonebookPage extends StatefulWidget {
  const PhonebookPage({super.key});

  @override
  State<PhonebookPage> createState() => _PhonebookPageState();
}

class _PhonebookPageState extends State<PhonebookPage> {
  List<Contact> _contacts = [];
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    // final prefs = await SharedPreferences.getInstance();
    // final data = prefs.getString('contacts');
    // if (data != null) {
    //   final List decoded = jsonDecode(data);
    //   setState(() {
    //     _contacts = decoded.map((e) => Contact.fromJson(e)).toList();
    //   });
    // }

    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('contacts');

    List<Contact> contacts = [];

    if (data != null) {
      final List decoded = jsonDecode(data);
      contacts = decoded.map((e) => Contact.fromJson(e)).toList();
    }

    // Check if default contact already exists
    bool hasDefault = contacts.any((c) => c.name == 'John Doe' && c.phone == '+91 1234567890');
    if (!hasDefault) {
      // Add default contact
      contacts.insert(
        0,
        Contact(
          name: 'Jigar Patel',
          phone: '+91 9854756523',
          notes: 'Good Listener',
        ),
      );
      contacts.insert(
        1,
        Contact(
          name: 'Keyur Shah',
          phone: '+91 9987562140',
          notes: 'He is Engineer',
        ),
      );

      // Save updated list to SharedPreferences
      final String encoded = jsonEncode(contacts.map((e) => e.toJson()).toList());
      await prefs.setString('contacts', encoded);
    }

    setState(() {
      _contacts = contacts;
    });
  }

  Future<void> _saveContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode(_contacts.map((e) => e.toJson()).toList());
    await prefs.setString('contacts', data);
  }

  void _addOrEditContact({Contact? contact, int? index}) {
    if (contact != null) {
      _nameCtrl.text = contact.name;
      _phoneCtrl.text = contact.phone;
      _notesCtrl.text = contact.notes;
    } else {
      _nameCtrl.clear();
      _phoneCtrl.clear();
      _notesCtrl.clear();
    }

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            title: Text(contact == null ? 'Add Contact' : 'Edit Contact'),
            content: SizedBox(
              width: 400, // 👈 fixed width
              height: 250, // 👈 fixed height
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _notesCtrl,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Notes',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColorLight,
                  foregroundColor: Colors.white,
                  elevation: 3,
                  // optional shadow
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8), // rounded corners
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                onPressed: () {
                  if (_nameCtrl.text.trim().isEmpty || _phoneCtrl.text.trim().isEmpty) return;

                  final newContact = Contact(
                    name: _nameCtrl.text.trim(),
                    phone: _phoneCtrl.text.trim(),
                    notes: _notesCtrl.text.trim(),
                  );

                  setState(() {
                    if (contact == null) {
                      _contacts.add(newContact);
                    } else {
                      _contacts[index!] = newContact;
                    }
                  });

                  _saveContacts();
                  Navigator.pop(context);
                },
                child: Text(contact == null ? 'Add' : 'Update'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // appBar: AppBar(
      //   title: const Text('Phone Book'),
      //   backgroundColor: Theme.of(context).primaryColorLight,
      //   foregroundColor: Colors.white,
      //   centerTitle: true,
      // ),
      body:
          _contacts.isEmpty
              ? const Center(child: Text('No contacts added yet.'))
              : ListView.builder(
                itemCount: _contacts.length,
                itemBuilder: (context, index) {
                  final contact = _contacts[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    color: Colors.blueGrey.shade50,
                    // 👈 change card background here
                    elevation: 3,
                    // optional shadow depth
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: ListTile(
                      title: Text(
                        contact.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(contact.phone),
                          if (contact.notes.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                'Notes: ${contact.notes}',
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _addOrEditContact(contact: contact, index: index),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteContact(index),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEditContact(),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _deleteContact(int index) async {
    setState(() {
      _contacts.removeAt(index);
    });
    _saveContacts();
  }
}

class Contact {
  String name;
  String phone;
  String notes;

  Contact({required this.name, required this.phone, this.notes = ''});

  Map<String, dynamic> toJson() => {'name': name, 'phone': phone, 'notes': notes};

  factory Contact.fromJson(Map<String, dynamic> json) =>
      Contact(name: json['name'], phone: json['phone'], notes: json['notes'] ?? '');
}
