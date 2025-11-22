import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// To track the last field edited by the user, for driving calculations.
enum _LastEdited { d, largSleeve, largEtuit }

class CalculManchonPage extends StatefulWidget {
  const CalculManchonPage({super.key});

  @override
  State<CalculManchonPage> createState() => _CalculManchonPageState();
}

class _CalculManchonPageState extends State<CalculManchonPage> {
  // --- Controllers ---
  final _dController = TextEditingController();
  final _largSleeveController = TextEditingController();
  final _largEtuitController = TextEditingController();
  
  final _lcController = TextEditingController();
  final _sccController = TextEditingController();
  final _retractController = TextEditingController();
  final _scdController = TextEditingController();
  final _scgController = TextEditingController();
  final _gbController = TextEditingController();
  final _spoteController = TextEditingController();

  // --- Focus Nodes to track user intent ---
  final _dFocusNode = FocusNode();
  final _largSleeveFocusNode = FocusNode();
  final _largEtuitFocusNode = FocusNode();

  // --- State ---
  _LastEdited _lastEdited = _LastEdited.d;
  double _laizeImpSleeve = 0.0;
  bool _isSpoteInterne = false;
  bool _isCalculating = false;

  final NumberFormat _numberFormat = NumberFormat("#,###.##", "fr_FR");

  @override
  void initState() {
    super.initState();
    // Set default values
    _lcController.text = "5";
    _sccController.text = "1";
    _retractController.text = "10";
    _scdController.text = "3";
    _scgController.text = "3";
    _gbController.text = "2";
    _spoteController.text = "3";
    
    // Add listeners to all controllers to trigger recalculation
    final allControllers = [
      _dController, _largSleeveController, _largEtuitController,
      _lcController, _sccController, _retractController,
      _scdController, _scgController, _gbController, _spoteController
    ];
    for (var controller in allControllers) {
      controller.addListener(_onInputChanged);
    }
    
    // Add focus listeners to determine which field drives the calculation
    _dFocusNode.addListener(() {
      if (_dFocusNode.hasFocus) setState(() => _lastEdited = _LastEdited.d);
    });
    _largSleeveFocusNode.addListener(() {
      if (_largSleeveFocusNode.hasFocus) setState(() => _lastEdited = _LastEdited.largSleeve);
    });
    _largEtuitFocusNode.addListener(() {
      if (_largEtuitFocusNode.hasFocus) setState(() => _lastEdited = _LastEdited.largEtuit);
    });

    _calculate();
  }

  @override
  void dispose() {
    // Dispose all controllers and focus nodes
    final allDisposables = [
      _dController, _largSleeveController, _largEtuitController,
      _lcController, _sccController, _retractController,
      _scdController, _scgController, _gbController, _spoteController,
      _dFocusNode, _largSleeveFocusNode, _largEtuitFocusNode
    ];
    for (var disposable in allDisposables) {
      disposable.dispose();
    }
    super.dispose();
  }
  
  void _onInputChanged() {
    if (!_isCalculating) {
      _calculate();
    }
  }

  void _updateTextField(TextEditingController controller, double value) {
    final formattedValue = (value > 0 && value.isFinite) ? _numberFormat.format(value) : '';
    if (controller.text != formattedValue) {
      controller.text = formattedValue;
    }
  }
  
  void _calculate() {
    if (_isCalculating) return;
    _isCalculating = true;

    final lc = double.tryParse(_lcController.text.replaceAll(' ', '').replaceAll(',', '.')) ?? 0.0;
    final scc = double.tryParse(_sccController.text.replaceAll(' ', '').replaceAll(',', '.')) ?? 0.0;
    final retract = double.tryParse(_retractController.text.replaceAll(' ', '').replaceAll(',', '.')) ?? 0.0;
    final scd = double.tryParse(_scdController.text.replaceAll(' ', '').replaceAll(',', '.')) ?? 0.0;
    final scg = double.tryParse(_scgController.text.replaceAll(' ', '').replaceAll(',', '.')) ?? 0.0;
    final gb = double.tryParse(_gbController.text.replaceAll(' ', '').replaceAll(',', '.')) ?? 0.0;
    final spote = double.tryParse(_spoteController.text.replaceAll(' ', '').replaceAll(',', '.')) ?? 0.0;

    double d = 0, largSleeve = 0, largEtuit = 0;
    final part2 = lc + scc;

    switch (_lastEdited) {
      case _LastEdited.d:
        d = double.tryParse(_dController.text.replaceAll(' ', '').replaceAll(',', '.')) ?? 0.0;
        if (d > 0) {
          largSleeve = (pi * d) / 2 + part2 + retract;
          largEtuit = (largSleeve - part2) / 2;
          _updateTextField(_largSleeveController, largSleeve);
          _updateTextField(_largEtuitController, largEtuit);
        }
        break;
      case _LastEdited.largSleeve:
        largSleeve = double.tryParse(_largSleeveController.text.replaceAll(' ', '').replaceAll(',', '.')) ?? 0.0;
        if (largSleeve > part2 + retract) {
          d = (2 * (largSleeve - part2 - retract)) / pi;
          largEtuit = (largSleeve - part2) / 2;
          _updateTextField(_dController, d);
          _updateTextField(_largEtuitController, largEtuit);
        }
        break;
      case _LastEdited.largEtuit:
        largEtuit = double.tryParse(_largEtuitController.text.replaceAll(' ', '').replaceAll(',', '.')) ?? 0.0;
        if (largEtuit > 0) {
          largSleeve = (largEtuit * 2) + part2;
          if (largSleeve > part2 + retract) {
            d = (2 * (largSleeve - part2 - retract)) / pi;
            _updateTextField(_dController, d);
            _updateTextField(_largSleeveController, largSleeve);
          }
        }
        break;
    }

    final spoteValue = _isSpoteInterne ? 0.0 : spote;
    final newLaizeImpSleeve = largSleeve > 0 ? (largSleeve + scd + scg + (gb * 2) + spoteValue) : 0.0;

    setState(() {
      _laizeImpSleeve = newLaizeImpSleeve;
    });
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _isCalculating = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 700;
        final mainContent = [
           _buildTechniqueParams(context),
           _buildMainCalculator(context),
        ];

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: isWide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final item in mainContent) Expanded(child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: item,
                    )),
                  ],
                )
              : Column(
                children: [
                  for (final item in mainContent) Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: item,
                  ),
                ],
              ),
        );
      },
    );
  }

  Widget _buildTechniqueParams(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: const Text("Paramètres Techniques Sleeve"),
        initiallyExpanded: false,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                _buildTextField(_lcController, 'Largeur Collage (LC)', icon: Icons.settings_ethernet),
                const SizedBox(height: 16),
                _buildTextField(_sccController, 'Securite contre collage (SCC)', icon: Icons.security),
                const SizedBox(height: 16),
                _buildTextField(_retractController, 'Rétraction (Retract)', icon: Icons.center_focus_strong),
                const SizedBox(height: 16),
                _buildTextField(_scdController, 'Securite coupe droit (SCD)', icon: Icons.arrow_forward),
                const SizedBox(height: 16),
                _buildTextField(_scgController, 'Securite coupe gauche (SCG)', icon: Icons.arrow_back),
                const SizedBox(height: 16),
                _buildTextField(_gbController, 'Guide bande (GB)', icon: Icons.compare_arrows),
                const SizedBox(height: 16),
                _buildTextField(_spoteController, 'Spote', icon: Icons.adjust),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMainCalculator(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Calculateur Principal",
              style: textTheme.headlineSmall?.copyWith(color: colorScheme.primary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            _buildTextField(_dController, 'Diamètre de la Forme (D)', focusNode: _dFocusNode, icon: Icons.circle_outlined),
            const SizedBox(height: 16),
            _buildTextField(_largSleeveController, 'Largeur à plat (LargSleeve)', focusNode: _largSleeveFocusNode, icon: Icons.unfold_more),
            const SizedBox(height: 16),
            _buildTextField(_largEtuitController, 'Largeur Etuit (LargEtuit)', focusNode: _largEtuitFocusNode, icon: Icons.unfold_less),
            const SizedBox(height: 16),
            SwitchListTile(
              title: Text(_isSpoteInterne ? 'Spote : Interne (non inclus)' : 'Spote : Externe (inclus)'),
              value: _isSpoteInterne,
              onChanged: (bool value) {
                setState(() => _isSpoteInterne = value);
                _calculate();
              },
              secondary: Icon(_isSpoteInterne ? Icons.layers_clear_outlined : Icons.layers_outlined),
            ),
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 16),
            _buildResultRow("Laize Impression Sleeve:", _laizeImpSleeve, "mm", context),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    FocusNode? focusNode,
    IconData? icon,
  }) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: icon != null ? Icon(icon) : null,
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
    );
  }

  Widget _buildResultRow(String label, double value, String unit, BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(label, style: textTheme.titleMedium?.copyWith(color: colorScheme.onSecondaryContainer)),
          const SizedBox(height: 4),
          Text(
            '${_numberFormat.format(value)} $unit',
            style: textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSecondaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}
