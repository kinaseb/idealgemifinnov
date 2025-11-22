import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ideal_calcule/class/etiquette.dart';

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
  final double etiqbobFille;
  final double prixrevienEtiquetteTTC;
  final NumberFormat formatnumeromillier;
  final ValueChanged<String?> onInclureChuteChanged;
  final VoidCallback onCoefChanged;
  final VoidCallback onPrixTTCChanged;
  final VoidCallback? onTransferToCoupe;

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
    required this.etiqbobFille,
    required this.prixrevienEtiquetteTTC,
    required this.formatnumeromillier,
    required this.onInclureChuteChanged,
    required this.onCoefChanged,
    required this.onPrixTTCChanged,
    this.onTransferToCoupe,
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
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: txtLzBobFille,
                      decoration: const InputDecoration(
                        labelText: 'Laize Fille (mm)',
                        prefixIcon: Icon(Icons.arrow_right_alt),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: txtLzBobM,
                      decoration: const InputDecoration(
                        labelText: 'Laize Mère (mm)',
                        prefixIcon: Icon(Icons.line_weight),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                      child: _buildInfoCard(context, 'Bobines Filles',
                          '$nbrbobf', Icons.copy, Colors.blue.shade50)),
                  const SizedBox(width: 10),
                  Expanded(
                      child: _buildInfoCard(context, 'Chute',
                          '$chutteBobMere mm', Icons.cut, Colors.orange.shade50,
                          textColor: Colors.red)),
                ],
              ),
              const SizedBox(height: 10),
              _buildInfoCard(
                  context,
                  'Étiquettes / Bobine Mère',
                  formatnumeromillier.format(etiqbobMere),
                  Icons.layers,
                  Colors.purple.shade50),
              const SizedBox(height: 10),
              _buildInfoCard(
                  context,
                  'Étiquettes / Bobine Fille',
                  formatnumeromillier.format(etiqbobFille),
                  Icons.layers_outlined,
                  Colors.purple.shade50),
              const Divider(height: 30, thickness: 1),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: txtLzBobFille,
                      decoration: const InputDecoration(
                        labelText: 'Laize Bobine Fille (mm)',
                        prefixIcon: Icon(Icons.straighten),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  if (onTransferToCoupe != null) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: onTransferToCoupe,
                      icon: const Icon(Icons.content_cut),
                      tooltip: "Transférer vers Coupe",
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: choixInclureChute,
                decoration: const InputDecoration(
                  labelText: 'Inclure la chute',
                  prefixIcon: Icon(Icons.delete_outline),
                  border: OutlineInputBorder(),
                ),
                items: Etiquette.includeWasteOptions.map((String inclure) {
                  return DropdownMenuItem<String>(
                      value: inclure, child: Text(inclure));
                }).toList(),
                onChanged: onInclureChuteChanged,
              ),
              const SizedBox(height: 16),
              _buildInfoCard(
                context,
                'Prix de revient / étiquette',
                '${formatnumeromillier.format(prixrevienEtiquetteTTC)} DA',
                Icons.monetization_on_outlined,
                Colors.green.shade50,
                textColor: Colors.green.shade800,
              ),
              const Divider(height: 30, thickness: 1),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: txtCoeficient,
                      decoration: const InputDecoration(
                        labelText: 'Coefficient',
                        prefixIcon: Icon(Icons.trending_up),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (_) => onCoefChanged(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: txtPrixTTC,
                      decoration: const InputDecoration(
                        labelText: 'Prix Vente TTC',
                        prefixIcon: Icon(Icons.price_check),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (_) => onPrixTTCChanged(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildInfoCard(
                context,
                'Prix de vente HT',
                '${txtPrixHT.text} DA',
                Icons.money_off,
                Colors.grey.shade200,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, String title, String value,
      IconData icon, Color color,
      {Color? textColor}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? Theme.of(context).cardColor : color;
    final txtColor = isDark ? Colors.white : (textColor ?? Colors.black87);

    return Card(
      elevation: 2,
      color: bgColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
        child: Column(
          children: [
            Icon(icon, color: txtColor, size: 24),
            const SizedBox(height: 4),
            Text(title,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: txtColor.withAlpha(179))),
            const SizedBox(height: 4),
            Text(value,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: txtColor)),
          ],
        ),
      ),
    );
  }
}
