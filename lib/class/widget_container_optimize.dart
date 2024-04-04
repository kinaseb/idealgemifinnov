import 'package:flutter/material.dart';
import 'package:ideal_calcule/calcule_commande.dart';
import 'package:intl/intl.dart';

class OptimizedWidget extends StatelessWidget {
  final NumberFormat formatNumeriqueMillier = NumberFormat("#,###");

  Widget buildInfoRow(String label, int value, Color backgroundColor) {
    return Row(
      children: [
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            label,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        Container(
          width: 200,
          color: backgroundColor,
          child: Text(
            formatNumeriqueMillier.format(value),
            style: TextStyle(
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        buildInfoRow("Nbr  BF    : ", nbrbobf,
            Colors.grey), // Première ligne d'information
        buildInfoRow("Chute BM: ", chutteBobMere,
            Colors.blueGrey), // Deuxième ligne d'information
        // Troisième ligne d'information
        // Vous pouvez ajouter plus de lignes d'information ici si nécessaire
      ],
    );
  }
}
