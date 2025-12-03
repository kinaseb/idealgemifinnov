import 'package:flutter/material.dart';
import '../class/repeat.dart';
import '../services/database_helper.dart';
import '../services/sync_service.dart';
import 'repeat_form_page.dart';
import 'dart:async';

class RepeatsPage extends StatefulWidget {
  const RepeatsPage({super.key});

  @override
  State<RepeatsPage> createState() => _RepeatsPageState();
}

class _RepeatsPageState extends State<RepeatsPage> {
  late Future<List<Repeat>> _repeatsFuture;
  final TextEditingController _searchController = TextEditingController();
  List<Repeat> _allRepeats = [];
  List<Repeat> _filteredRepeats = [];
  StreamSubscription? _syncSubscription;

  @override
  void initState() {
    super.initState();
    _refreshRepeats();
    _searchController.addListener(_filterRepeats);

    _syncSubscription = SyncService().onChange.listen((_) {
      if (mounted) {
        _refreshRepeats();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _syncSubscription?.cancel();
    super.dispose();
  }

  void _refreshRepeats() {
    print('🔵 DEBUG: _refreshRepeats() called');
    setState(() {
      _repeatsFuture = DatabaseHelper().getRepeats().then((data) {
        print('🔵 DEBUG: getRepeats() returned ${data.length} items');
        final repeats = data.map((e) => Repeat.fromMap(e)).toList();
        _allRepeats = repeats;
        _filterRepeats();
        print('✅ DEBUG: _refreshRepeats() finished');
        return repeats;
      }).catchError((e) {
        print('❌ DEBUG: Error in _refreshRepeats: $e');
        return <Repeat>[];
      });
    });
  }

  void _filterRepeats() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredRepeats = _allRepeats;
      } else {
        _filteredRepeats = _allRepeats.where((repeat) {
          return repeat.reference.toLowerCase().contains(query) ||
              (repeat.fournisseur?.toLowerCase().contains(query) ?? false);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Repeats (Clichés)'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher un repeat...',
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
      body: FutureBuilder<List<Repeat>>(
        future: _repeatsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }

          if (_filteredRepeats.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.circle_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Aucun repeat trouvé', style: TextStyle(fontSize: 18)),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: _filteredRepeats.length,
            itemBuilder: (context, index) {
              final repeat = _filteredRepeats[index];
              final hasCylinder = repeat.hasMagneticCylinder == true;
              final compatibleTypes = repeat.compatiblePrintTypes;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: hasCylinder ? Colors.green : Colors.orange,
                    child: Icon(
                      hasCylinder ? Icons.check_circle : Icons.circle,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(
                    repeat.reference,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          '${repeat.nbrDents} dents • ${repeat.developpement.toStringAsFixed(2)} mm'),
                      Text('Stock: ${repeat.quantite}'),
                      if (repeat.fournisseur != null)
                        Text('Fournisseur: ${repeat.fournisseur}'),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 4,
                        children: compatibleTypes.map((type) {
                          return Chip(
                            label: Text(type,
                                style: const TextStyle(fontSize: 10)),
                            padding: EdgeInsets.zero,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  isThreeLine: true,
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RepeatFormPage(repeat: repeat),
                      ),
                    );
                    if (result == true) {
                      _refreshRepeats();
                    }
                  },
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (hasCylinder == true)
                        Icon(Icons.hexagon, color: Colors.green[700], size: 20),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Supprimer repeat'),
                              content:
                                  Text('Supprimer "${repeat.reference}" ?'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
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
                            await DatabaseHelper().deleteRepeat(repeat.id!);
                            _refreshRepeats();
                          }
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
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const RepeatFormPage()),
          );
          if (result == true) {
            _refreshRepeats();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
