import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ideal_calcule/class/mother_reel_data.dart';

class CalculCoupePage extends StatefulWidget {
  final List<MotherReelData> motherReels;

  const CalculCoupePage({super.key, required this.motherReels});

  @override
  State<CalculCoupePage> createState() => CalculCoupePageState();
}

class CalculCoupePageState extends State<CalculCoupePage> {
  final NumberFormat _numberFormat = NumberFormat("#,###.###", "fr_FR");

  // Global results
  final Map<double, double> _globalCuts = {}; // Width -> Total Quantity
  final Map<double, double> _globalWasteDetails = {}; // Width -> Total Quantity

  @override
  void initState() {
    super.initState();
    // If empty, add one reel (handled by parent now, but good for safety)
    if (widget.motherReels.isEmpty) {
      _addMotherReel();
    }

    // Add listeners to existing reels
    for (var reel in widget.motherReels) {
      _attachListeners(reel);
    }

    _calculate();
  }

  @override
  void dispose() {
    // We do NOT dispose controllers here as they belong to the parent state
    // Just remove listeners
    for (var reel in widget.motherReels) {
      _removeListeners(reel);
    }
    super.dispose();
  }

  void _attachListeners(MotherReelData reel) {
    reel.widthController.addListener(_calculate);
    reel.quantityController.addListener(_calculate);
    for (var cut in reel.cuts) {
      cut.widthController.addListener(_calculate);
      cut.qtyController.addListener(_calculate);
    }
  }

  void _removeListeners(MotherReelData reel) {
    reel.widthController.removeListener(_calculate);
    reel.quantityController.removeListener(_calculate);
    for (var cut in reel.cuts) {
      cut.widthController.removeListener(_calculate);
      cut.qtyController.removeListener(_calculate);
    }
  }

  void addExternalReel(MotherReelData reel) {
    setState(() {
      _attachListeners(reel);
      widget.motherReels.add(reel);
      _calculate();
    });
  }

  void clearReels() {
    setState(() {
      for (var reel in widget.motherReels) {
        _removeListeners(reel);
        reel.dispose();
      }
      widget.motherReels.clear();
      _calculate();
    });
  }

  void _addMotherReel() {
    setState(() {
      final newReel = MotherReelData();
      _attachListeners(newReel);
      // Add one initial cut row
      _addCutRow(newReel);
      widget.motherReels.add(newReel);
    });
  }

  void _removeMotherReel(int index) {
    setState(() {
      final reel = widget.motherReels[index];
      _removeListeners(reel);
      reel.dispose();
      widget.motherReels.removeAt(index);
      _calculate();
    });
  }

  void _addCutRow(MotherReelData reel) {
    setState(() {
      final newCut = CutRow();
      newCut.widthController.addListener(_calculate);
      newCut.qtyController.addListener(_calculate);
      reel.cuts.add(newCut);
    });
  }

  void _removeCutRow(MotherReelData reel, int index) {
    setState(() {
      final cut = reel.cuts[index];
      cut.widthController.removeListener(_calculate);
      cut.qtyController.removeListener(_calculate);
      cut.dispose();
      reel.cuts.removeAt(index);
      _calculate();
    });
  }

  void _calculate() {
    _globalCuts.clear();
    _globalWasteDetails.clear();

    for (var reel in widget.motherReels) {
      double motherWidth = double.tryParse(reel.widthController.text) ?? 0;
      double motherQty = double.tryParse(reel.quantityController.text) ?? 1;
      double usedPerReel = 0;

      for (var cut in reel.cuts) {
        double w = double.tryParse(cut.widthController.text) ?? 0;
        double q = double.tryParse(cut.qtyController.text) ?? 0;

        if (w > 0 && q > 0) {
          usedPerReel += (w * q);

          // Add to global results
          double totalQ = q * motherQty;
          _globalCuts.update(w, (value) => value + totalQ,
              ifAbsent: () => totalQ);
        }
      }

      reel.totalUsed = usedPerReel;
      reel.waste = motherWidth - usedPerReel;
      reel.isOverLimit = reel.waste < 0;

      if (motherWidth > 0) {
        if (!reel.isOverLimit && reel.waste > 0) {
          _globalWasteDetails.update(reel.waste, (value) => value + motherQty,
              ifAbsent: () => motherQty);
        }
      }
    }

    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header with Add Button
              Wrap(
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const Text(
                    "Configuration des Bobines",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton.icon(
                    onPressed: _addMotherReel,
                    icon: const Icon(Icons.add_circle),
                    label: const Text("Ajouter Bobine Mère"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // List of Mother Reels
              ...widget.motherReels.asMap().entries.map((entry) {
                int index = entry.key;
                MotherReelData reel = entry.value;
                return _buildMotherReelCard(index, reel);
              }),

              const SizedBox(height: 24),
              const Divider(thickness: 2),
              const SizedBox(height: 16),

              // Global Results
              _buildGlobalResults(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMotherReelCard(int index, MotherReelData reel) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: reel.isOverLimit
            ? const BorderSide(color: Colors.red, width: 2)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Reel Header
            Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  child: Text("${index + 1}"),
                ),
                const SizedBox(width: 10),
                const Text(
                  "Bobine Mère",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => _removeMotherReel(index),
                  tooltip: "Supprimer cette bobine",
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Mother Reel Inputs
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: reel.widthController,
                  decoration: const InputDecoration(
                    labelText: 'Laize Bobine Mère (mm)',
                    prefixIcon: Icon(Icons.line_weight),
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: reel.quantityController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre de Bobines',
                    prefixIcon: Icon(Icons.numbers),
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Cuts Section
            Container(
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      const Text("Coupes (Bobines Filles)",
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      TextButton.icon(
                        onPressed: () => _addCutRow(reel),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text("Ajouter Coupe"),
                      ),
                    ],
                  ),
                  ...reel.cuts.asMap().entries.map((cutEntry) {
                    int cutIndex = cutEntry.key;
                    CutRow cut = cutEntry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              controller: cut.widthController,
                              decoration: const InputDecoration(
                                labelText: 'Laize (mm)',
                                border: OutlineInputBorder(),
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 12),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 1,
                            child: TextFormField(
                              controller: cut.qtyController,
                              decoration: const InputDecoration(
                                labelText: 'Qté',
                                border: OutlineInputBorder(),
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 12),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close,
                                color: Colors.red, size: 20),
                            onPressed: () => _removeCutRow(reel, cutIndex),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Reel Stats
            Wrap(
              alignment: WrapAlignment.spaceAround,
              spacing: 16,
              runSpacing: 8,
              children: [
                Text(
                  "Utilisé: ${_numberFormat.format(reel.totalUsed)} mm",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.blue),
                ),
                Text(
                  "Chute: ${_numberFormat.format(reel.waste)} mm",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: reel.isOverLimit ? Colors.red : Colors.green),
                ),
              ],
            ),
            if (reel.isOverLimit)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  "Attention: Laize utilisée dépasse la bobine mère!",
                  style: TextStyle(
                      color: Colors.red.shade900, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlobalResults() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Sort cuts by width
    var sortedCuts = _globalCuts.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    // Sort waste by width
    var sortedWaste = _globalWasteDetails.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return Card(
      elevation: 4,
      color: isDark ? Colors.indigo.shade900 : Colors.indigo.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                "Résultats Globaux",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Bobines Filles Section
                Column(
                  children: [
                    const Text(
                      "Bobines Filles",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue),
                    ),
                    const SizedBox(height: 10),
                    if (sortedCuts.isEmpty)
                      const Text("-",
                          style: TextStyle(fontStyle: FontStyle.italic))
                    else
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        children: sortedCuts.map((entry) {
                          return _buildCompactChip(
                              context,
                              "${_numberFormat.format(entry.key)} mm",
                              entry.value.toInt().toString(),
                              Colors.blue);
                        }).toList(),
                      ),
                  ],
                ),

                const SizedBox(height: 20),
                Divider(height: 1, color: Colors.grey.withAlpha(100)),
                const SizedBox(height: 20),

                // Chutes Section
                Column(
                  children: [
                    const Text(
                      "Chutes",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.green),
                    ),
                    const SizedBox(height: 10),
                    if (sortedWaste.isEmpty)
                      const Text("-",
                          style: TextStyle(fontStyle: FontStyle.italic))
                    else
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        children: sortedWaste.map((entry) {
                          return _buildCompactChip(
                              context,
                              "${_numberFormat.format(entry.key)} mm",
                              entry.value.toInt().toString(),
                              Colors.green);
                        }).toList(),
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactChip(
      BuildContext context, String label, String count, MaterialColor color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
          color: isDark ? color.shade900.withAlpha(100) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 2,
              offset: const Offset(0, 1),
            )
          ]),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 13),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              count,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
