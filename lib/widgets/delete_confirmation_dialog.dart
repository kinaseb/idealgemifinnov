import 'package:flutter/material.dart';

class DeleteConfirmationDialog extends StatelessWidget {
  final String entityType;
  final String entityName;
  final Map<String, int>? relatedItems;

  const DeleteConfirmationDialog({
    super.key,
    required this.entityType,
    required this.entityName,
    this.relatedItems,
  });

  static Future<bool?> show(
    BuildContext context, {
    required String entityType,
    required String entityName,
    Map<String, int>? relatedItems,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => DeleteConfirmationDialog(
        entityType: entityType,
        entityName: entityName,
        relatedItems: relatedItems,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasRelatedItems = relatedItems != null && relatedItems!.isNotEmpty;
    final totalRelated =
        relatedItems?.values.fold(0, (sum, count) => sum + count) ?? 0;

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Supprimer $entityType ?',
              style: const TextStyle(fontSize: 20),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Êtes-vous sûr de vouloir supprimer :',
              style: TextStyle(color: Colors.grey[700]),
            ),
            const SizedBox(height: 8),
            Text(
              '"$entityName"',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            if (hasRelatedItems) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline,
                            size: 20, color: Colors.red[700]),
                        const SizedBox(width: 8),
                        Text(
                          'Éléments liés qui seront aussi supprimés :',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.red[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...relatedItems!.entries.map((entry) => Padding(
                          padding: const EdgeInsets.only(left: 28, top: 4),
                          child: Text(
                            '• ${entry.value} ${entry.key}',
                            style: TextStyle(color: Colors.grey[800]),
                          ),
                        )),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Total: $totalRelated élément${totalRelated > 1 ? 's' : ''} lié${totalRelated > 1 ? 's' : ''} sera${totalRelated > 1 ? 'ont' : ''} supprimé${totalRelated > 1 ? 's' : ''}.',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey[600],
                  fontSize: 13,
                ),
              ),
            ],
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  Icon(Icons.restore_from_trash,
                      size: 18, color: Colors.blue[700]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Les éléments seront déplacés vers la corbeille',
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: Colors.blue[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: const Text('Supprimer'),
        ),
      ],
    );
  }
}
