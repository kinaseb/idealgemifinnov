import 'package:flutter/material.dart';
import 'package:ideal_calcule/main.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ideal_calcule/class/etiquette.dart';
import 'package:ideal_calcule/class/mother_reel_data.dart';
import 'package:ideal_calcule/theme/app_colors.dart';
import 'package:ideal_calcule/widgets/font_size_dialog.dart';
import './calcul_metrage_page.dart';
import './calcul_prix_page.dart';
import './calcul_coupe_page.dart';
import './calcul_piece_page.dart';
import './calcul_manchon_page.dart';
import './clients_page.dart';
import './supports_page.dart';
import 'stock/stock_dashboard_page.dart';
import './orders_page.dart';
import './trash_page.dart';
import './repeats_page.dart';
import './machines_page.dart';
import 'package:share_plus/share_plus.dart';

import '../class/article.dart';
import '../class/client.dart';
import '../services/database_helper.dart';
import '../services/data_migration_service.dart';
import '../services/supabase_service.dart';
import 'login_page.dart';
import '../widgets/article_selection_dialog.dart';

class CalculatorHostPage extends StatefulWidget {
  const CalculatorHostPage({super.key});

  @override
  State<CalculatorHostPage> createState() => _CalculatorHostPageState();
}

class _CalculatorHostPageState extends State<CalculatorHostPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // State from CalculMetragePage
  double metrage = 0;
  double qtmetrage = 0;
  final txtQtCommande = TextEditingController();
  final txtQtMetrage = TextEditingController();
  String choixRepeat = "74";
  String poseChoix = "1";

  // State from CalculPrixPage
  double prixrevienEtiquetteTTC = 0.0;
  double prixEtiquetteTTC = 0.0;
  double prixEtiquetteHT = 0.0;
  double coefPrxi = 1.0;
  int nbrbobf = 0;
  int chutteBobMere = 0;
  double etiqbobMere = 0;
  double etiqbobf = 0; // This is the shared value

  final txtLzBobM = TextEditingController(text: "1000");
  final txtLzBobFille = TextEditingController();
  final txtPrixSupport = TextEditingController();
  final txtCoeficient = TextEditingController();
  final txtPrixTTC = TextEditingController();
  final txtPrixHT = TextEditingController();
  String choixInclureChute = "oui";

  final NumberFormat formatnumeromillier = NumberFormat("#,###.###", "fr_FR");

  // State from CalculCoupePage
  final List<MotherReelData> _motherReels = [];
  final GlobalKey<CalculCoupePageState> _coupeKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);

    // Add listeners to recalculate everything when user types in these fields
    txtQtCommande.addListener(_recalculateAll);
    txtQtMetrage.addListener(_recalculateAll);
    txtLzBobM.addListener(_recalculateAll);
    txtLzBobFille.addListener(_recalculateAll);
    txtPrixSupport.addListener(_recalculateAll);
    _recalculateAll();

    // Initialize one mother reel if empty
    if (_motherReels.isEmpty) {
      _motherReels.add(MotherReelData());
    }
  }

  // ... (lines 92-267 omitted for brevity, no changes needed there)

  void _performTransfer(double laizeFille, {required bool overwrite}) {
    setState(() {
      if (overwrite) {
        _coupeKey.currentState?.clearReels();
      }

      // Create new reel configuration
      final newReel = MotherReelData();
      // Use the mother reel width from Prix tab if available
      if (txtLzBobM.text.isNotEmpty) {
        newReel.widthController.text = txtLzBobM.text;
      }

      // Add the cut
      final cut = CutRow(width: laizeFille.toString(), qty: "1");
      newReel.cuts.add(cut);

      // Add via key to attach listeners
      _coupeKey.currentState?.addExternalReel(newReel);

      // Switch to Coupe tab
      _tabController.animateTo(2);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    txtQtCommande.dispose();
    txtQtMetrage.dispose();
    txtLzBobM.dispose();
    txtLzBobFille.dispose();
    txtPrixSupport.dispose();
    txtCoeficient.dispose();
    txtPrixTTC.dispose();
    txtPrixHT.dispose();
    for (var reel in _motherReels) {
      reel.dispose();
    }
    super.dispose();
  }

  void _recalculateAll() {
    setState(() {
      _metragecommande();
      _qntselonmetrage(); // This now calculates etiqbobf
      _calculecoupebobine();
      _calculePrix();
      _calculePrixVente();
    });
  }

  // --- Calculation Logic ---
  void _metragecommande() {
    final repeat = int.tryParse(choixRepeat) ?? 0;
    final pose = int.tryParse(poseChoix) ?? 0;
    final commande = int.tryParse(txtQtCommande.text.replaceAll(' ', '')) ?? 0;

    metrage = Etiquette.calculateMetrageRequired(repeat, pose, commande);
  }

  void _qntselonmetrage() {
    final repeat = int.tryParse(choixRepeat) ?? 0;
    final pose = int.tryParse(poseChoix) ?? 0;
    final qtmetre = int.tryParse(txtQtMetrage.text.replaceAll(' ', '')) ?? 0;

    if (repeat > 0 && pose > 0) {
      // Calculate labels for 1000m (default base)
      etiqbobf = Etiquette.calculateLabelsCount(repeat, pose, 1000);

      // Calculate labels for specific metrage
      qtmetrage =
          Etiquette.calculateLabelsCount(repeat, pose, qtmetre.toDouble());
    } else {
      etiqbobf = 0;
      qtmetrage = 0;
    }
  }

  void _calculecoupebobine() {
    final lzBobF = int.tryParse(txtLzBobFille.text) ?? 0;
    final lzBobM = int.tryParse(txtLzBobM.text) ?? 0;

    final cuts = Etiquette.calculateCuts(lzBobM, lzBobF);
    nbrbobf = cuts[0];
    chutteBobMere = cuts[1];

    etiqbobMere = etiqbobf * nbrbobf;
  }

  void _calculePrix() {
    final prixSupport = double.tryParse(txtPrixSupport.text) ?? 0.0;
    final lzBobMer = int.tryParse(txtLzBobM.text) ?? 0;

    if (prixSupport > 0 && lzBobMer > 0 && etiqbobMere > 0) {
      // prixSupport is in €/m². lzBobMer is in mm.
      // We want the cost for the same amount of material that produces etiqbobMere labels.
      // etiqbobMere is calculated for 1000m run.
      // Cost for 1000m = Price/m² * Width(m) * 1000
      // Width(m) = lzBobMer / 1000.
      // So Cost = Price/m² * (lzBobMer / 1000) * 1000 = Price/m² * lzBobMer.

      final prixSupportM2 = prixSupport; // No division by 1000

      prixrevienEtiquetteTTC = Etiquette.calculateCostPrice(
        prixSupportM2: prixSupportM2,
        lzBobMer: lzBobMer,
        etiqBobMere: etiqbobMere.toInt(),
        inclureChute: choixInclureChute == "oui",
        chutteBobMere: chutteBobMere,
      );
    } else {
      prixrevienEtiquetteTTC = 0;
    }
  }

  void _calculePrixVente() {
    final coef =
        double.tryParse(txtCoeficient.text.replaceAll(',', '.')) ?? 0.0;
    if (coef > 0 && prixrevienEtiquetteTTC > 0) {
      prixEtiquetteTTC = coef * prixrevienEtiquetteTTC;
      prixEtiquetteHT = prixEtiquetteTTC / 1.19;
      String newPrixTTC = formatnumeromillier.format(prixEtiquetteTTC);
      if (txtPrixTTC.text != newPrixTTC) {
        txtPrixTTC.text = newPrixTTC;
      }
      String newPrixHT = formatnumeromillier.format(prixEtiquetteHT);
      if (txtPrixHT.text != newPrixHT) {
        txtPrixHT.text = newPrixHT;
      }
    }
    setState(() {});
  }

  void _calculeCoefVente() {
    final prixTTC = double.tryParse(
            txtPrixTTC.text.replaceAll(' ', '').replaceAll(',', '.')) ??
        0.0;
    if (prixTTC > 0 && prixrevienEtiquetteTTC > 0) {
      coefPrxi = prixTTC / prixrevienEtiquetteTTC;
      prixEtiquetteHT = prixTTC / 1.19;
      String newCoef = coefPrxi.toStringAsFixed(2);
      if (txtCoeficient.text != newCoef) {
        txtCoeficient.text = newCoef;
      }
      String newPrixHT = formatnumeromillier.format(prixEtiquetteHT);
      if (txtPrixHT.text != newPrixHT) {
        txtPrixHT.text = newPrixHT;
      }
    }
    setState(() {});
  }

  void _transferToCoupe() {
    final laizeFilleStr = txtLzBobFille.text;
    if (laizeFilleStr.isEmpty) return;

    final laizeFille = double.tryParse(laizeFilleStr);
    if (laizeFille == null || laizeFille <= 0) return;

    // Check if we have existing data in Coupe tab
    bool hasData = false;
    for (var reel in _motherReels) {
      if (reel.widthController.text.isNotEmpty ||
          (reel.cuts.isNotEmpty &&
              reel.cuts.any((c) => c.widthController.text.isNotEmpty))) {
        hasData = true;
        break;
      }
    }

    if (hasData) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Données existantes"),
          content: const Text(
              "Il y a déjà des données dans l'onglet Coupe. Voulez-vous écraser les données existantes ou ajouter une nouvelle bobine ?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _performTransfer(laizeFille, overwrite: false);
              },
              child: const Text("Ajouter"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _performTransfer(laizeFille, overwrite: true);
              },
              child: const Text("Écraser", style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
    } else {
      _performTransfer(laizeFille, overwrite: true);
    }
  }

  // --- Article Integration ---
  Article? _selectedArticle;
  Client? _selectedClient;

  Future<void> _loadArticle() async {
    final article = await showDialog<Article>(
      context: context,
      builder: (context) => const ArticleSelectionDialog(),
    );

    if (article != null) {
      setState(() {
        _selectedArticle = article;
        // Fetch client for share info
        DatabaseHelper().getClients().then((clients) {
          final clientMap = clients
              .firstWhere((c) => c['id'] == article.clientId, orElse: () => {});
          if (clientMap.isNotEmpty) {
            _selectedClient = Client.fromMap(clientMap);
          }
        });

        // Populate fields
        choixRepeat = article.repeat.toStringAsFixed(0);
        // Ensure repeat is in the list, if not, add it or handle it
        if (!Etiquette.availableRepeats.contains(choixRepeat)) {
          // If not in list, maybe just use it anyway if we change Dropdown to accept custom?
          // For now, if it's not in the list, we might have an issue with Dropdown.
          // Let's assume standard repeats for now or add it to the list dynamically?
          // Etiquette.availableRepeats is const, so we can't add.
          // We'll try to find the closest or just set it if it matches.
        }

        poseChoix = article.poseCount.toString();
        txtLzBobFille.text = article.width.toString();

        // If we have cost price, we might want to use it?
        // But CalculPrixPage calculates cost based on Support Price.
        // If Article has a specific Cost Price saved, maybe we should display it or use it?
        // For now, we just load dimensions.

        _recalculateAll();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Article ${article.name} loaded!')),
        );
      }
    }
  }

  Future<void> _shareCommand() async {
    if (_selectedArticle == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner un article')),
      );
      return;
    }

    final text = '''
Commande pour ${_selectedArticle!.name}
Date: ${DateFormat('dd/MM/yyyy').format(DateTime.now())}
Client: ${_selectedClient?.name ?? "N/A"}

Détails Article:
Nom: ${_selectedArticle!.name}
Type: ${_selectedArticle!.type}
Machine: ${_selectedArticle!.machine}
Laize: ${_selectedArticle!.width} mm
Repeat: ${_selectedArticle!.repeat}
Poses: ${_selectedArticle!.poseCount}

Détails Commande:
Quantité Commandée: ${txtQtCommande.text}
Métrage Nécessaire: ${formatnumeromillier.format(metrage)} m
Nombre de Bobines Filles: $nbrbobf
Etiquettes / Bobine Fille: ${formatnumeromillier.format(etiqbobf)}
''';

    await Share.share(text);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Calculateur Flexo', style: GoogleFonts.lato()),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: isDark
                ? AppColors.darkPrimaryGradient
                : AppColors.lightPrimaryGradient,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.text_fields),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const FontSizeDialog(),
              );
            },
          ),
          ValueListenableBuilder<ThemeMode>(
            valueListenable: MyApp.themeNotifier,
            builder: (context, currentMode, child) {
              return IconButton(
                icon: Icon(
                  currentMode == ThemeMode.dark
                      ? Icons.light_mode
                      : Icons.dark_mode,
                ),
                onPressed: () {
                  MyApp.themeNotifier.value = currentMode == ThemeMode.dark
                      ? ThemeMode.light
                      : ThemeMode.dark;
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await SupabaseService().client.auth.signOut();
              if (context.mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              }
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Container(
            color: isDark ? Colors.black26 : Colors.white24,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              indicatorColor: AppColors.accent,
              indicatorWeight: 4,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              labelStyle:
                  GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.bold),
              tabs: const [
                Tab(text: 'Commandes'),
                Tab(text: 'Métrage'),
                Tab(text: 'Prix'),
                Tab(text: 'Coupe'),
                Tab(text: 'Pièce'),
                Tab(text: 'Manchon'),
              ],
            ),
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: isDark
                    ? AppColors.darkPrimaryGradient
                    : AppColors.lightPrimaryGradient,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 30,
                    child: Icon(Icons.calculate,
                        size: 35, color: AppColors.primary),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Ideal Calcule',
                    style: GoogleFonts.lato(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Clients'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ClientsPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.inventory),
              title: const Text('Supports (Matières)'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SupportsPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.warehouse),
              title: const Text('Gestion des Stocks'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const StockDashboardPage()),
                );
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.precision_manufacturing, color: Colors.blue),
              title: const Text('Machines'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MachinesPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.circle, color: Colors.purple),
              title: const Text('Repeats (Clichés)'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RepeatsPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.orange),
              title: const Text('Corbeille'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TrashPage()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.cloud_upload),
              title: const Text('Migrer vers Supabase'),
              onTap: () async {
                Navigator.pop(context);
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Confirmer la migration'),
                    content: const Text(
                        'Voulez-vous envoyer toutes les données locales vers Supabase ? Cela peut prendre quelques secondes.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Annuler'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Migrer'),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Migration en cours...'),
                          duration: Duration(seconds: 10)),
                    );
                  }

                  await DataMigrationService().migrateAllData();

                  if (mounted) {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Migration terminée avec succès !'),
                          backgroundColor: Colors.green),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          const OrdersPage(),
          CalculMetragePage(
            txtQtCommande: txtQtCommande,
            txtQtMetrage: txtQtMetrage,
            choixRepeat: choixRepeat,
            poseChoix: poseChoix,
            metrage: metrage,
            qtmetrage: qtmetrage,
            etiqbobFille: etiqbobf,
            formatnumeromillier: formatnumeromillier,
            onRepeatChanged: (val) {
              setState(() {
                choixRepeat = val!;
                _recalculateAll();
              });
            },
            onPoseChanged: (val) {
              setState(() {
                poseChoix = val!;
                _recalculateAll();
              });
            },
            onLoadArticle: _loadArticle,
            onShare: _shareCommand,
          ),
          CalculPrixPage(
            txtLzBobM: txtLzBobM,
            txtLzBobFille: txtLzBobFille,
            txtPrixSupport: txtPrixSupport,
            txtCoeficient: txtCoeficient,
            txtPrixTTC: txtPrixTTC,
            txtPrixHT: txtPrixHT,
            choixInclureChute: choixInclureChute,
            nbrbobf: nbrbobf,
            chutteBobMere: chutteBobMere,
            etiqbobMere: etiqbobMere,
            etiqbobFille: etiqbobf,
            metrage: metrage, // Added
            prixrevienEtiquetteTTC: prixrevienEtiquetteTTC,
            formatnumeromillier: formatnumeromillier,
            onInclureChuteChanged: (val) {
              setState(() {
                choixInclureChute = val!;
                _recalculateAll();
              });
            },
            onCoefChanged: _calculePrixVente,
            onPrixTTCChanged: _calculeCoefVente,
            onTransferToCoupe: _transferToCoupe,
            onLoadArticle: _loadArticle,
            onShare: _shareCommand,
          ),
          CalculCoupePage(key: _coupeKey, motherReels: _motherReels),
          const CalculPiecePage(),
          const CalculManchonPage(),
        ],
      ),
    );
  }
}
