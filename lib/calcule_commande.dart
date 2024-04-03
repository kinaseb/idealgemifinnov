import 'package:flutter/material.dart';
import 'package:ideal_calcule/class/donnees.dart';
//import 'package:intl/intl.dart';


double metrage = 0;
double qtmetrage = 0;
double etiqbobf = 0;

class ScreanCommandeMetrage extends StatefulWidget {
  const ScreanCommandeMetrage({super.key});

  @override
  State<ScreanCommandeMetrage> createState() => _ScreanCommandeMetrageState();
}

class _ScreanCommandeMetrageState extends State<ScreanCommandeMetrage> {
  final txtQtCommande = TextEditingController();
  final txtQtMetrage = TextEditingController();

  //var chiffre = NumberFormat("#,##0", "en_US");

  String choixRepeat = "74";
  String poseChoix = "1";
  int intPose = 0;
  double intRepeat = 0.0;
  String labelName = "commande";
  String bttext = "1K";
  int valueBut = 10000;
  int value = 100000;
  int intQtcommande = 0;
  double metrageCommande = 0;

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
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
        
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
                    // initialValue: "$value",
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
            Row(
              children: [
                const Padding(
                  // metrage label
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "Metrage    : ",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  //metrage
                  width: 200,
                  color: coulourcont,
                  child: Text(
                    // initialValue: "$value",
                    //controller: qtCommande,
                    "$metrage",
                    style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: coulourtxtint),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
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
            Row(
              children: [
                const Padding(
                  // metrage label
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "Quantite   : ",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  //metrage
                  width: 200,
                  color: coulourcont,
                  child: Text(
                    // initialValue: "$value",
                    //controller: qtCommande,
                    "$qtmetrage",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: coulourtxtint,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
        
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
                    "Etiq BobF : ",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  //metrage
                  width: 200,
                  color: coulourcont,
                  child: Text(
                    // initialValue: "$value",
                    //controller: qtCommande,
                    "$etiqbobf",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: coulourtxtint,
                    ),
                    textAlign: TextAlign.center,
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
                    "Etiq BobF : ",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  //metrage
                  width: 200,
                  color: coulourcont,
                  child: Text(
                    // initialValue: "$value",
                    //controller: qtCommande,
                    "$etiqbobf",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: coulourtxtint,
                    ),
                    textAlign: TextAlign.center,
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
                    "Etiq BobF : ",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  //metrage
                  width: 200,
                  color: coulourcont,
                  child: Text(
                    // initialValue: "$value",
                    //controller: qtCommande,
                    "$etiqbobf",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: coulourtxtint,
                    ),
                    textAlign: TextAlign.center,
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
                    "Etiq BobF : ",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  //metrage
                  width: 200,
                  color: coulourcont,
                  child: Text(
                    // initialValue: "$value",
                    //controller: qtCommande,
                    "$etiqbobf",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: coulourtxtint,
                    ),
                    textAlign: TextAlign.center,
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
                    "Etiq BobF : ",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  //metrage
                  width: 200,
                  color: coulourcont,
                  child: Text(
                    // initialValue: "$value",
                    //controller: qtCommande,
                    "$etiqbobf",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: coulourtxtint,
                    ),
                    textAlign: TextAlign.center,
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
                    "Etiq BobF : ",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  //metrage
                  width: 200,
                  color: coulourcont,
                  child: Text(
                    // initialValue: "$value",
                    //controller: qtCommande,
                    "$etiqbobf",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: coulourtxtint,
                    ),
                    textAlign: TextAlign.center,
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
                    "Etiq BobF : ",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  //metrage
                  width: 200,
                  color: coulourcont,
                  child: Text(
                    // initialValue: "$value",
                    //controller: qtCommande,
                    "$etiqbobf",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: coulourtxtint,
                    ),
                    textAlign: TextAlign.center,
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
                    "Etiq BobF : ",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  //metrage
                  width: 200,
                  color: coulourcont,
                  child: Text(
                    // initialValue: "$value",
                    //controller: qtCommande,
                    "$etiqbobf",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: coulourtxtint,
                    ),
                    textAlign: TextAlign.center,
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
                    "Etiq BobF : ",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  //metrage
                  width: 200,
                  color: coulourcont,
                  child: Text(
                    // initialValue: "$value",
                    //controller: qtCommande,
                    "$etiqbobf",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: coulourtxtint,
                    ),
                    textAlign: TextAlign.center,
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
                    "Etiq BobF : ",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  //metrage
                  width: 200,
                  color: coulourcont,
                  child: Text(
                    // initialValue: "$value",
                    //controller: qtCommande,
                    "$etiqbobf",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: coulourtxtint,
                    ),
                    textAlign: TextAlign.center,
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
                    "Etiq BobF : ",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  //metrage
                  width: 200,
                  color: coulourcont,
                  child: Text(
                    // initialValue: "$value",
                    //controller: qtCommande,
                    "$etiqbobf",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: coulourtxtint,
                    ),
                    textAlign: TextAlign.center,
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
  metrage = (commande / (1000 / (repeat * 3.175) * pose)).ceil().toDouble();

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
  etiqbobf = ((1000 / (repeat * 3.175) * pose) * 1000).ceil().toDouble();

  // Calcul du métrage
  qtmetrage = ((1000 / (repeat * 3.175) * pose) * qtmetre).ceil().toDouble();
}
