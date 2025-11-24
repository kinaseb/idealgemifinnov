import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

// To track the last field edited by the user
enum _LastEdited { d, perimetre, largSleeve, largEtuit }

// Keys for SharedPreferences
const String _kLcKey = 'lc_param';
const String _kSccKey = 'scc_param';
const String _kScdKey = 'scd_param';
const String _kScgKey = 'scg_param';
const String _kRetractKey = 'retract_param';
const String _kGbKey = 'gb_param';
const String _kSpoteKey = 'spote_param';

const _defaultTechParams = {
  _kLcKey: "5",
  _kSccKey: "1",
  _kScdKey: "3",
  _kScgKey: "3",
  _kRetractKey: "10",
  _kGbKey: "2",
  _kSpoteKey: "3",
};

class CalculManchonPage extends StatefulWidget {
  const CalculManchonPage({super.key});

  @override
  State<CalculManchonPage> createState() => _CalculManchonPageState();
}

class _CalculManchonPageState extends State<CalculManchonPage> {
  // --- Controllers ---
  final _dController = TextEditingController();
  final _perimetreController = TextEditingController();
  final _largSleeveController = TextEditingController();
  final _largEtuitController = TextEditingController();
  final _lcController = TextEditingController();
  final _sccController = TextEditingController();
  final _retractController = TextEditingController();
  final _scdController = TextEditingController();
  final _scgController = TextEditingController();
  final _gbController = TextEditingController();
  final _spoteController = TextEditingController();

  // --- Focus Nodes ---
  final _dFocusNode = FocusNode();
  final _perimetreFocusNode = FocusNode();
  final _largSleeveFocusNode = FocusNode();
  final _largEtuitFocusNode = FocusNode();

  // --- State ---
  _LastEdited _lastEdited = _LastEdited.d;
  double _laizeImpSleeve = 0.0;
  bool _isSpoteExterne = true;
  bool _isCalculating = false;
  final NumberFormat _numberFormat = NumberFormat("#,###", "fr_FR");

  @override
  void initState() {
    super.initState();
    _loadTechnicalParams();

    // Add listeners to controllers
    final allControllers = {
      _dController: _onInputChanged,
      _perimetreController: _onInputChanged,
      _largSleeveController: _onInputChanged,
      _largEtuitController: _onInputChanged,
      _lcController: _onInputChanged,
      _sccController: _onInputChanged,
      _retractController: _onInputChanged,
      _scdController: _onInputChanged,
      _scgController: _onInputChanged,
      _gbController: _onInputChanged,
      _spoteController: _onInputChanged,
    };
    allControllers
        .forEach((controller, listener) => controller.addListener(listener));

    // Add listeners to focus nodes
    final allFocusNodes = {
      _dFocusNode: _LastEdited.d,
      _perimetreFocusNode: _LastEdited.perimetre,
      _largSleeveFocusNode: _LastEdited.largSleeve,
      _largEtuitFocusNode: _LastEdited.largEtuit,
    };
    allFocusNodes.forEach((node, field) => node.addListener(() {
          if (node.hasFocus) setState(() => _lastEdited = field);
        }));
  }

  @override
  void dispose() {
    // Dispose all controllers and focus nodes
    for (var disposable in [
      _dController,
      _perimetreController,
      _largSleeveController,
      _largEtuitController,
      _lcController,
      _sccController,
      _retractController,
      _scdController,
      _scgController,
      _gbController,
      _spoteController,
      _dFocusNode,
      _perimetreFocusNode,
      _largSleeveFocusNode,
      _largEtuitFocusNode
    ]) {
      disposable.dispose();
    }
    super.dispose();
  }

  // --- Data Persistence ---
  Future<void> _loadTechnicalParams() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _lcController.text =
          prefs.getString(_kLcKey) ?? _defaultTechParams[_kLcKey]!;
      _sccController.text =
          prefs.getString(_kSccKey) ?? _defaultTechParams[_kSccKey]!;
      _scdController.text =
          prefs.getString(_kScdKey) ?? _defaultTechParams[_kScdKey]!;
      _scgController.text =
          prefs.getString(_kScgKey) ?? _defaultTechParams[_kScgKey]!;
      _retractController.text =
          prefs.getString(_kRetractKey) ?? _defaultTechParams[_kRetractKey]!;
      _gbController.text =
          prefs.getString(_kGbKey) ?? _defaultTechParams[_kGbKey]!;
      _spoteController.text =
          prefs.getString(_kSpoteKey) ?? _defaultTechParams[_kSpoteKey]!;
    });
    _calculate();
  }

  Future<void> _saveTechnicalParams() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLcKey, _lcController.text);
    await prefs.setString(_kSccKey, _sccController.text);
    await prefs.setString(_kScdKey, _scdController.text);
    await prefs.setString(_kScgKey, _scgController.text);
    await prefs.setString(_kRetractKey, _retractController.text);
    await prefs.setString(_kGbKey, _gbController.text);
    await prefs.setString(_kSpoteKey, _spoteController.text);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Paramètres sauvegardés !'),
        backgroundColor: Colors.green,
      ));
    }
  }

  Future<void> _resetTechnicalParams() async {
    setState(() {
      _defaultTechParams.forEach((key, value) {
        switch (key) {
          case _kLcKey:
            _lcController.text = value;
            break;
          case _kSccKey:
            _sccController.text = value;
            break;
          case _kScdKey:
            _scdController.text = value;
            break;
          case _kScgKey:
            _scgController.text = value;
            break;
          case _kRetractKey:
            _retractController.text = value;
            break;
          case _kGbKey:
            _gbController.text = value;
            break;
          case _kSpoteKey:
            _spoteController.text = value;
            break;
        }
      });
    });
    await _saveTechnicalParams();
    _calculate();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Paramètres réinitialisés.'),
        backgroundColor: Colors.blue,
      ));
    }
  }

  // --- Calculation Logic ---
  void _onInputChanged() {
    if (!_isCalculating) _calculate();
  }

  void _updateTextField(TextEditingController controller, double value) {
    final roundedValue = value.round();
    final formattedValue = (roundedValue > 0 && value.isFinite)
        ? _numberFormat.format(roundedValue)
        : '';
    if (controller.text != formattedValue) {
      controller.text = formattedValue;
    }
  }

  void _calculate() {
    if (_isCalculating) return;
    _isCalculating = true;

    final lc = double.tryParse(_lcController.text.replaceAll(',', '.')) ?? 0.0;
    final scc =
        double.tryParse(_sccController.text.replaceAll(',', '.')) ?? 0.0;
    final scd =
        double.tryParse(_scdController.text.replaceAll(',', '.')) ?? 0.0;
    final scg =
        double.tryParse(_scgController.text.replaceAll(',', '.')) ?? 0.0;
    final retract =
        double.tryParse(_retractController.text.replaceAll(',', '.')) ?? 0.0;
    final gb = double.tryParse(_gbController.text.replaceAll(',', '.')) ?? 0.0;
    final spote =
        double.tryParse(_spoteController.text.replaceAll(',', '.')) ?? 0.0;

    double d = 0, perimetre = 0, largSleeve = 0, largEtuit = 0;
    final part2 = lc + scc;

    switch (_lastEdited) {
      case _LastEdited.d:
        d = double.tryParse(_dController.text.replaceAll(',', '.')) ?? 0.0;
        if (d > 0) {
          perimetre = d * pi;
          largSleeve = perimetre + part2 + retract;
          largEtuit = (largSleeve - part2) / 2;
          _updateTextField(_perimetreController, perimetre);
          _updateTextField(_largSleeveController, largSleeve);
          _updateTextField(_largEtuitController, largEtuit);
        }
        break;
      case _LastEdited.perimetre:
        perimetre =
            double.tryParse(_perimetreController.text.replaceAll(',', '.')) ??
                0.0;
        if (perimetre > 0) {
          d = perimetre / pi;
          largSleeve = perimetre + part2 + retract;
          largEtuit = (largSleeve - part2) / 2;
          _updateTextField(_dController, d);
          _updateTextField(_largSleeveController, largSleeve);
          _updateTextField(_largEtuitController, largEtuit);
        }
        break;
      case _LastEdited.largSleeve:
        largSleeve =
            double.tryParse(_largSleeveController.text.replaceAll(',', '.')) ??
                0.0;
        if (largSleeve > part2 + retract) {
          perimetre = largSleeve - part2 - retract;
          d = perimetre / pi;
          largEtuit = (largSleeve - part2) / 2;
          _updateTextField(_dController, d);
          _updateTextField(_perimetreController, perimetre);
          _updateTextField(_largEtuitController, largEtuit);
        }
        break;
      case _LastEdited.largEtuit:
        largEtuit =
            double.tryParse(_largEtuitController.text.replaceAll(',', '.')) ??
                0.0;
        if (largEtuit > 0) {
          largSleeve = (largEtuit * 2) + part2;
          if (largSleeve > part2 + retract) {
            perimetre = largSleeve - part2 - retract;
            d = perimetre / pi;
            _updateTextField(_dController, d);
            _updateTextField(_perimetreController, perimetre);
            _updateTextField(_largSleeveController, largSleeve);
          }
        }
        break;
    }

    final spoteValue = _isSpoteExterne ? spote : 0.0;
    final newLaizeImpSleeve =
        largSleeve > 0 ? (largSleeve + scd + scg + (gb * 2) + spoteValue) : 0.0;

    setState(() => _laizeImpSleeve = newLaizeImpSleeve);
    WidgetsBinding.instance.addPostFrameCallback((_) => _isCalculating = false);
  }

  // --- UI Build Methods ---
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
              _buildTechniqueParamsCard(),
              const SizedBox(height: 16),
              _buildMainCalculatorCard(),
              const SizedBox(height: 24),
              _buildResultCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTechniqueParamsCard() {
    final fields = [
      _buildTextField('Collage', _lcController, icon: Icons.layers_outlined),
      _buildTextField('Contre collage', _sccController,
          icon: Icons.security_outlined),
      _buildTextField('Securite droite', _scdController,
          icon: Icons.arrow_forward_outlined),
      _buildTextField('Securite gauche', _scgController,
          icon: Icons.arrow_back_outlined),
      _buildTextField('Rétraction', _retractController,
          icon: Icons.compress_outlined),
      _buildTextField('Guide bande', _gbController,
          icon: Icons.compare_arrows_outlined),
      _buildTextField('Spote', _spoteController, icon: Icons.adjust_outlined),
    ];

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: const Text("Paramètres Techniques (en mm)"),
        initiallyExpanded: false,
        children: [
          Padding(
            padding: const EdgeInsets.all(16).copyWith(top: 0),
            child: Column(
              children: [
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 3.5, // Adjusted for compactness
                  children: fields,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    FilledButton.icon(
                      onPressed: _saveTechnicalParams,
                      icon: const Icon(Icons.save_alt),
                      label: const Text('Sauvegarder'),
                    ),
                    TextButton.icon(
                      onPressed: _resetTechnicalParams,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Réinitialiser'),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMainCalculatorCard() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Calculateur Principal",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: isDark
                    ? theme.colorScheme.surfaceContainerHighest.withOpacity(0.5)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  _buildTextField('Diamètre de la Forme (D)', _dController,
                      focusNode: _dFocusNode, icon: Icons.circle_outlined),
                  const SizedBox(height: 10),
                  _buildTextField('Périmètre de la forme', _perimetreController,
                      focusNode: _perimetreFocusNode,
                      icon: Icons.donut_large_outlined),
                  const SizedBox(height: 10),
                  _buildTextField(
                      'Largeur avant manchon', _largSleeveController,
                      focusNode: _largSleeveFocusNode,
                      icon: Icons.unfold_more_outlined),
                  const SizedBox(height: 10),
                  _buildTextField('Largeur Etuit', _largEtuitController,
                      focusNode: _largEtuitFocusNode,
                      icon: Icons.unfold_less_outlined),
                ],
              ),
            ),
            const SizedBox(height: 10),
            ListTile(
              title: const Text('Inclure le Spote externe'),
              trailing: Switch(
                value: _isSpoteExterne,
                onChanged: (value) {
                  setState(() => _isSpoteExterne = value);
                  _calculate();
                },
                activeThumbColor: theme.colorScheme.primary,
              ),
              onTap: () {
                setState(() => _isSpoteExterne = !_isSpoteExterne);
                _calculate();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final String resultLabel = _isSpoteExterne
        ? "Laize impression avec spote Externe"
        : "Laize impression sans spote";

    return Card(
      elevation: 4,
      color: isDark
          ? colorScheme.secondaryContainer
          : colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(resultLabel,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            Text(
              '${_numberFormat.format(_laizeImpSleeve.round())} mm',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? colorScheme.onSecondaryContainer
                    : colorScheme.onPrimaryContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {FocusNode? focusNode, IconData? icon, bool readOnly = false}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color fillColor;
    if (readOnly) {
      fillColor = isDark ? Colors.grey.shade800 : Colors.grey.shade300;
    } else {
      fillColor = isDark
          ? theme.colorScheme.surfaceContainerHighest.withOpacity(0.3)
          : Colors.white;
    }

    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon) : null,
        border: const OutlineInputBorder(),
        isDense: true,
        fillColor: fillColor,
        filled: true,
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
    );
  }
}
