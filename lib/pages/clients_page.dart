import 'dart:io';
import 'package:flutter/material.dart';
import '../class/client.dart';
import '../services/database_helper.dart';
import 'client_form_page.dart';
import 'articles_page.dart';

class ClientsPage extends StatefulWidget {
  const ClientsPage({super.key});

  @override
  State<ClientsPage> createState() => _ClientsPageState();
}

class _ClientsPageState extends State<ClientsPage> {
  late Future<List<Client>> _clientsFuture;

  @override
  void initState() {
    super.initState();
    _refreshClients();
  }

  void _refreshClients() {
    setState(() {
      _clientsFuture = DatabaseHelper().getClients().then((data) {
        return data.map((e) => Client.fromMap(e)).toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clients'),
      ),
      body: FutureBuilder<List<Client>>(
        future: _clientsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No clients found.'));
          }

          final clients = snapshot.data!;
          return ListView.builder(
            itemCount: clients.length,
            itemBuilder: (context, index) {
              final client = clients[index];
              return Card(
                child: ListTile(
                  leading: client.logoPath != null
                      ? CircleAvatar(
                          backgroundImage: FileImage(File(client.logoPath!)),
                        )
                      : const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(client.name,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(client.contactInfo ?? ''),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ArticlesPage(client: client),
                      ),
                    );
                  },
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ClientFormPage(client: client),
                            ),
                          );
                          _refreshClients();
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          await DatabaseHelper().deleteClient(client.id!);
                          _refreshClients();
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ClientFormPage()),
          );
          _refreshClients();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
