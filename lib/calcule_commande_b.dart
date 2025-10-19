//import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:ideal_calcule/class/donnees.dart';
import 'package:intl/intl.dart';
//import 'package:toggle_switch/toggle_switch.dart';

class ScreanCommandeMetrage extends StatefulWidget {
  const ScreanCommandeMetrage({super.key});

  @override
  State<ScreanCommandeMetrage> createState() => _ScreanCommandeMetrageState();
}

class _ScreanCommandeMetrageState extends State<ScreanCommandeMetrage> {
  // State variables moved from global scope
  double metrage = 0;
  double qtmetrage = 0;
  double etiqbobf = 0;
  double etiqbobMere = 0;
  int lzbm = 1000;
  int lzbf = 0;
  int nbrbobf = 0;
  int chutteBobMere = 0;

  double prixrevienEtiquetteTTC = 0.0;
  double coefPrxi = 1.0;
  double prixEtiquetteTTC = 0.0;
  double prixEtiquetteHT = 0.0;

  final NumberFormat formatnumeromillier = NumberFormat("#,###", "fr_FR");

  // TextEditingControllers are now state variables
  final txtQtCommande = TextEditingController();
  final txtQtMetrage = TextEditingController();
  final txtLzBobM = TextEditingController();
  final txtLzBobFille = TextEditingController();
  final txtPrixSupport = TextEditingController();
  final txtCoeficient = TextEditingController();
  final txtPrixTTC = TextEditingController();
  final txtPrixHT = TextEditingController();

  // Magic number given a descriptive name
  static const double DENT_TO_MM_CONVERSION = 3.175;

  String choixRepeat = "74";
  String poseChoix = "1";
  String choixInclureChute = "oui";
  int intPose = 0;
  double intRepeat = 0.0;
  String labelName = "commande";
  String bttext = "1K";
  int valueBut = 10000;
  int value = 100000;
  int intQtcommande = 0;
  double metrageCommande = 0;
  List<String> choixinclureList = ['Oui', 'Non'];
  int repeat = 0;
  int pose = 0;
  int commande = 0;
  Color coulourcont = Colors.blueGrey;
  Color coulourtxtint = Colors.white;

  @override
  void initState() {
    super.initState();
    // Initialize controllers and perform initial calculation
    txtLzBobM.text = "1000";
    _recalculateAll();
  }

  @override
  void dispose() {
    // Dispose controllers to prevent memory leaks
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

  // --- Calculation Logic moved into State class ---

  @override
  Widget build(BuildContext context) {
    //txtQtCommande.text = "100 000";
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Calculatrice Metrage Commande",
          style: TextStyle(
              fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        shadowColor: coulourcont,
        elevation: 10,
        backgroundColor: coulourcont,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // const SizedBox(
            //   height: 00,
            // ),
            Row(
              children: [
                const SizedBox(
                  height: 100,
                ),
                const Padding(
                  //repeat label
                  padding: EdgeInsets.all(10.0),
                  child: Text(
                    "Repeat :",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  //repeat
                  padding: const EdgeInsets.only(left: 5.0),
                  child: DropdownButton<String>(
                    padding: const EdgeInsets.all(10),
                    style: const TextStyle(
                        fontSize: 30,
                        color: Colors.black,
                        fontWeight: FontWeight.bold),
                    value: choixRepeat,
                    items: listRepeat.map((String repeat) {
                      return DropdownMenuItem<String>(
                        value: repeat,
                        child: Text(repeat),
                      );
                    }).toList(),
                    onChanged: (String? repeat) {
                      setState(() {
                        choixRepeat = repeat!;
                        _recalculateAll();
                      });
                    },
                  ),
                ),
                const Padding(
                  //poselabel
                  padding: EdgeInsets.only(left: 8.0, right: 8),
                  child: Text(
                    "Pose :",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  //pose
                  padding: const EdgeInsets.only(left: 5.0),
                  child: DropdownButton<String>(
                    padding: const EdgeInsets.all(10),
                    style: const TextStyle(
                        fontSize: 30,
                        color: Colors.black,
                        fontWeight: FontWeight.bold),
                    value: poseChoix,
                    items: nbrPose.map((String e) {
                      return DropdownMenuItem<String>(
                        value: e,
                        child: Text(e),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      setState(
                        () {
                          poseChoix = value!;
                          if (poseChoix != "") {
                            intPose = int.parse(poseChoix);
                            intRepeat = double.parse(choixRepeat);
                            poseChoix = intPose.toString();
                          }
                          _recalculateAll();
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
            buildInfoRowPerso("Etiq BobF : ", etiqbobf, Colors.grey),

            Row(
              children: [
                Padding(
                  //commande lable
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    labelName,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  //commande
                  width: 150,
                  child: TextFormField(
                    //initialValue: NumberFormat("#,##0", "en_US")
                    //  .format(double.parse(txtQtCommande.text)),
                    controller: txtQtCommande,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 25, fontWeight: FontWeight.bold),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        _metragecommande();
                      });
                    },
                  ),
                ),
                OutlinedButton(
                  //btn  000
                  onPressed: () {
                    setState(() {
                      final currentValue = int.tryParse(txtQtCommande.text) ?? 0;
                      if (currentValue > 0) {
                        txtQtCommande.text = (currentValue * 1000).toString();
                        _metragecommande();
                      }
                    });
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStatePropertyAll(coulourcont),
                  ),
                  child: Text(
                    bttext,
                    style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: coulourtxtint),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            buildInfoRowPerso("Metrage    : ", metrage, Colors.grey),

            Divider(
              color: coulourcont,
              thickness: 10,
              height: 40,
            ),

            Row(
              children: [
                const Padding(
                  //commande lable
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "Nbr Metre",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  //commande
                  width: 150,
                  child: TextFormField(
                    // initialValue: "$value",
                    controller: txtQtMetrage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 25, fontWeight: FontWeight.bold),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        _qntselonmetrage();
                      });
                    },
                  ),
                ),
                OutlinedButton(
                  //btn  000
                  onPressed: () {
                    setState(() {
                      final currentValue = int.tryParse(txtQtMetrage.text) ?? 0;
                      if (currentValue > 0) {
                        txtQtMetrage.text = (currentValue * 1000).toString();
                        _qntselonmetrage();
                      }
                    });
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStatePropertyAll(coulourcont),
                  ),
                  child: Text(
                    bttext,
                    style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: coulourtxtint),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            buildInfoRowPerso("Etiq BobF : ", qtmetrage, Colors.grey),

            Divider(
              color: coulourcont,
              thickness: 10,
              height: 40,
            ),

            buildInfoRowPerso("Etiq BobF : ", etiqbobf, Colors.grey),

            Row(
              children: [
                const Padding(
                  // metrage label
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "Laize BF   : ",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  //commande
                  width: 150,
                  child: TextFormField(
                    // initialValue: "$value",
                    controller: txtLzBobFille,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 25, fontWeight: FontWeight.bold),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        _recalculateAll();
                      });
                    },
                  ),
                ),
              ],
            ),
            Row(
              children: [
                const Padding(
                  // metrage label
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "Laize BM  : ",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  //commande
                  width: 150,
                  child: TextFormField(
                    // initialValue: "$value",
                    controller: txtLzBobM,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 25, fontWeight: FontWeight.bold),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        _recalculateAll();
                      });
                    },
                  ),
                ),
              ],
            ),

            buildInfoRowPerso("Nbr  BF    : ", nbrbobf, Colors.grey),
            buildInfoRowPerso("Chute BM: ", chutteBobMere, Colors.red),
            buildInfoRowPerso("Etiq  BM   : ", etiqbobMere, Colors.grey),
            Divider(
              color: coulourcont,
              thickness: 10,
              height: 40,
            ),

            Row(
              children: [
                const Padding(
                  // metrage label
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "prix  Sup  : ",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  //commande
                  width: 150,
                  child: TextFormField(
                    // initialValue: "$value",
                    controller: txtPrixSupport,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 25, fontWeight: FontWeight.bold),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        _recalculateAll();
                      });
                    },
                  ),
                ),
              ],
            ),

            Row(
              children: [
                const Padding(
                  //repeat label
                  padding: EdgeInsets.all(10.0),
                  child: Text(
                    "inclure la chutte :",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  //repeat
                  padding: const EdgeInsets.only(left: 5.0),
                  child: DropdownButton<String>(
                    padding: const EdgeInsets.all(10),
                    style: const TextStyle(
                        fontSize: 30,
                        color: Colors.black,
                        fontWeight: FontWeight.bold),
                    value: choixInclureChute,
                    items: inclureChuteOuPas.map((String inclure) {
                      return DropdownMenuItem<String>(
                        value: inclure,
                        child: Text(inclure),
                      );
                    }).toList(),
                    onChanged: (String? inclure) {
                      setState(() {
                        choixInclureChute = inclure!;
                        _recalculateAll();
                      });
                    },
                  ),
                ),
              ],
            ),
            buildInfoRowPerso(
                "Etq P/Rev: ", prixrevienEtiquetteTTC, Colors.green),
            const Divider(
              color: Colors.green,
              thickness: 10,
              height: 40,
            ),

            Row(
              children: [
                const Padding(
                  // metrage label
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "Coef         : ",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  //commande
                  width: 150,
                  child: TextFormField(
                    // initialValue: "$value",
                    controller: txtCoeficient,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 25, fontWeight: FontWeight.bold),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        _calculePrixVente();
                      });
                    },
                  ),
                ),
              ],
            ),
            Row(
              children: [
                const Padding(
                  // metrage label
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "prix TTC  : ",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  //commande
                  width: 150,
                  child: TextFormField(
                    // initialValue: "$value",
                    controller: txtPrixTTC,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 25, fontWeight: FontWeight.bold),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        _calculeCoefVente();
                      });
                    },
                  ),
                ),
              ],
            ),
            Row(
              children: [
                const Padding(
                  // metrage label
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "prix HT    : ",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  //commande
                  width: 150,
                  child: TextFormField(
                    // initialValue: "$value",
                    controller: txtPrixHT,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 25, fontWeight: FontWeight.bold),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _recalculateAll() {
    _metragecommande();
    _qntselonmetrage();
    _calculecoupebobine();
    _calculePrix();
    _calculePrixVente();
  }

  void _metragecommande() {
    final repeat = int.tryParse(choixRepeat) ?? 0;
    final pose = int.tryParse(poseChoix) ?? 0;
    final commande = int.tryParse(txtQtCommande.text) ?? 0;

    if (repeat > 0 && pose > 0 && commande > 0) {
      metrage = (commande / (1000 / (repeat * DENT_TO_MM_CONVERSION) * pose))
          .floor()
          .toDouble();
    } else {
      metrage = 0;
    }
  }

  void _qntselonmetrage() {
    final repeat = int.tryParse(choixRepeat) ?? 0;
    final pose = int.tryParse(poseChoix) ?? 0;
    final qtmetre = int.tryParse(txtQtMetrage.text) ?? 0;

    if (repeat > 0 && pose > 0) {
      etiqbobf = ((1000 / (repeat * DENT_TO_MM_CONVERSION) * pose) * 1000)
          .floor()
          .toDouble();
      if (qtmetre > 0) {
        qtmetrage = ((1000 / (repeat * DENT_TO_MM_CONVERSION) * pose) * qtmetre)
            .floor()
            .toDouble();
      } else {
        qtmetrage = 0;
      }
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
      final prixSupportM2 = prixSupport * 1000;
      if (choixInclureChute == "oui") {
        prixrevienEtiquetteTTC = prixSupportM2 / etiqbobMere;
      } else {
        final prixSupportsansChutte =
            ((lzBobMer - chutteBobMere) * prixSupportM2) / 1000;
        prixrevienEtiquetteTTC = prixSupportsansChutte / etiqbobMere;
      }
    } else {
      prixrevienEtiquetteTTC = 0;
    }
  }

  void _calculePrixVente() {
    final coef = double.tryParse(txtCoeficient.text) ?? 0.0;
    if (coef > 0 && prixrevienEtiquetteTTC > 0) {
      prixEtiquetteTTC = coef * prixrevienEtiquetteTTC;
      prixEtiquetteHT = prixEtiquetteTTC / 1.19;
      txtPrixTTC.text = prixEtiquetteTTC.toStringAsFixed(3);
      txtPrixHT.text = prixEtiquetteHT.toStringAsFixed(3);
    } else {
      // Keep user input if any, otherwise clear
    }
  }

  void _calculeCoefVente() {
    final prixTTC = double.tryParse(txtPrixTTC.text) ?? 0.0;
    if (prixTTC > 0 && prixrevienEtiquetteTTC > 0) {
      coefPrxi = prixTTC / prixrevienEtiquetteTTC;
      prixEtiquetteHT = prixTTC / 1.19;
      txtCoeficient.text = coefPrxi.toStringAsFixed(3);
      txtPrixHT.text = prixEtiquetteHT.toStringAsFixed(3);
    }
  }
}

Widget buildInfoRowPerso(String label, num value, Color backgroundColor) {
  return Row(
    children: [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          label,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      Container(
        width: 200,
        color: backgroundColor,
        child: Text(
          NumberFormat("#,##0.00").format(value),
          style: const TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Colors.black, // Couleur du texte
          ),
          textAlign: TextAlign.center,
        ),
      ),
    ],
  );
}
