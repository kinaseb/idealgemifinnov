import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ideal_calcule/class/donnees.dart';

class CalculPrixPage extends StatelessWidget {
  final TextEditingController txtLzBobM;
  final TextEditingController txtLzBobFille;
  final TextEditingController txtPrixSupport;
  final TextEditingController txtCoeficient;
  final TextEditingController txtPrixTTC;
  final TextEditingController txtPrixHT;
  final String choixInclureChute;
  final int nbrbobf;
  final int chutteBobMere;
  final double etiqbobMere;
  final double prixrevienEtiquetteTTC;
  final NumberFormat formatnumeromillier;
  final ValueChanged<String?> onInclureChuteChanged;
  final VoidCallback onCoefChanged;
  final VoidCallback onPrixTTCChanged;

  const CalculPrixPage({
    super.key,
    required this.txtLzBobM,
    required this.txtLzBobFille,
    required this.txtPrixSupport,
    required this.txtCoeficient,
    required this.txtPrixTTC,
    required this.txtPrixHT,
    required this.choixInclureChute,
    required this.nbrbobf,
    required this.chutteBobMere,
    required this.etiqbobMere,
    required this.prixrevienEtiquetteTTC,
    required this.formatnumeromillier,
    required this.onInclureChuteChanged,
    required this.onCoefChanged,
    required this.onPrixTTCChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: txtLzBobFille,
            decoration: const InputDecoration(labelText: 'Laize Bobine Fille (mm)', border: OutlineInputBorder()),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: txtLzBobM,
            decoration: const InputDecoration(labelText: 'Laize Bobine Mère (mm)', border: OutlineInputBorder()),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 10),
          Card(elevation: 2, child: Padding(padding: const EdgeInsets.all(8.0), child: Text('Nombre de bobines filles: $nbrbobf', textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)))),
          Card(elevation: 2, color: Colors.orange[100], child: Padding(padding: const EdgeInsets.all(8.0), child: Text('Chute: $chutteBobMere mm', textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red)))),
          Card(elevation: 2, child: Padding(padding: const EdgeInsets.all(8.0), child: Text('Étiquettes par bobine mère: ${formatnumeromillier.format(etiqbobMere)}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)))),
          const Divider(height: 40, thickness: 2),
          TextFormField(
            controller: txtPrixSupport,
            decoration: const InputDecoration(labelText: 'Prix Support (€/m²)', border: OutlineInputBorder()),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            initialValue: choixInclureChute,
            decoration: const InputDecoration(labelText: 'Inclure la chute', border: OutlineInputBorder()),
            items: inclureChuteOuPas.map((String inclure) {
              return DropdownMenuItem<String>(value: inclure, child: Text(inclure));
            }).toList(),
            onChanged: onInclureChuteChanged,
          ),
          const SizedBox(height: 10),
          Card(elevation: 2, color: Colors.green[100], child: Padding(padding: const EdgeInsets.all(8.0), child: Text('Prix de revient / étiquette: ${formatnumeromillier.format(prixrevienEtiquetteTTC)} €', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green[800])))),
          const Divider(height: 40, thickness: 2),
          TextFormField(
            controller: txtCoeficient,
            decoration: const InputDecoration(labelText: 'Coefficient', border: OutlineInputBorder()),
            keyboardType: TextInputType.number,
            onChanged: (_) => onCoefChanged(),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: txtPrixTTC,
            decoration: const InputDecoration(labelText: 'Prix de vente TTC', border: OutlineInputBorder()),
            keyboardType: TextInputType.number,
            onChanged: (_) => onPrixTTCChanged(),
          ),
          const SizedBox(height: 10),
          Card(elevation: 2, child: Padding(padding: const EdgeInsets.all(8.0), child: Text('Prix de vente HT: ${txtPrixHT.text} €', textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)))),
        ],
      ),
    );
  }
}