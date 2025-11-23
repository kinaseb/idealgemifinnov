import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ideal_calcule/class/etiquette.dart';
import 'package:ideal_calcule/class/mother_reel_data.dart';
import 'package:ideal_calcule/main.dart';
import './calcul_metrage_page.dart';
import './calcul_prix_page.dart';
import './calcul_coupe_page.dart';
import './calcul_piece_page.dart';
import './calcul_manchon_page.dart';

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);

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

  void _performTransfer(double laizeFille, {required bool overwrite}) {
    setState(() {
      if (overwrite) {
        for (var reel in _motherReels) {
          reel.dispose();
        }
        _motherReels.clear();
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

      _motherReels.add(newReel);

      // Switch to Coupe tab
      _tabController.animateTo(2);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ideal Calcule'),
        actions: [
          ValueListenableBuilder<ThemeMode>(
            valueListenable: themeNotifier,
            builder: (context, mode, _) {
              return IconButton(
                icon: Icon(mode == ThemeMode.dark
                    ? Icons.light_mode
                    : Icons.dark_mode),
                onPressed: () {
                  themeNotifier.value =
                      mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
                },
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.straighten), text: 'Métrage'),
            Tab(icon: Icon(Icons.calculate), text: 'Prix'),
            Tab(icon: Icon(Icons.content_cut), text: 'Coupe'),
            Tab(icon: Icon(Icons.flip_to_front), text: 'Sleeve'),
            Tab(icon: Icon(Icons.construction), text: 'Pièce'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
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
          ),
          CalculCoupePage(motherReels: _motherReels),
          const CalculManchonPage(),
          const CalculPiecePage(),
        ],
      ),
    );
  }
}
