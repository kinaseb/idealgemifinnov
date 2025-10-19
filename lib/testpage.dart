import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

double metrage2 = 0;
NumberFormat metrageFormater = NumberFormat("#,###", "fr_FR");

class ScreanCommandeMetrage extends StatefulWidget {
  const ScreanCommandeMetrage({super.key});

  @override
  State<ScreanCommandeMetrage> createState() => _ScreanCommandeMetrageState();
}

class _ScreanCommandeMetrageState extends State<ScreanCommandeMetrage> {
  final txtQtCommande = TextEditingController();

  //var chiffre = NumberFormat("#,##0", "en_US");

  List<String> listRepeat = [
    "74",
    "76",
    "85",
    "94",
    "112",
    "115",
    "135",
    "190"
  ];
  List<String> nbrPose = [
    "1",
    "2",
    "3",
    "4",
    "5",
    "6",
    "7",
    "8",
    "9",
    "10",
    "11",
    "12",
    "13",
    "14",
    "15",
    "16",
    "17",
    "18",
    "19",
    "20",
    "21",
    "22",
    "23",
    "24",
    "25",
    "26",
    "27",
    "28",
    "29",
    "30",
    "31",
    "32",
    "33",
    "34",
    "35",
    "36",
    "37",
    "38",
    "39",
    "40",
    "41",
    "42",
    "43",
    "44",
    "45",
    "46",
    "47",
    "48",
    "49",
    "50",
    "51",
    "52",
    "53",
    "54",
    "55",
    "56",
    "57",
    "58",
    "59",
    "60",
    "61",
    "62",
    "63",
    "64",
    "65",
    "66",
    "67",
    "68",
    "69",
    "70",
    "71",
    "72",
    "73",
    "74",
    "75",
    "76",
    "77",
    "78",
    "79",
    "80",
    "81",
    "82",
    "83",
    "84",
    "85",
    "86",
    "87",
    "88",
    "89",
    "90",
    "91",
    "92",
    "93",
    "94",
    "95",
    "96",
    "97",
    "98",
    "99",
    "100",
  ];
  String choixRepeat = "74";
  String poseChoix = "1";
  int intPose = 0;
  double intRepeat = 0.0;
  String labelName = "commande";
  String bttext = "00";
  int valueBut = 10000;
  int value = 100000;
  int intQtcommande = 0;
  double metrageCommande = 0;
  double metrage = 0;
  String metrageStr = "0";
  int repeat = 0;
  int pose = 0;
  int commande = 0;

  @override
  Widget build(BuildContext context) {
    //txtQtCommande.text = "100 000";
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Calculatrice Metrage & Commande",
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        shadowColor: Colors.green,
        elevation: 10,
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          // const SizedBox(
          //   height: 00,
          // ),
          Row(
            children: [
              const Padding(
                padding: EdgeInsets.all(10.0),
                child: Text(
                  "Repeat :",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
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
                      metrageStr = metrageCommandef(
                          choixRepeat, poseChoix, txtQtCommande);
                    });
                  },
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(left: 8.0, right: 8),
                child: Text(
                  "Pose :",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
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
                        metrageStr = metrageCommandef(
                            choixRepeat, poseChoix, txtQtCommande);
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
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  labelName,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(
                width: 150,
                child: TextFormField(
                  // initialValue: "$value",
                  controller: txtQtCommande,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 25, fontWeight: FontWeight.bold),
                  keyboardType: TextInputType.number,
                  onChanged: ((value) {
                    setState(() {
                      if (txtQtCommande.text.isNotEmpty) {
                        metrageStr = metrageCommandef(
                            choixRepeat, poseChoix, txtQtCommande);
                      }
                    });
                  }),
                ),
              ),
              OutlinedButton(
                onPressed: () {
                  setState(
                    () {
                      if (txtQtCommande.text != "") {
                        txtQtCommande.text =
                            (int.parse(txtQtCommande.text) * 100).toString();

                        metrageStr = metrageCommandef(
                            choixRepeat, poseChoix, txtQtCommande);
                        // }
                      }
                    },
                  );
                },
                style: const ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll(Colors.grey),
                ),
                child: Text(
                  bttext,
                  style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.yellow),
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
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "Metrage   : ",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                width: 155,
                color: Colors.grey,
                child: Text(
                  metrageStr,
                  style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.yellow),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

String metrageCommandef(
    String choixRepeat, String poseChoix, TextEditingController txtQtCommande) {
  int repeat = int.parse(choixRepeat.isNotEmpty ? choixRepeat : "0");
  int pose = int.parse(poseChoix.isNotEmpty ? poseChoix : "0");
  String commandStr = txtQtCommande.text.replaceAll(' ', '');
  int commande = int.parse(txtQtCommande.text.isNotEmpty ? commandStr : "0");
  String metrageStr = "0";
  double metrage3 = 0;

  if (choixRepeat.isNotEmpty ||
      poseChoix.isNotEmpty ||
      txtQtCommande.text.isNotEmpty) {
    metrage3 =
        ((commande / ((1000 / (repeat * 3.175) * pose))).ceil()).toDouble();
  }
  metrageStr = metrageFormater.format(metrage3);
  return metrageStr;
}

Widget labelFieldBt(
    {String labelName = "commande",
    String bttext = "0000",
    int valueBut = 10000}) {
  int value = 10;
  return Row(
    children: [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          labelName,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      SizedBox(
        width: 150,
        child: TextFormField(
          initialValue: "$value",
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          keyboardType: TextInputType.number,
        ),
      ),
      OutlinedButton(
        onPressed: () {},
        style: const ButtonStyle(
            backgroundColor: MaterialStatePropertyAll(Colors.green)),
        child: Text(
          bttext,
          style: const TextStyle(
              fontSize: 25, fontWeight: FontWeight.bold, color: Colors.yellow),
        ),
      ),
    ],
  );
}
