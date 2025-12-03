import 'package:flutter/material.dart';
import '../class/machine.dart';
import '../services/database_helper.dart';
import '../services/sync_service.dart';
import 'machine_form_page.dart';
import 'dart:async';

class MachinesPage extends StatefulWidget {
  const MachinesPage({super.key});

  @override
  State<MachinesPage> createState() => _MachinesPageState();
}

class _MachinesPageState extends State<MachinesPage> {
  late Future<List<Machine>> _machinesFuture;
  final TextEditingController _searchController = TextEditingController();
  List<Machine> _allMachines = [];
  List<Machine> _filteredMachines = [];
  StreamSubscription? _syncSubscription;

  @override
  void initState() {
    super.initState();
    _refreshMachines();
    _searchController.addListener(_filterMachines);

    _syncSubscription = SyncService().onChange.listen((_) {
      if (mounted) {
        _refreshMachines();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _syncSubscription?.cancel();
    super.dispose();
  }

  void _refreshMachines() {
    setState(() {
      _machinesFuture = DatabaseHelper().getMachines().then((data) {
        final machines = data.map((e) => Machine.fromMap(e)).toList();
        _allMachines = machines;
        _filterMachines();
        return machines;
      });
    });
  }

  void _filterMachines() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredMachines = _allMachines;
      } else {
        _filteredMachines = _allMachines.where((machine) {
          return machine.reference.toLowerCase().contains(query) ||
              (machine.typeName?.toLowerCase().contains(query) ?? false);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Machines'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher une machine...',
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
      body: FutureBuilder<List<Machine>>(
        future: _machinesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }

          if (_filteredMachines.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.precision_manufacturing,
                      size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Aucune machine trouvée',
                      style: TextStyle(fontSize: 18)),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: _filteredMachines.length,
            itemBuilder: (context, index) {
              final machine = _filteredMachines[index];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: const Icon(Icons.precision_manufacturing,
                        color: Colors.white),
                  ),
                  title: Text(
                    machine.reference,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(machine.typeName ?? '',
                          style: TextStyle(color: Colors.blue[700])),
                      Text(
                          'Laize: ${machine.laizeMin.toInt()}-${machine.laizeMax.toInt()} mm'),
                      if (machine.nbrStations != null)
                        Text(
                            'Stations: ${machine.nbrStations}${machine.nbrStationsDecoupe != null ? ' + ${machine.nbrStationsDecoupe} découpe' : ''}'),
                    ],
                  ),
                  isThreeLine: true,
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MachineFormPage(machine: machine),
                      ),
                    );
                    if (result == true) {
                      _refreshMachines();
                    }
                  },
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Supprimer machine'),
                          content: Text('Supprimer "${machine.reference}" ?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Annuler'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Supprimer'),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true && mounted) {
                        await DatabaseHelper().deleteMachine(machine.id!);
                        _refreshMachines();
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MachineFormPage()),
          );
          if (result == true) {
            _refreshMachines();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
