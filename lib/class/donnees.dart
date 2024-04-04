import 'package:flutter/material.dart';

List<String> listRepeat = ["74", "76", "85", "94", "112", "115", "135", "190"];
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
List<String> inclureChuteOuPas = ["oui", "non"];
Widget labelFieldBt(
    {String labelName = "commande",
    String bttext = "1K",
    int valueBut = 1000}) {
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
//


// Déclaration de la fonction metrageCommande
// double metrageCommande(String choixRepeat, String poseChoix, String txtQtCommande) {
//   // Vérification des entrées
//   if (choixRepeat.isNotEmpty && poseChoix.isNotEmpty && txtQtCommande.isNotEmpty) {
//     // Conversion des entrées en types numériques
//     int repeat = int.parse(choixRepeat);
//     int pose = int.parse(poseChoix);
//     int commande = int.parse(txtQtCommande);
    
//     // Calcul du métrage
//     double resultat = (commande / (1000 / (repeat * 3.175) * pose)).ceil().toDouble();
    
//     // Retourner le métrage calculé
//     return resultat;
//   } else {
//     // Si des entrées sont vides, retourner 0
//     return 0;
//   }
// }

//   double metrageCommande(
//     String choixRepeat, String poseChoix, TextEditingController txtQtCommande) {
//   int repeat = int.parse(choixRepeat);
//   int pose = int.parse(poseChoix);
//   int commande = int.parse(txtQtCommande.text);
//   double metrage = 0;

//   if (choixRepeat.isNotEmpty ||
//       poseChoix.isNotEmpty ||
//       txtQtCommande.text != "") {
//     metrage =
//         ((commande / ((1000 / (repeat * 3.175) * pose))).ceil()).toDouble();
//   }
//   return metrage;
// }