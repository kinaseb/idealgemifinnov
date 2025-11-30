import 'dart:async';
import 'package:flutter/material.dart';
import '../class/client.dart';
import '../services/database_helper.dart';
import '../services/sync_service.dart';
import '../widgets/avatar_image.dart';
import 'client_form_page.dart';
import 'articles_page.dart';

class ClientsPage extends StatefulWidget {
  const ClientsPage({super.key});

  @override
  State<ClientsPage> createState() => _ClientsPageState();
}

class _ClientsPageState extends State<ClientsPage> {
  late Future<List<Client>> _clientsFuture;

  List<Client> _allClients = [];
  List<Client> _filteredClients = [];
  final TextEditingController _searchController = TextEditingController();

  StreamSubscription? _syncSubscription;

  @override
  void initState() {
    super.initState();
    _refreshClients();
    _searchController.addListener(_filterClients);

    // Listen for realtime updates
    _syncSubscription = SyncService().onChange.listen((_) {
      if (mounted) {
        _refreshClients();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _syncSubscription?.cancel();
    super.dispose();
  }

  void _refreshClients() {
    setState(() {
      _clientsFuture = DatabaseHelper().getClients().then((data) {
        final clients = data.map((e) => Client.fromMap(e)).toList();
        _allClients = clients;
        _filterClients();
        return clients;
      });
    });
  }

  void _filterClients() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredClients = _allClients;
      } else {
        _filteredClients = _allClients.where((client) {
          return client.name.toLowerCase().contains(query) ||
              (client.contactInfo?.toLowerCase().contains(query) ?? false);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clients'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search clients...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ),
      body: FutureBuilder<List<Client>>(
        future: _clientsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (_filteredClients.isEmpty) {
            return const Center(child: Text('No clients found.'));
          }

          return ListView.builder(
            itemCount: _filteredClients.length,
            itemBuilder: (context, index) {
              final client = _filteredClients[index];
              return Card(
                child: ListTile(
                  leading: AvatarImage(
                    imagePath: client.logoPath,
                    fallbackText: client.name,
                  ),
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
