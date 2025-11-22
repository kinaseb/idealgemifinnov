import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
//import 'package:ideal_calcule/class/donnees.dart';
import './calcul_metrage_page.dart';
import './calcul_prix_page.dart';

class CalculatorHostPage extends StatefulWidget {
  const CalculatorHostPage({super.key});

  @override
  State<CalculatorHostPage> createState() => _CalculatorHostPageState();
}

class _CalculatorHostPageState extends State<CalculatorHostPage> {
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

  @override
  void initState() {
    super.initState();
    // Add listeners to recalculate everything when user types in these fields
    txtQtCommande.addListener(_recalculateAll);
    txtQtMetrage.addListener(_recalculateAll);
    txtLzBobM.addListener(_recalculateAll);
    txtLzBobFille.addListener(_recalculateAll);
    txtPrixSupport.addListener(_recalculateAll);
    _recalculateAll();
  }

  @override
  void dispose() {
    txtQtCommande.dispose();
    txtQtMetrage.dispose();
    txtLzBobM.dispose();
    txtLzBobFille.dispose();
    txtPrixSupport.dispose();
    txtCoeficient.dispose();
    txtPrixTTC.dispose();
    txtPrixHT.dispose();
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
    metrage = (repeat > 0 && pose > 0 && commande > 0)
        ? (commande / (1000 / (repeat * 3.175) * pose)).floor().toDouble()
        : 0;
  }

  void _qntselonmetrage() {
    final repeat = int.tryParse(choixRepeat) ?? 0;
    final pose = int.tryParse(poseChoix) ?? 0;
    final qtmetre = int.tryParse(txtQtMetrage.text.replaceAll(' ', '')) ?? 0;
    if (repeat > 0 && pose > 0) {
      etiqbobf = ((1000 / (repeat * 3.175) * pose) * 1000).floor().toDouble();
      qtmetrage = (qtmetre > 0)
          ? ((1000 / (repeat * 3.175) * pose) * qtmetre).floor().toDouble()
          : 0;
    } else {
      etiqbobf = 0;
      qtmetrage = 0;
    }
  }

  void _calculecoupebobine() {
    final lzBobF = int.tryParse(txtLzBobFille.text) ?? 0;
    final lzBobM = int.tryParse(txtLzBobM.text) ?? 0;
    if (lzBobF > 0 && lzBobM > 0) {
      nbrbobf = lzBobM ~/ lzBobF;
      chutteBobMere = lzBobM % lzBobF;
      etiqbobMere = etiqbobf * nbrbobf;
    } else {
      nbrbobf = 0;
      chutteBobMere = 0;
      etiqbobMere = 0;
    }
  }

  void _calculePrix() {
    final prixSupport = double.tryParse(txtPrixSupport.text) ?? 0.0;
    final lzBobMer = int.tryParse(txtLzBobM.text) ?? 0;
    if (prixSupport > 0 && lzBobMer > 0 && etiqbobMere > 0) {
      final prixSupportM2 = prixSupport / 1000;
      if (choixInclureChute == "oui") {
        prixrevienEtiquetteTTC = (prixSupportM2 * lzBobMer) / etiqbobMere;
      } else {
        final prixSupportsansChutte = (prixSupportM2 * (lzBobMer - chutteBobMere));
        prixrevienEtiquetteTTC = prixSupportsansChutte / etiqbobMere;
      }
    } else {
      prixrevienEtiquetteTTC = 0;
    }
  }

  void _calculePrixVente() {
    final coef = double.tryParse(txtCoeficient.text.replaceAll(',', '.')) ?? 0.0;
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
  }

  void _calculeCoefVente() {
    final prixTTC = double.tryParse(txtPrixTTC.text.replaceAll(' ', '').replaceAll(',', '.')) ?? 0.0;
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

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Ideal Calcule'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.straighten), text: 'Métrage'),
              Tab(icon: Icon(Icons.price_change), text: 'Prix'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            CalculMetragePage(
              txtQtCommande: txtQtCommande,
              txtQtMetrage: txtQtMetrage,
              choixRepeat: choixRepeat,
              poseChoix: poseChoix,
              metrage: metrage,
              qtmetrage: qtmetrage,
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
            ),
          ],
        ),
      ),
    );
  }
}
