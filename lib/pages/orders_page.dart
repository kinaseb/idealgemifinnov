import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:share_plus/share_plus.dart';
import '../services/supabase_service.dart';
import '../services/database_helper.dart';
import '../class/client.dart';
import '../class/article.dart';
import '../class/etiquette.dart';
import '../class/employee.dart';
import '../pages/employees_page.dart';
import '../pages/new_order_page.dart';
import '../widgets/image_zoom_dialog.dart';
import '../widgets/responsive_layout.dart';
import '../widgets/modern_card.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();

  // Controllers for DropdownMenu
  final _clientController = TextEditingController();
  final _articleController = TextEditingController();

  late TabController _tabController;

  // Data
  List<Client> _clients = [];
  List<Article> _articles = [];
  List<Map<String, dynamic>> _orders = [];
  List<Map<String, dynamic>> _filteredOrders = [];

  // Selections
  Client? _selectedClient;
  Article? _selectedArticle;
  DateTime _selectedDate = DateTime.now();

  // Calculation
  double _calculatedMetrage = 0.0;

  // Search/Sort
  String _searchQuery = '';
  bool _sortAscending = false;
  int _sortColumnIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadInitialData();
    _quantityController.addListener(_calculateMetrage);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _quantityController.dispose();
    _clientController.dispose();
    _articleController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    final clientsData = await DatabaseHelper().getClients();
    setState(() {
      _clients = clientsData.map((e) => Client.fromMap(e)).toList();
    });
    _refreshOrders();
  }

  Future<void> _refreshOrders() async {
    try {
      final data = await SupabaseService().getOrders();
      if (mounted) {
        setState(() {
          _orders = data;
          _filterOrders();
        });
      }
    } catch (e) {
      debugPrint('Error refreshing orders: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Erreur chargement: $e'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  void _filterOrders() {
    setState(() {
      if (_searchQuery.isEmpty) {
        _filteredOrders = List.from(_orders);
      } else {
        final query = _searchQuery.toLowerCase();
        _filteredOrders = _orders.where((order) {
          final clientName =
              (order['clients']?['name'] ?? '').toString().toLowerCase();
          final articleName =
              (order['articles']?['name'] ?? '').toString().toLowerCase();
          return clientName.contains(query) || articleName.contains(query);
        }).toList();
      }
    });
  }

  Future<void> _loadArticlesForClient(int clientId) async {
    final articlesData = await DatabaseHelper().getArticlesByClient(clientId);
    setState(() {
      _articles = articlesData.map((e) => Article.fromMap(e)).toList();
      _selectedArticle = null;
      _articleController.clear();
    });
  }

  void _calculateMetrage() {
    if (_selectedArticle != null && _quantityController.text.isNotEmpty) {
      final qty =
          int.tryParse(_quantityController.text.replaceAll(' ', '')) ?? 0;
      final repeat = _selectedArticle!.repeat.toInt();
      final poses = _selectedArticle!.poseCount;

      if (repeat > 0 && poses > 0) {
        setState(() {
          _calculatedMetrage =
              Etiquette.calculateMetrageRequired(repeat, poses, qty);
        });
        return;
      }
    }
    setState(() {
      _calculatedMetrage = 0.0;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submitOrder() async {
    if (_formKey.currentState!.validate() &&
        _selectedClient != null &&
        _selectedArticle != null) {
      final quantity = int.parse(_quantityController.text.replaceAll(' ', ''));
      final orderRef =
          'CMD-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';

      final orderData = {
        'client_id': _selectedClient!.id,
        'article_id': _selectedArticle!.id,
        'quantity': quantity,
        'initial_quantity': quantity,
        'order_ref': orderRef,
        'date': DateFormat('yyyy-MM-dd').format(_selectedDate),
        'status': 'En attente',
        'production_log': '',
      };

      try {
        await SupabaseService().insertOrder(orderData);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Commande ajoutée avec succès'),
                backgroundColor: Colors.green),
          );
          _quantityController.clear();
          setState(() {
            _selectedArticle = null;
            _articleController.clear();
            _calculatedMetrage = 0.0;
          });
          _refreshOrders();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
          );
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Veuillez remplir tous les champs'),
            backgroundColor: Colors.orange),
      );
    }
  }

  Future<void> _shareOrder() async {
    if (_selectedClient == null || _selectedArticle == null) return;

    final text = '''
Nouvelle Commande
Client: ${_selectedClient!.name}
Article: ${_selectedArticle!.name}
Date: ${DateFormat('dd/MM/yyyy').format(_selectedDate)}
Quantité: ${_quantityController.text}
Métrage estimé: ${_calculatedMetrage.toStringAsFixed(2)} m
''';
    await Share.share(text);
  }

  Future<void> _deleteOrder(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la commande ?'),
        content: const Text('Cette action est irréversible.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annuler')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child:
                  const Text('Supprimer', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      await SupabaseService().deleteOrder(id);
      _refreshOrders();
    }
  }

  Future<int?> _selectEmployee() async {
    final employees = await SupabaseService().getEmployees();
    if (employees.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Aucun employé trouvé. Veuillez en créer un.')),
        );
      }
      return null;
    }

    final employeeList = employees.map((e) => Employee.fromMap(e)).toList();

    if (!mounted) return null;

    return await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Qui effectue cette action ?'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: employeeList.length,
            itemBuilder: (context, index) {
              final employee = employeeList[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: employee.photoUrl != null
                      ? NetworkImage(employee.photoUrl!)
                      : null,
                  child: employee.photoUrl == null
                      ? Text(employee.firstName[0])
                      : null,
                ),
                title: Text(employee.fullName),
                subtitle: Text(employee.jobTitle ?? ''),
                onTap: () => Navigator.pop(context, employee.id),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateOrderStatus(int id, String newStatus) async {
    final index = _orders.indexWhere((o) => o['id'] == id);
    if (index == -1) return;

    final order = _orders[index];
    final orderRef = order['order_ref'];
    final articleId = order['articles']?['id'];
    final oldStatus = order['status'];

    // 1. Select Employee
    final employeeId = await _selectEmployee();
    if (employeeId == null) return; // Cancelled

    // Check for merge target
    final targetIndex = _orders.indexWhere((o) =>
        o['id'] != id &&
        o['status'] == newStatus &&
        o['order_ref'] == orderRef &&
        o['articles']?['id'] == articleId);

    if (targetIndex != -1) {
      // MERGE LOGIC
      final targetOrder = _orders[targetIndex];
      final sourceQty = order['quantity'] as int;
      final targetQty = targetOrder['quantity'] as int;
      final newQty = targetQty + sourceQty;

      // Optimistic Update: Update target, Remove source
      setState(() {
        _orders[targetIndex]['quantity'] = newQty;
        _orders.removeAt(index);
        _filterOrders();
      });

      try {
        // Log movement before delete
        await SupabaseService()
            .logOrderMovement(id, oldStatus, newStatus, employeeId);

        // Transfer history to target
        await SupabaseService().transferOrderHistory(id, targetOrder['id']);

        await SupabaseService()
            .updateOrder(targetOrder['id'], {'quantity': newQty});
        await SupabaseService().deleteOrder(id);

        if (newStatus == 'Livraison') {
          _checkCompletion(orderRef, order['initial_quantity'] ?? 0);
        }
      } catch (e) {
        // Revert on error
        debugPrint('Error merging: $e');
        _refreshOrders();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Erreur fusion: $e'),
                backgroundColor: Colors.red),
          );
        }
      }
    } else {
      // STANDARD MOVE LOGIC
      setState(() {
        _orders[index]['status'] = newStatus;
        _filterOrders();
      });

      try {
        await SupabaseService().updateOrder(id, {'status': newStatus});
        await SupabaseService()
            .logOrderMovement(id, oldStatus, newStatus, employeeId);

        if (newStatus == 'Livraison') {
          _checkCompletion(orderRef, order['initial_quantity'] ?? 0);
        }
      } catch (e) {
        // Revert on error
        debugPrint('Error updating status: $e');
        setState(() {
          _orders[index]['status'] = oldStatus;
          _filterOrders();
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  Future<void> _updateOrderQuantity(int id, int newQuantity) async {
    try {
      await SupabaseService().updateOrder(id, {'quantity': newQuantity});
      _refreshOrders();
    } catch (e) {
      debugPrint('Error updating quantity: $e');
    }
  }

  void _showOrderPreview(Map<String, dynamic> order) {
    final client = Client.fromSupabaseMap(order['clients']);
    final article = Article.fromSupabaseMap(order['articles']);
    final quantity = order['quantity'] as int;
    final metrage = Etiquette.calculateMetrageRequired(
        article.repeat.toInt(), article.poseCount, quantity);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            if (client.logoPath != null)
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: CircleAvatar(
                  backgroundImage: NetworkImage(client.logoPath!),
                  radius: 16,
                ),
              ),
            Expanded(child: Text(client.name)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (article.photo != null)
                Center(
                  child: GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) =>
                            ImageZoomDialog(imageUrl: article.photo),
                      );
                    },
                    child: Container(
                      height: 150,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: NetworkImage(article.photo!),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
              Text(article.name,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const Divider(),
              _buildDetailRow('Type', article.type),
              _buildDetailRow('Machine', article.machine),
              _buildDetailRow('Laize', '${article.width} mm'),
              _buildDetailRow('Repeat', '${article.repeat}'),
              _buildDetailRow('Poses', '${article.poseCount}'),
              const Divider(),
              _buildDetailRow('Quantité', '$quantity'),
              _buildDetailRow('Métrage', '${metrage.toStringAsFixed(0)} m',
                  isBold: true, color: Colors.blue),
            ],
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _shareOrderDetails(client, article, order);
            },
            icon: const Icon(Icons.share),
            label: const Text('Partager'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value,
      {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value,
              style: TextStyle(
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                  color: color)),
        ],
      ),
    );
  }

  Future<void> _shareOrderDetails(
      Client client, Article article, Map<String, dynamic> order) async {
    final metrage = Etiquette.calculateMetrageRequired(
        article.repeat.toInt(), article.poseCount, order['quantity'] as int);
    final text = '''
Commande: ${article.name}
Client: ${client.name}
Date: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(order['date']))}
Quantité: ${order['quantity']}
Métrage: ${metrage.toStringAsFixed(0)} m

Détails Techniques:
Machine: ${article.machine}
Laize: ${article.width} mm
Repeat: ${article.repeat}
Poses: ${article.poseCount}
''';
    await Share.share(text);
  }

  void _showStockQuickEdit(Map<String, dynamic> order) {
    final controller =
        TextEditingController(text: order['quantity'].toString());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifier Stock'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Nouvelle Quantité'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              final newQty = int.tryParse(controller.text);
              if (newQty != null) {
                _updateOrderQuantity(order['id'], newQty);
                Navigator.pop(context);
              }
            },
            child: const Text('Valider'),
          ),
        ],
      ),
    );
  }

  void _showSplitOrderDialog(Map<String, dynamic> order) {
    final currentQty = order['quantity'] as int;
    int splitQty = 0;
    String targetStatus = 'Production';
    final statuses = ['Prepresse', 'Production', 'Finition', 'Stock'];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Diviser la commande'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                      'Quantité actuelle: $currentQty\nQuantité restante: ${currentQty - splitQty}'),
                  Slider(
                    value: splitQty.toDouble(),
                    min: 0,
                    max: currentQty.toDouble(),
                    divisions: currentQty > 100 ? 100 : currentQty,
                    label: splitQty.toString(),
                    onChanged: (val) {
                      setState(() {
                        splitQty = val.toInt();
                      });
                    },
                  ),
                  TextField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        labelText: 'Ou entrer quantité exacte'),
                    onChanged: (val) {
                      final v = int.tryParse(val);
                      if (v != null && v <= currentQty) {
                        setState(() {
                          splitQty = v;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: targetStatus,
                    items: statuses
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (val) {
                      setState(() {
                        targetStatus = val!;
                      });
                    },
                    decoration: const InputDecoration(labelText: 'Vers Statut'),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Annuler'),
                ),
                TextButton(
                  onPressed: splitQty > 0 && splitQty < currentQty
                      ? () {
                          Navigator.pop(context);
                          _splitOrder(order, splitQty, targetStatus);
                        }
                      : null,
                  child: const Text('Diviser'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _splitOrder(
      Map<String, dynamic> originalOrder, int splitQty, String targetStatus,
      {String? productionLog}) async {
    final originalId = originalOrder['id'];
    final currentQty = originalOrder['quantity'] as int;
    final newQtyOriginal = currentQty - splitQty;
    final orderRef =
        originalOrder['order_ref'] ?? originalOrder['id'].toString();
    final initialQty = originalOrder['initial_quantity'] ??
        (originalOrder['quantity'] + splitQty);

    try {
      if (newQtyOriginal > 0) {
        await _updateOrderQuantity(originalId, newQtyOriginal);
      } else if (newQtyOriginal == 0) {
        await _updateOrderStatus(originalId, targetStatus);
        return;
      }

      final newOrder = Map<String, dynamic>.from(originalOrder);
      newOrder.remove('id');
      newOrder.remove('clients');
      newOrder.remove('articles');
      newOrder.remove('created_at');
      newOrder['quantity'] = splitQty;
      newOrder['status'] = targetStatus;
      newOrder['order_ref'] = orderRef;
      newOrder['initial_quantity'] = initialQty;
      newOrder['production_log'] = productionLog ?? '';

      await SupabaseService().insertOrder(newOrder);

      if (targetStatus == 'Livraison') {
        _checkCompletion(orderRef, initialQty);
      }

      _refreshOrders();
    } catch (e) {
      debugPrint('Error splitting order: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Erreur lors de la division: $e'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _checkCompletion(String orderRef, int initialQty) async {
    final data = await SupabaseService().getOrders();
    final related = data.where((o) => o['order_ref'] == orderRef).toList();

    int deliveredQty = 0;
    for (var o in related) {
      if (o['status'] == 'Livraison') {
        deliveredQty += (o['quantity'] as int);
      }
    }

    if (deliveredQty >= initialQty) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Commande Terminée !'),
            content: Text(
                'La commande $orderRef est entièrement livrée ($deliveredQty / $initialQty).\nVoulez-vous l\'archiver ?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Plus tard'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  // Archive all related orders
                  for (var o in related) {
                    await SupabaseService()
                        .updateOrder(o['id'], {'status': 'Terminé'});
                  }
                  _refreshOrders();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Commande archivée'),
                          backgroundColor: Colors.green),
                    );
                  }
                },
                child: const Text('Archiver'),
              ),
            ],
          ),
        );
      }
    }
  }

  void _showProductionInput(Map<String, dynamic> order) {
    final article = Article.fromSupabaseMap(order['articles']);
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Saisie Production'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Métrage réalisé (m)',
                suffixText: 'm',
              ),
            ),
            const SizedBox(height: 16),
            const Text(
                'Cela calculera automatiquement la quantité d\'étiquettes.',
                style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              final meters = double.tryParse(controller.text);
              if (meters != null && meters > 0) {
                final qty = Etiquette.calculateLabelsCount(
                    article.repeat.toInt(), article.poseCount, meters);
                Navigator.pop(context);
                _confirmProductionSplit(order, qty.toInt(), meters);
              }
            },
            child: const Text('Valider'),
          ),
        ],
      ),
    );
  }

  void _confirmProductionSplit(
      Map<String, dynamic> order, int qty, double meters) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer Production'),
        content: Text(
            'Métrage: $meters m\nQuantité calculée: $qty étiquettes\n\nDéplacer vers Finition ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              final log =
                  'Prod: $meters m -> $qty etq (${DateFormat('dd/MM HH:mm').format(DateTime.now())})';
              _splitOrder(order, qty, 'Finition', productionLog: log);
            },
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
  }

  void _sort<T>(Comparable<T> Function(Map<String, dynamic> d) getField,
      int columnIndex, bool ascending) {
    _filteredOrders.sort((a, b) {
      final aValue = getField(a);
      final bValue = getField(b);
      return ascending
          ? Comparable.compare(aValue, bValue)
          : Comparable.compare(bValue, aValue);
    });
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
  }

  void _showOrderHistory(int orderId) async {
    final history = await SupabaseService().getOrderHistory(orderId);

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Historique de la commande'),
        content: SizedBox(
          width: 600,
          child: SingleChildScrollView(
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Date')),
                DataColumn(label: Text('Heure')),
                DataColumn(label: Text('De')),
                DataColumn(label: Text('Vers')),
                DataColumn(label: Text('Employé')),
              ],
              rows: history.map((h) {
                final date = DateTime.parse(h['timestamp']).toLocal();
                final employee = h['employees'] != null
                    ? Employee.fromMap(h['employees'])
                    : null;
                return DataRow(cells: [
                  DataCell(Text(DateFormat('dd/MM/yyyy').format(date))),
                  DataCell(Text(DateFormat('HH:mm').format(date))),
                  DataCell(Text(h['from_status'] ?? '-')),
                  DataCell(Text(h['to_status'] ?? '-')),
                  DataCell(Row(
                    children: [
                      if (employee?.photoUrl != null)
                        CircleAvatar(
                          radius: 10,
                          backgroundImage: NetworkImage(employee!.photoUrl!),
                        ),
                      const SizedBox(width: 8),
                      Text(employee?.fullName ?? 'Inconnu'),
                    ],
                  )),
                ]);
              }).toList(),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ResponsiveLayout(
        mobile: _buildMobileLayout(),
        tablet: _buildTabletLayout(),
        desktop: _buildDesktopLayout(),
      ),
      floatingActionButton: ResponsiveLayout.isMobile(context)
          ? FloatingActionButton(
              onPressed: () {
                _tabController.animateTo(0); // Go to 'Nouveau' tab
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 400, child: _buildFormPanel()),
        Expanded(
          child: Column(
            children: [
              _buildTabBar(isDesktop: true),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildKanbanView(),
                    _buildPipelineView(),
                    _buildListPanel(),
                    const Center(child: Text('Statistiques (Bientôt)')),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabletLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 300, child: _buildFormPanel()),
        Expanded(
          child: Column(
            children: [
              _buildTabBar(isDesktop: false),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildKanbanView(),
                    _buildPipelineView(),
                    _buildListPanel(),
                    const Center(child: Text('Statistiques (Bientôt)')),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        _buildTabBar(isDesktop: false, isMobile: true),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildFormPanel(),
              _buildKanbanView(),
              _buildPipelineView(),
              _buildListPanel(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar({bool isDesktop = false, bool isMobile = false}) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: Theme.of(context).primaryColor,
        unselectedLabelColor: Colors.grey,
        indicatorSize: TabBarIndicatorSize.label,
        indicatorColor: Theme.of(context).primaryColor,
        tabs: isMobile
            ? const [
                Tab(text: 'Nouveau'),
                Tab(text: 'Kanban'),
                Tab(text: 'Pipeline'),
                Tab(text: 'Liste'),
              ]
            : const [
                Tab(text: 'Kanban'),
                Tab(text: 'Pipeline'),
                Tab(text: 'Liste'),
                Tab(text: 'Statistiques'),
              ],
      ),
    );
  }

  Widget _buildFormPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Nouvelle Commande',
                    style: Theme.of(context).textTheme.headlineSmall),
                IconButton(
                  icon: const Icon(Icons.people),
                  tooltip: 'Gérer les employés',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const EmployeesPage()),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Client Searchable Dropdown
            DropdownMenu<Client>(
              controller: _clientController,
              width: 318, // Adjust width to fit container
              label: const Text('Client'),
              enableFilter: true,
              dropdownMenuEntries: _clients.map((c) {
                return DropdownMenuEntry<Client>(value: c, label: c.name);
              }).toList(),
              onSelected: (Client? client) {
                setState(() {
                  _selectedClient = client;
                  if (client != null) {
                    _loadArticlesForClient(client.id!);
                  }
                });
              },
            ),
            const SizedBox(height: 16),

            // Article Searchable Dropdown
            DropdownMenu<Article>(
              controller: _articleController,
              width: 318,
              label: const Text('Article'),
              enableFilter: true,
              enabled: _selectedClient != null,
              dropdownMenuEntries: _articles.map((a) {
                return DropdownMenuEntry<Article>(value: a, label: a.name);
              }).toList(),
              onSelected: (Article? article) {
                setState(() {
                  _selectedArticle = article;
                  _calculateMetrage();
                });
              },
            ),
            const SizedBox(height: 16),

            // Date Picker
            InkWell(
              onTap: () => _selectDate(context),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Date',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(DateFormat('dd/MM/yyyy').format(_selectedDate)),
              ),
            ),
            const SizedBox(height: 16),

            // Quantity
            TextFormField(
              controller: _quantityController,
              decoration: const InputDecoration(
                labelText: 'Quantité',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.numbers),
              ),
              keyboardType: TextInputType.number,
              validator: (val) =>
                  (val == null || val.isEmpty) ? 'Requis' : null,
            ),
            const SizedBox(height: 16),

            // Calculated Metrage
            if (_calculatedMetrage > 0)
              ModernCard(
                backgroundColor: Colors.blue.shade50,
                child: Column(
                  children: [
                    const Text('Métrage Nécessaire',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('${_calculatedMetrage.toStringAsFixed(0)} m',
                        style:
                            const TextStyle(fontSize: 24, color: Colors.blue)),
                    Text('Bobine Fille: ${_selectedArticle?.width} mm',
                        style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _submitOrder,
                    icon: const Icon(Icons.save),
                    label: const Text('Enregistrer'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  onPressed: _shareOrder,
                  icon: const Icon(Icons.share),
                  tooltip: 'Partager',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListPanel() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Rechercher Client / Article...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onChanged: (val) {
                    _searchQuery = val;
                    _filterOrders();
                  },
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NewOrderPage(),
                    ),
                  );
                },
                icon: const Icon(Icons.add_circle_outline),
                label: const Text('Nouvelle Commande'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _refreshOrders,
                tooltip: 'Actualiser',
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ModernCard(
              padding: EdgeInsets.zero,
              child: DataTable2(
                columnSpacing: 12,
                horizontalMargin: 12,
                minWidth: 600,
                sortColumnIndex: _sortColumnIndex,
                sortAscending: _sortAscending,
                columns: [
                  DataColumn2(
                    label: const Text('Date'),
                    size: ColumnSize.S,
                    onSort: (columnIndex, ascending) =>
                        _sort<String>((d) => d['date'], columnIndex, ascending),
                  ),
                  DataColumn2(
                    label: const Text('Client'),
                    size: ColumnSize.L,
                    onSort: (columnIndex, ascending) => _sort<String>(
                        (d) => d['clients']['name'], columnIndex, ascending),
                  ),
                  DataColumn2(
                    label: const Text('Article'),
                    size: ColumnSize.L,
                    onSort: (columnIndex, ascending) => _sort<String>(
                        (d) => d['articles']['name'], columnIndex, ascending),
                  ),
                  DataColumn2(
                    label: const Text('Quantité'),
                    size: ColumnSize.S,
                    numeric: true,
                    onSort: (columnIndex, ascending) => _sort<num>(
                        (d) => d['quantity'], columnIndex, ascending),
                  ),
                  DataColumn2(
                    label: const Text('Statut'),
                    size: ColumnSize.S,
                  ),
                  const DataColumn2(
                    label: Text('Actions'),
                    size: ColumnSize.S,
                  ),
                ],
                rows: _filteredOrders.map((order) {
                  return DataRow(
                      onLongPress: () => _showOrderPreview(order),
                      cells: [
                        DataCell(Text(DateFormat('dd/MM/yyyy')
                            .format(DateTime.parse(order['date'])))),
                        DataCell(Text(order['clients']?['name'] ?? 'Inconnu')),
                        DataCell(Text(order['articles']?['name'] ?? 'Inconnu')),
                        DataCell(Text(order['quantity'].toString())),
                        DataCell(_buildStatusBadge(order['status'])),
                        DataCell(
                          IconButton(
                            icon: const Icon(Icons.delete,
                                color: Colors.red, size: 20),
                            onPressed: () => _deleteOrder(order['id']),
                          ),
                        ),
                      ]);
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String? status) {
    Color color;
    switch (status) {
      case 'Stock':
        color = Colors.purple;
        break;
      case 'Finition':
        color = Colors.green;
        break;
      case 'Production':
        color = Colors.orange;
        break;
      case 'Prepresse':
        color = Colors.blue;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(51),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        status ?? 'En attente',
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildKanbanView() {
    final columns = [
      'En attente',
      'Prepresse',
      'Production',
      'Finition',
      'Stock',
      'Livraison'
    ];

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(16),
      itemCount: columns.length,
      itemBuilder: (context, index) {
        final status = columns[index];
        final ordersInStatus = _filteredOrders
            .where((o) => (o['status'] ?? 'En attente') == status)
            .toList();

        return _buildKanbanColumn(status, ordersInStatus);
      },
    );
  }

  Widget _buildKanbanColumn(String status, List<Map<String, dynamic>> orders) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(status,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('${orders.length}',
                      style: const TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: DragTarget<int>(
              onWillAcceptWithDetails: (details) => true,
              onAcceptWithDetails: (details) {
                _updateOrderStatus(details.data, status);
              },
              builder: (context, candidateData, rejectedData) {
                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    return Draggable<int>(
                      data: order['id'],
                      feedback: SizedBox(
                        width: 260,
                        child: ModernCard(
                          child: Text(order['articles']?['name'] ?? 'Article'),
                        ),
                      ),
                      childWhenDragging: Opacity(
                        opacity: 0.5,
                        child: _buildKanbanCard(order, status),
                      ),
                      child: _buildKanbanCard(order, status),
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

  Widget _buildKanbanCard(Map<String, dynamic> order, String status) {
    final isStock = status == 'Stock';
    final isProduction = status == 'Production';
    final orderRef = order['order_ref'] ?? '';

    return GestureDetector(
      onLongPressStart: (details) {
        if (isStock) {
          _showStockQuickEdit(order);
        } else {
          showMenu(
            context: context,
            position: RelativeRect.fromLTRB(
              details.globalPosition.dx,
              details.globalPosition.dy,
              details.globalPosition.dx,
              details.globalPosition.dy,
            ),
            items: [
              if (isProduction)
                const PopupMenuItem(
                  value: 'production',
                  child: Row(
                    children: [
                      Icon(Icons.factory),
                      SizedBox(width: 8),
                      Text('Saisir Production (m)'),
                    ],
                  ),
                ),
              const PopupMenuItem(
                value: 'split',
                child: Row(
                  children: [
                    Icon(Icons.call_split),
                    SizedBox(width: 8),
                    Text('Diviser la commande'),
                  ],
                ),
              ),
            ],
          ).then((value) {
            if (value == 'split') {
              _showSplitOrderDialog(order);
            } else if (value == 'production') {
              _showProductionInput(order);
            }
          });
        }
      },
      onDoubleTap: () => _showOrderPreview(order),
      child: ModernCard(
        margin: const EdgeInsets.only(bottom: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(order['clients']?['name'] ?? 'Client Inconnu',
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
                if (orderRef.isNotEmpty)
                  GestureDetector(
                    onTap: () => _showOrderHistory(order['id']),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(orderRef,
                          style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue)),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(order['articles']?['name'] ?? 'Article Inconnu',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),

            // Global Progress Indicator
            if (orderRef.isNotEmpty) ...[
              Builder(builder: (context) {
                final related =
                    _orders.where((o) => o['order_ref'] == orderRef).toList();
                final totalDelivered = related
                    .where((o) => o['status'] == 'Livraison')
                    .fold(0, (sum, o) => sum + (o['quantity'] as int));
                final initialQty = order['initial_quantity'] ?? 0;
                final progress =
                    initialQty > 0 ? totalDelivered / initialQty : 0.0;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LinearProgressIndicator(
                      value: progress.clamp(0.0, 1.0),
                      backgroundColor: Colors.grey.shade200,
                      color: Colors.green,
                      minHeight: 4,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Reste: ${initialQty - totalDelivered} / $initialQty',
                      style:
                          TextStyle(fontSize: 10, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 8),
                  ],
                );
              }),
            ],

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (isStock)
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline, size: 20),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () {
                          final currentQty = order['quantity'] as int;
                          if (currentQty > 0) {
                            _updateOrderQuantity(order['id'], currentQty - 1);
                          }
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text('${order['quantity']}',
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline, size: 20),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () {
                          final currentQty = order['quantity'] as int;
                          _updateOrderQuantity(order['id'], currentQty + 1);
                        },
                      ),
                    ],
                  )
                else
                  Text('${order['quantity']} unités',
                      style: const TextStyle(fontSize: 12)),
                Text(DateFormat('dd/MM').format(DateTime.parse(order['date'])),
                    style: const TextStyle(fontSize: 10)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPipelineView() {
    final statuses = [
      'En attente',
      'Prepresse',
      'Production',
      'Finition',
      'Stock',
      'Livraison'
    ];

    return DefaultTabController(
      length: statuses.length,
      child: Column(
        children: [
          Container(
            color: Colors.grey.shade100,
            child: TabBar(
              isScrollable: true,
              labelColor: Theme.of(context).primaryColor,
              unselectedLabelColor: Colors.grey,
              tabs: statuses.map((s) => Tab(text: s)).toList(),
            ),
          ),
          Expanded(
            child: TabBarView(
              children: statuses.map((status) {
                final ordersInStatus = _filteredOrders
                    .where((o) => (o['status'] ?? 'En attente') == status)
                    .toList();
                return _buildPipelineList(status, ordersInStatus, statuses);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPipelineList(String currentStatus,
      List<Map<String, dynamic>> orders, List<String> allStatuses) {
    if (orders.isEmpty) {
      return const Center(
        child: Text('Aucune commande dans ce statut',
            style: TextStyle(color: Colors.grey)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        final clientName = order['clients']?['name'] ?? 'Inconnu';
        final articleName = order['articles']?['name'] ?? 'Inconnu';
        final currentIndex = allStatuses.indexOf(currentStatus);

        return ModernCard(
          margin: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(articleName,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                      DateFormat('dd/MM').format(DateTime.parse(order['date'])),
                      style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
              Text(clientName, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Chip(label: Text('${order['quantity']} ex')),
                  const Spacer(),
                  if (currentIndex > 0)
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => _updateOrderStatus(
                          order['id'], allStatuses[currentIndex - 1]),
                      tooltip: 'Statut précédent',
                    ),
                  if (currentIndex < allStatuses.length - 1)
                    IconButton.filled(
                      icon: const Icon(Icons.arrow_forward),
                      onPressed: () => _updateOrderStatus(
                          order['id'], allStatuses[currentIndex + 1]),
                      tooltip: 'Statut suivant',
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
