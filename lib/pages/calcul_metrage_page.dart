import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ideal_calcule/class/donnees.dart';

class CalculMetragePage extends StatelessWidget {
  final TextEditingController txtQtCommande;
  final TextEditingController txtQtMetrage;
  final String choixRepeat;
  final String poseChoix;
  final double metrage;
  final double qtmetrage;
  final NumberFormat formatnumeromillier;
  final ValueChanged<String?> onRepeatChanged;
  final ValueChanged<String?> onPoseChanged;

  const CalculMetragePage({
    super.key,
    required this.txtQtCommande,
    required this.txtQtMetrage,
    required this.choixRepeat,
    required this.poseChoix,
    required this.metrage,
    required this.qtmetrage,
    required this.formatnumeromillier,
    required this.onRepeatChanged,
    required this.onPoseChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  const Text("Repeat :", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  DropdownButton<String>(
                    value: choixRepeat,
                    items: listRepeat.map((String repeat) {
                      return DropdownMenuItem<String>(value: repeat, child: Text(repeat));
                    }).toList(),
                    onChanged: onRepeatChanged,
                  ),
                ],
              ),
              Column(
                children: [
                  const Text("Pose :", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  DropdownButton<String>(
                    value: poseChoix,
                    items: nbrPose.map((String e) {
                      return DropdownMenuItem<String>(value: e, child: Text(e));
                    }).toList(),
                    onChanged: onPoseChanged,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: txtQtCommande,
            decoration: const InputDecoration(labelText: 'Quantité commandée', border: OutlineInputBorder()),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 10),
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Métrage nécessaire: ${formatnumeromillier.format(metrage)} m', textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),
          const Divider(height: 40, thickness: 2),
          TextFormField(
            controller: txtQtMetrage,
            decoration: const InputDecoration(labelText: 'Métrage en stock', border: OutlineInputBorder()),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 10),
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Quantité d\'étiquettes: ${formatnumeromillier.format(qtmetrage)}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
