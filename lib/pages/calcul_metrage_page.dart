import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ideal_calcule/class/etiquette.dart';

class CalculMetragePage extends StatelessWidget {
  final TextEditingController txtQtCommande;
  final TextEditingController txtQtMetrage;
  final String choixRepeat;
  final String poseChoix;
  final double metrage;
  final double qtmetrage;
  final double etiqbobFille;
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
    required this.etiqbobFille,
    required this.formatnumeromillier,
    required this.onRepeatChanged,
    required this.onPoseChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              const Text("Repeat",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              DropdownButton<String>(
                                value: choixRepeat,
                                underline: Container(
                                    height: 3,
                                    color: Theme.of(context).primaryColor),
                                items: Etiquette.availableRepeats
                                    .map((String repeat) {
                                  return DropdownMenuItem<String>(
                                      value: repeat,
                                      child: Text(
                                        repeat,
                                        style: const TextStyle(fontSize: 22),
                                      ));
                                }).toList(),
                                onChanged: onRepeatChanged,
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              const Text("Pose",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              DropdownButton<String>(
                                value: poseChoix,
                                underline: Container(
                                    height: 3,
                                    color: Theme.of(context).primaryColor),
                                items: Etiquette.availablePoses.map((String e) {
                                  return DropdownMenuItem<String>(
                                      value: e,
                                      child: Text(
                                        e,
                                        style: const TextStyle(fontSize: 22),
                                      ));
                                }).toList(),
                                onChanged: onPoseChanged,
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .secondary
                              .withAlpha(30),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Étiq / Bob.Fille : ${formatnumeromillier.format(etiqbobFille)}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: txtQtCommande,
                      style: const TextStyle(fontSize: 22),
                      decoration: const InputDecoration(
                        labelText: 'Quantité commandée',
                        prefixIcon: Icon(Icons.shopping_cart),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      final val = double.tryParse(txtQtCommande.text) ?? 0;
                      txtQtCommande.text = (val * 1000).toInt().toString();
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text(
                      "1K",
                      style: TextStyle(fontSize: 22),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildResultCard(
                context,
                title: 'Métrage nécessaire',
                value: '${formatnumeromillier.format(metrage)} m',
                icon: Icons.straighten,
                color: Colors.blue.shade100,
                textColor: Colors.blue.shade900,
              ),
              const Divider(height: 40, thickness: 1),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: txtQtMetrage,
                      style: const TextStyle(fontSize: 22),
                      decoration: const InputDecoration(
                        labelText: 'Métrage en stock',
                        prefixIcon: Icon(Icons.inventory),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      final val = double.tryParse(txtQtMetrage.text) ?? 0;
                      txtQtMetrage.text = (val * 1000).toInt().toString();
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("1K"),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildResultCard(
                context,
                title: 'Quantité d\'étiquettes',
                value: formatnumeromillier.format(qtmetrage),
                icon: Icons.confirmation_number,
                color: Colors.green.shade100,
                textColor: Colors.green.shade900,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultCard(BuildContext context,
      {required String title,
      required String value,
      required IconData icon,
      Color? color,
      Color? textColor}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor =
        isDark ? Theme.of(context).cardColor : (color ?? Colors.grey.shade100);
    final txtColor = isDark ? Colors.white : (textColor ?? Colors.black);

    return Card(
      elevation: 4,
      color: bgColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, size: 30, color: txtColor),
            const SizedBox(height: 8),
            Text(title,
                style: TextStyle(fontSize: 18, color: txtColor.withAlpha(204))),
            const SizedBox(height: 4),
            Text(value,
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: txtColor)),
          ],
        ),
      ),
    );
  }
}
