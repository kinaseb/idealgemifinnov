import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../services/supabase_service.dart';
import '../class/client.dart';
import '../class/article.dart';
import '../class/etiquette.dart';
import '../widgets/modern_card.dart';
import '../widgets/image_zoom_dialog.dart';
import '../pages/employees_page.dart';

class NewOrderPage extends StatefulWidget {
  const NewOrderPage({super.key});

  @override
  State<NewOrderPage> createState() => _NewOrderPageState();
}

class _NewOrderPageState extends State<NewOrderPage> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _clientController = TextEditingController();
  final _articleController = TextEditingController();

  List<Client> _clients = [];
  List<Article> _articles = [];

  Client? _selectedClient;
  Article? _selectedArticle;
  DateTime _selectedDate = DateTime.now();
  double _calculatedMetrage = 0.0;

  @override
  void initState() {
    super.initState();
    _loadData();
    _quantityController.addListener(_calculateMetrage);
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _clientController.dispose();
    _articleController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final clients = await SupabaseService().client.from('clients').select();
    setState(() {
      _clients = clients.map((c) => Client.fromSupabaseMap(c)).toList();
    });
  }

  Future<void> _loadArticlesForClient(int clientId) async {
    final articles = await SupabaseService()
        .client
        .from('articles')
        .select()
        .eq('client_id', clientId);
    setState(() {
      _articles = articles.map((a) => Article.fromSupabaseMap(a)).toList();
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

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]} ',
        );
  }

  void _showImageZoom(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => ImageZoomDialog(imageUrl: imageUrl),
    );
  }

  void _showArticleDetailsForSelection(Article article) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(article.name),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.5,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (article.photo != null)
                  Center(
                    child: GestureDetector(
                      onTap: () => _showImageZoom(article.photo!),
                      child: Container(
                        height: 200,
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
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow('Type', article.type),
                      _buildDetailRow('Machine', article.machine),
                      _buildDetailRow('Couleurs', '${article.colorCount}'),
                      const Divider(height: 16),
                      _buildDetailRow('Laize', '${article.width} mm',
                          isBold: true),
                      _buildDetailRow('Répétition', '${article.repeat} mm'),
                      _buildDetailRow('Poses', '${article.poseCount}'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _selectedArticle = article;
                _articleController.text = article.name;
                _calculateMetrage();
              });
              Navigator.pop(context); // Close details
              Navigator.pop(context); // Close gallery
            },
            icon: const Icon(Icons.check),
            label: const Text('Sélectionner'),
          ),
        ],
      ),
    );
  }

  void _showClientArticlesGallery(Client client) {
    final clientArticles =
        _articles.where((a) => a.clientId == client.id).toList();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            if (client.logoPath != null)
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: CircleAvatar(
                  backgroundImage: NetworkImage(client.logoPath!),
                  radius: 20,
                ),
              ),
            Expanded(child: Text('Articles de ${client.name}')),
          ],
        ),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.7,
          height: MediaQuery.of(context).size.height * 0.6,
          child: clientArticles.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inventory_2_outlined,
                          size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Aucun article pour ce client',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount:
                        MediaQuery.of(context).size.width > 600 ? 3 : 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: clientArticles.length,
                  itemBuilder: (context, index) {
                    final article = clientArticles[index];
                    return GestureDetector(
                      onTap: () => _showArticleDetailsForSelection(article),
                      child: Card(
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: article.photo != null
                                  ? Image.network(
                                      article.photo!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stack) =>
                                          Container(
                                        color: Colors.grey.shade200,
                                        child: const Icon(
                                            Icons.image_not_supported,
                                            size: 48,
                                            color: Colors.grey),
                                      ),
                                    )
                                  : Container(
                                      color: Colors.grey.shade200,
                                      child: const Icon(Icons.image,
                                          size: 48, color: Colors.grey),
                                    ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    article.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${article.width}mm • ${article.poseCount} poses',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
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
          // Reset form
          _quantityController.clear();
          setState(() {
            _selectedArticle = null;
            _articleController.clear();
            _calculatedMetrage = 0.0;
          });
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
    if (_selectedClient != null &&
        _selectedArticle != null &&
        _quantityController.text.isNotEmpty) {
      final qty = int.parse(_quantityController.text.replaceAll(' ', ''));
      final text = '''
Nouvelle Commande
Client: ${_selectedClient!.name}
Article: ${_selectedArticle!.name}
Date: ${DateFormat('dd/MM/yyyy').format(_selectedDate)}
Quantité: $qty
Métrage: ${_calculatedMetrage.toStringAsFixed(0)} m
''';
      await Share.share(text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouvelle Commande'),
        actions: [
          IconButton(
            icon: const Icon(Icons.people),
            tooltip: 'Gérer les employés',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EmployeesPage()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Client Section
                  ModernCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Client',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            if (_selectedClient?.logoPath != null)
                              Padding(
                                padding: const EdgeInsets.only(right: 12),
                                child: GestureDetector(
                                  onTap: () => _showClientArticlesGallery(
                                      _selectedClient!),
                                  child: CircleAvatar(
                                    backgroundImage: NetworkImage(
                                        _selectedClient!.logoPath!),
                                    radius: 24,
                                  ),
                                ),
                              ),
                            Expanded(
                              child: DropdownMenu<Client>(
                                controller: _clientController,
                                label: const Text('Sélectionner un client'),
                                enableFilter: true,
                                expandedInsets: EdgeInsets.zero,
                                dropdownMenuEntries: _clients.map((c) {
                                  return DropdownMenuEntry<Client>(
                                      value: c, label: c.name);
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
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Article Section
                  ModernCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Article',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            if (_selectedArticle?.photo != null)
                              Padding(
                                padding: const EdgeInsets.only(right: 12),
                                child: GestureDetector(
                                  onTap: () =>
                                      _showImageZoom(_selectedArticle!.photo!),
                                  child: Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      image: DecorationImage(
                                        image: NetworkImage(
                                            _selectedArticle!.photo!),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            Expanded(
                              child: DropdownMenu<Article>(
                                controller: _articleController,
                                enabled: _selectedClient != null,
                                label: const Text('Sélectionner un article'),
                                enableFilter: true,
                                expandedInsets: EdgeInsets.zero,
                                dropdownMenuEntries: _articles.map((a) {
                                  return DropdownMenuEntry<Article>(
                                      value: a, label: a.name);
                                }).toList(),
                                onSelected: (Article? article) {
                                  setState(() {
                                    _selectedArticle = article;
                                    _calculateMetrage();
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Details Section
                  ModernCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Détails Commande',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 16),

                        // Date
                        InkWell(
                          onTap: () => _selectDate(context),
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Date',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.calendar_today),
                            ),
                            child: Text(
                                DateFormat('dd/MM/yyyy').format(_selectedDate)),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Quantity with 1K button
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _quantityController,
                                decoration: const InputDecoration(
                                  labelText: 'Quantité',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.numbers),
                                ),
                                keyboardType: TextInputType.number,
                                validator: (val) => (val == null || val.isEmpty)
                                    ? 'Requis'
                                    : null,
                                onChanged: (value) {
                                  final cleanValue = value.replaceAll(' ', '');
                                  if (cleanValue.isNotEmpty) {
                                    final number = int.tryParse(cleanValue);
                                    if (number != null) {
                                      final formatted = _formatNumber(number);
                                      if (formatted != value) {
                                        _quantityController.value =
                                            TextEditingValue(
                                          text: formatted,
                                          selection: TextSelection.collapsed(
                                            offset: formatted.length,
                                          ),
                                        );
                                      }
                                    }
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            SizedBox(
                              height: 58,
                              child: ElevatedButton(
                                onPressed: () {
                                  final current = int.tryParse(
                                          _quantityController.text
                                              .replaceAll(' ', '')) ??
                                      0;
                                  final newValue = current * 1000;
                                  _quantityController.text =
                                      _formatNumber(newValue);
                                  _calculateMetrage();
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                ),
                                child: const Text('1K',
                                    style: TextStyle(fontSize: 18)),
                              ),
                            ),
                          ],
                        ),

                        // Calculated Metrage
                        if (_calculatedMetrage > 0) ...[
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: Colors.blue.shade200, width: 2),
                            ),
                            child: Column(
                              children: [
                                const Text('Métrage Nécessaire',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    )),
                                const SizedBox(height: 8),
                                Text(
                                    '${_calculatedMetrage.toStringAsFixed(0)} m',
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue.shade700,
                                    )),
                                const SizedBox(height: 4),
                                Text(
                                    'Bobine Fille: ${_selectedArticle?.width} mm',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    )),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Actions
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _submitOrder,
                          icon: const Icon(Icons.save),
                          label: const Text('Enregistrer'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      IconButton.filledTonal(
                        onPressed: _shareOrder,
                        icon: const Icon(Icons.share),
                        iconSize: 28,
                        tooltip: 'Partager',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
