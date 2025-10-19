//import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:ideal_calcule/class/donnees.dart';
import 'package:intl/intl.dart';
//import 'package:toggle_switch/toggle_switch.dart';
//import 'package:intl/intl.dart';

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

NumberFormat formatnumeromillier = NumberFormat("#,###", "fr_FR");

final txtQtCommande = TextEditingController();
final txtQtMetrage = TextEditingController();
final txtLzBobM = TextEditingController();
final txtLzBobFille = TextEditingController();
final txtPrixSupport = TextEditingController();
final txtCoeficient = TextEditingController();
final txtPrixTTC = TextEditingController();
final txtPrixHT = TextEditingController();

class ScreanCommandeMetrage extends StatefulWidget {
  const ScreanCommandeMetrage({super.key});

  @override
  State<ScreanCommandeMetrage> createState() => _ScreanCommandeMetrageState();
}

class _ScreanCommandeMetrageState extends State<ScreanCommandeMetrage> {
  //var chiffre = NumberFormat("#,##0", "en_US");

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

                        metragecommande(
                            choixRepeat, poseChoix, txtQtCommande.text);
                        qntselonmetrage(
                            choixRepeat, poseChoix, txtQtMetrage.text);
                        calculecoupebobine(txtLzBobFille.text, txtLzBobM.text);
                        calculePrix(choixInclureChute, txtPrixSupport.text,
                            txtLzBobM.text);
                        calculePrixVente(txtCoeficient.text);
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

                          metragecommande(
                              choixRepeat, poseChoix, txtQtCommande.text);
                          qntselonmetrage(
                              choixRepeat, poseChoix, txtQtMetrage.text);
                          calculecoupebobine(
                              txtLzBobFille.text, txtLzBobM.text);

                          calculePrix(choixInclureChute, txtPrixSupport.text,
                              txtLzBobM.text);
                          calculePrixVente(txtCoeficient.text);
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
                        metragecommande(
                            choixRepeat, poseChoix, txtQtCommande.text);
                      });
                    },
                  ),
                ),
                OutlinedButton(
                  //btn  000
                  onPressed: () {
                    setState(() {
                      //double metrage= metrageCommande(choixRepeat, poseChoix, txtQtCommande);

                      if (txtQtCommande.text != "") {
                        //intQtcommande = int.parse(txtQtCommande.text);

                        txtQtCommande.text =
                            (int.parse(txtQtCommande.text) * 1000).toString();
                        // metrage= metrageCommande;

                        metragecommande(
                            choixRepeat, poseChoix, txtQtCommande.text);
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
                        qntselonmetrage(
                            choixRepeat, poseChoix, txtQtMetrage.text);
                      });
                    },
                  ),
                ),
                OutlinedButton(
                  //btn  000
                  onPressed: () {
                    setState(() {
                      //double metrage= metrageCommande(choixRepeat, poseChoix, txtQtCommande);

                      if (txtQtMetrage.text != "") {
                        //intQtcommande = int.parse(txtQtCommande.text);

                        txtQtMetrage.text =
                            (int.parse(txtQtMetrage.text) * 1000).toString();

                        qntselonmetrage(
                            choixRepeat, poseChoix, txtQtMetrage.text);
                        // metrage= metrageCommande;
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
                        calculecoupebobine(txtLzBobFille.text, txtLzBobM.text);
                        calculePrix(choixInclureChute, txtPrixSupport.text,
                            txtLzBobM.text);
                        calculePrixVente(txtCoeficient.text);
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
                        calculecoupebobine(txtLzBobFille.text, txtLzBobM.text);
                        calculePrix(choixInclureChute, txtPrixSupport.text,
                            txtLzBobM.text);
                        calculePrixVente(txtCoeficient.text);
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
                        calculePrix(choixInclureChute, txtPrixSupport.text,
                            txtLzBobM.text);
                        calculePrixVente(txtCoeficient.text);
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

                        calculePrix(choixInclureChute, txtPrixSupport.text,
                            txtLzBobM.text);
                        calculePrixVente(txtCoeficient.text);
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
                        calculePrixVente(txtCoeficient.text);
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
                        calculeCoefVente(txtPrixTTC.text);
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
}

void metragecommande(
    String choixRepeat, String poseChoix, String txtQtCommande) {
  // Vérification des entrées

  // Conversion des entrées en types numériques
  int repeat = int.parse(choixRepeat);
  int pose = int.parse(poseChoix);
  if (txtQtCommande == "") {
    txtQtCommande = "0";
  }
  int commande = int.parse(txtQtCommande);

  // Calcul du métrage
  metrage = (commande / (1000 / (repeat * 3.175) * pose)).floor().toDouble();

  // Retourner le métrage calculé
}

void qntselonmetrage(
    String choixRepeat, String poseChoix, String txtQtMetrage) {
  // Conversion des entrées en types numériques
  int repeat = int.parse(choixRepeat);
  int pose = int.parse(poseChoix);

  if (txtQtMetrage == "") {
    txtQtMetrage = "0";
  }
  int qtmetre = int.parse(txtQtMetrage);
  etiqbobf = ((1000 / (repeat * 3.175) * pose) * 1000).floor().toDouble();

  // Calcul du métrage
  qtmetrage = ((1000 / (repeat * 3.175) * pose) * qtmetre).floor().toDouble();
}

void calculecoupebobine(String lzBobFtxt, String lzBobMtxt) {
  if ((lzBobFtxt != "") && (lzBobMtxt != "")) {
    int lzBobF = int.parse(lzBobFtxt);
    int lzBobM = int.parse(lzBobMtxt);

    nbrbobf = lzBobM ~/ lzBobF;
    chutteBobMere = lzBobM % lzBobF;
    etiqbobMere = etiqbobf * nbrbobf;
  } else {
    lzbf = 0;
    nbrbobf = 0;
    chutteBobMere = 0;
    etiqbobMere = 0;
  }
}

void calculePrix(
    String choixChutetxt, String prixSupporttxt, String lzBobMertxt) {
  int lzBobMer = 0;
  if (prixSupporttxt == "" || lzBobMertxt == "") {
    prixrevienEtiquetteTTC = 0;
  } else {
    double prixSupport = (double.parse(prixSupporttxt)) * 1000;
    //int NbrEtiqBM = int.parse(NbrEtiqBMtxt);
    lzBobMer = int.parse(lzBobMertxt);
    //int Chute = int.parse(Chutetxt);

    double prixSupportsansChutte =
        ((lzBobMer - chutteBobMere) * prixSupport) / 1000;

    if (etiqbobMere != 0) {
      if (choixChutetxt == "oui") {
        prixrevienEtiquetteTTC = prixSupport / etiqbobMere;
      } else {
        prixrevienEtiquetteTTC = prixSupportsansChutte / etiqbobMere;
      }
    }
  }
}

void calculePrixVente(String coeficiEntTxt) {
  if (coeficiEntTxt != "") {
    prixEtiquetteTTC = double.parse(coeficiEntTxt) * prixrevienEtiquetteTTC;

    prixEtiquetteHT = prixEtiquetteTTC / 1.19;
    txtPrixTTC.text = prixEtiquetteTTC.toStringAsFixed(3);
    txtPrixHT.text = prixEtiquetteHT.toStringAsFixed(3);
  } else {
    prixEtiquetteTTC = 0;
    prixEtiquetteHT = 0;
    txtPrixTTC.text = "0";
    txtPrixHT.text = "0";
  }
}

void calculeCoefVente(String prixTTCtxt) {
  if (prixTTCtxt != "") {
    coefPrxi = double.parse(prixTTCtxt) / prixrevienEtiquetteTTC;
    prixEtiquetteHT = double.parse(prixTTCtxt) / 1.19;

    txtCoeficient.text = coefPrxi.toStringAsFixed(3);
    txtPrixHT.text = prixEtiquetteHT.toStringAsFixed(3);
  } else {
    coefPrxi = 0;

    txtCoeficient.text = "0";
    txtPrixHT.text = "0";
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
