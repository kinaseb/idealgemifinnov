import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../class/trash_item.dart';
import '../services/trash_service.dart';

class TrashPage extends StatefulWidget {
  const TrashPage({super.key});

  @override
  State<TrashPage> createState() => _TrashPageState();
}

class _TrashPageState extends State<TrashPage> {
  late Future<List<TrashItem>> _trashFuture;
  String _filterType = 'all';

  @override
  void initState() {
    super.initState();
    _refreshTrash();
  }

  void _refreshTrash() {
    setState(() {
      if (_filterType == 'all') {
        _trashFuture = TrashService()
            .getTrashItems()
            .then((items) => items.map((e) => TrashItem.fromMap(e)).toList());
      } else {
        _trashFuture = TrashService()
            .getTrashItemsByType(_filterType)
            .then((items) => items.map((e) => TrashItem.fromMap(e)).toList());
      }
    });
  }

  Future<void> _restore(TrashItem item) async {
    try {
      await TrashService().restore(item.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✓ ${item.entityTypeLabel} restauré'),
            backgroundColor: Colors.green,
          ),
        );
        _refreshTrash();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _permanentDelete(TrashItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Suppression définitive'),
        content: Text(
          'Voulez-vous supprimer définitivement "${item.displayName}" ?\n\nCette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await TrashService().permanentDelete(item.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✓ Supprimé définitivement'),
              backgroundColor: Colors.orange,
            ),
          );
          _refreshTrash();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Erreur: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _emptyTrash() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Vider la corbeille'),
        content: const Text(
          'Voulez-vous vider toute la corbeille ?\n\nTous les éléments seront définitivement supprimés.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Vider'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await TrashService().emptyTrash();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✓ Corbeille vidée'),
              backgroundColor: Colors.orange,
            ),
          );
          _refreshTrash();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Erreur: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Corbeille'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            tooltip: 'Vider la corbeille',
            onPressed: _emptyTrash,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('Tous'),
                  selected: _filterType == 'all',
                  onSelected: (selected) {
                    setState(() {
                      _filterType = 'all';
                      _refreshTrash();
                    });
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Clients'),
                  selected: _filterType == 'client',
                  onSelected: (selected) {
                    setState(() {
                      _filterType = 'client';
                      _refreshTrash();
                    });
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Articles'),
                  selected: _filterType == 'article',
                  onSelected: (selected) {
                    setState(() {
                      _filterType = 'article';
                      _refreshTrash();
                    });
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Supports'),
                  selected: _filterType == 'support',
                  onSelected: (selected) {
                    setState(() {
                      _filterType = 'support';
                      _refreshTrash();
                    });
                  },
                ),
              ],
            ),
          ),
          // Trash items list
          Expanded(
            child: FutureBuilder<List<TrashItem>>(
              future: _trashFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Erreur: ${snapshot.error}'));
                }

                final items = snapshot.data ?? [];

                if (items.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.delete_outline,
                            size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('Corbeille vide', style: TextStyle(fontSize: 18)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Icon(_getIconForType(item.entityType)),
                        ),
                        title: Text(item.displayName),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.entityTypeLabel),
                            Text(
                              'Supprimé le ${DateFormat('dd/MM/yyyy HH:mm').format(item.deletedAt)}',
                              style: const TextStyle(fontSize: 12),
                            ),
                            if (item.relatedCount > 0)
                              Text(
                                '${item.relatedCount} élément${item.relatedCount > 1 ? 's' : ''} lié${item.relatedCount > 1 ? 's' : ''}',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.orange[700]),
                              ),
                          ],
                        ),
                        isThreeLine: true,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.restore,
                                  color: Colors.green),
                              tooltip: 'Restaurer',
                              onPressed: () => _restore(item),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_forever,
                                  color: Colors.red),
                              tooltip: 'Supprimer définitivement',
                              onPressed: () => _permanentDelete(item),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'client':
        return Icons.business;
      case 'article':
        return Icons.article;
      case 'support':
        return Icons.layers;
      case 'machine':
        return Icons.precision_manufacturing;
      case 'repeat':
        return Icons.circle;
      default:
        return Icons.help_outline;
    }
  }
}
