import 'package:flutter/material.dart';
import '../class/repeat.dart';
import '../class/magnetic_cylinder.dart';
import '../services/database_helper.dart';

class RepeatFormPage extends StatefulWidget {
  final Repeat? repeat;

  const RepeatFormPage({super.key, this.repeat});

  @override
  State<RepeatFormPage> createState() => _RepeatFormPageState();
}

class _RepeatFormPageState extends State<RepeatFormPage> {
  final _formKey = GlobalKey<FormState>();
  // Reference removed - will auto-generate from nbrDents
  final _nbrDentsController = TextEditingController();
  final _quantiteController = TextEditingController();
  final _fournisseurController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime? _dateAchat;
  List<MagneticCylinder> _cylinders = [];
  bool _isEditing = false;
  bool _hasMagneticCylinder = false;
  List<int> _selectedMachineIds = []; // New: selected machines
  List<Map<String, dynamic>> _availableMachines = []; // New: all machines

  @override
  void initState() {
    super.initState();
    _isEditing = widget.repeat != null;
    _loadMachines();
    if (_isEditing) {
      _loadRepeatData();
    }
  }

  Future<void> _loadMachines() async {
    final machines = await DatabaseHelper().getMachines();
    setState(() {
      // Filter only impression machines (typeId 1 = Flexo/Impression)
      _availableMachines = machines.where((m) => m['typeId'] == 1).toList();
    });
  }

  Future<void> _loadRepeatData() async {
    final repeat = widget.repeat!;
    // Extract number from reference (Z85 -> 85)
    _nbrDentsController.text = repeat.nbrDents.toString();
    _quantiteController.text = repeat.quantite.toString();
    _fournisseurController.text = repeat.fournisseur ?? '';
    _notesController.text = repeat.notes ?? '';
    _dateAchat = repeat.dateAchat;

    // Load cylinders
    final cylData =
        await DatabaseHelper().getMagneticCylindersByRepeat(repeat.id!);

    // Load linked machines
    final linkedMachines =
        await DatabaseHelper().getMachinesByRepeat(repeat.id!);

    setState(() {
      _cylinders = cylData.map((e) => MagneticCylinder.fromMap(e)).toList();
      _hasMagneticCylinder = _cylinders.isNotEmpty;
      _selectedMachineIds = linkedMachines.map((m) => m['id'] as int).toList();
    });
  }

  @override
  void dispose() {
    _nbrDentsController.dispose();
    _quantiteController.dispose();
    _fournisseurController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    print('🔵 DEBUG: _save() appelé');
    if (!_formKey.currentState!.validate()) {
      print('❌ DEBUG: Validation formulaire échouée');
      return;
    }

    try {
      final nbrDents = int.parse(_nbrDentsController.text);
      final reference = 'Z$nbrDents'; // Auto-generate: Z85, Z74, etc.
      print('🔵 DEBUG: Création repeat référence=$reference dents=$nbrDents');

      final repeat = Repeat(
        id: widget.repeat?.id,
        reference: reference,
        nbrDents: nbrDents,
        quantite: int.parse(_quantiteController.text),
        dateAchat: _dateAchat,
        fournisseur: _fournisseurController.text.isEmpty
            ? null
            : _fournisseurController.text,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );

      int repeatId;
      if (_isEditing) {
        print('🔵 DEBUG: Mode édition, update repeat id=${repeat.id}');
        await DatabaseHelper().updateRepeat(repeat.toMap());
        repeatId = repeat.id!;
      } else {
        print('🔵 DEBUG: Mode création, insert repeat');
        repeatId = await DatabaseHelper().insertRepeat(repeat.toMap());
        print('✅ DEBUG: Repeat créé avec ID=$repeatId');
      }

      // Save/delete magnetic cylinder based on checkbox
      try {
        if (_hasMagneticCylinder) {
          // Auto-create or update magnetic cylinder
          MagneticCylinder cylinder;
          if (_cylinders.isEmpty) {
            cylinder = MagneticCylinder(
              repeatId: repeatId,
              reference: '${reference}-CYL', // Use auto reference
              quantite: 1,
              notes: 'Cylindre magnétique (auto)',
            );
          } else {
            cylinder = MagneticCylinder(
              id: _cylinders.first.id,
              repeatId: repeatId,
              reference: '${reference}-CYL', // Use auto reference
              quantite: _cylinders.first.quantite,
              dateAchat: _cylinders.first.dateAchat,
              etat: _cylinders.first.etat,
              notes: 'Cylindre magnétique (auto)',
            );
          }

          final cylData = cylinder.toMap();
          cylData['repeatId'] = repeatId;

          if (cylinder.id != null) {
            await DatabaseHelper().updateMagneticCylinder(cylData);
          } else {
            await DatabaseHelper().insertMagneticCylinder(cylData);
          }
        } else {
          // Delete cylinders if unchecked
          for (var cylinder in _cylinders) {
            if (cylinder.id != null) {
              await DatabaseHelper().deleteMagneticCylinder(cylinder.id!);
            }
          }
        }
      } catch (cylError) {
        print('⚠️ Erreur cylindre (non-bloquant): $cylError');
        // Continue even if cylinder fails
      }

      // Save machine links
      try {
        await DatabaseHelper()
            .linkMachinesToRepeat(repeatId, _selectedMachineIds);
      } catch (linkError) {
        print('⚠️ Erreur liaison machines: $linkError');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Repeat $reference sauvegardé'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e, stackTrace) {
      print('❌ Erreur sauvegarde repeat: $e');
      print('Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Modifier Repeat' : 'Nouveau Repeat'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _save,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Info sur la référence auto
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[700]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'La référence sera générée automatiquement: Z{nombre_de_dents}',
                        style: TextStyle(fontSize: 12, color: Colors.blue[900]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Nombre de dents
            TextFormField(
              controller: _nbrDentsController,
              decoration: const InputDecoration(
                labelText: 'Nombre de dents *',
                prefixIcon: Icon(Icons.settings),
                helperText: 'Le développement sera calculé automatiquement',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Requis';
                if (int.tryParse(value!) == null) return 'Nombre invalide';
                return null;
              },
              onChanged: (value) => setState(() {}), // Refresh for preview
            ),
            if (_nbrDentsController.text.isNotEmpty &&
                int.tryParse(_nbrDentsController.text) != null)
              Padding(
                padding: const EdgeInsets.only(left: 56, top: 4),
                child: Text(
                  'Développement: ${(int.parse(_nbrDentsController.text) * 3.175).toStringAsFixed(2)} mm',
                  style: TextStyle(color: Colors.blue[700], fontSize: 12),
                ),
              ),
            const SizedBox(height: 16),

            // Quantité
            TextFormField(
              controller: _quantiteController,
              decoration: const InputDecoration(
                labelText: 'Quantité en stock *',
                prefixIcon: Icon(Icons.inventory),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Requis';
                if (int.tryParse(value!) == null) return 'Nombre invalide';
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Date achat
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: Text(_dateAchat == null
                  ? 'Date d\'achat (optionnel)'
                  : 'Date: ${_dateAchat!.day}/${_dateAchat!.month}/${_dateAchat!.year}'),
              trailing: _dateAchat != null
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => setState(() => _dateAchat = null),
                    )
                  : null,
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _dateAchat ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  setState(() => _dateAchat = date);
                }
              },
            ),
            const SizedBox(height: 16),

            // Fournisseur
            TextFormField(
              controller: _fournisseurController,
              decoration: const InputDecoration(
                labelText: 'Fournisseur (optionnel)',
                prefixIcon: Icon(Icons.business),
              ),
            ),
            const SizedBox(height: 16),

            // Notes
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (optionnel)',
                prefixIcon: Icon(Icons.note),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),

            // Machines compatibles - Multi-select
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.precision_manufacturing,
                            color: Colors.blue),
                        const SizedBox(width: 8),
                        const Text(
                          'Machines Compatibles',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Sélectionnez les machines qui utilisent ce repeat',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _availableMachines.map((machine) {
                        final machineId = machine['id'] as int;
                        final isSelected =
                            _selectedMachineIds.contains(machineId);
                        return FilterChip(
                          label: Text(machine['reference'] as String),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedMachineIds.add(machineId);
                              } else {
                                _selectedMachineIds.remove(machineId);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    if (_selectedMachineIds.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text(
                          'Aucune machine sélectionnée',
                          style: TextStyle(fontSize: 12, color: Colors.orange),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Simple checkbox for magnetic cylinder
            Card(
              color: Colors.green[50],
              child: CheckboxListTile(
                title: Row(
                  children: [
                    const Icon(Icons.hexagon, color: Colors.green, size: 24),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Cylindre Magnétique',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                subtitle: Text(
                  _hasMagneticCylinder
                      ? '✓ Cylindre auto-créé avec ${_nbrDentsController.text.isNotEmpty ? _nbrDentsController.text + " dents" : "?"}'
                      : 'Cocher pour créer auto un cylindre magnétique',
                  style: TextStyle(
                    color: _hasMagneticCylinder
                        ? Colors.green[700]
                        : Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                value: _hasMagneticCylinder,
                onChanged: (value) {
                  setState(() {
                    _hasMagneticCylinder = value ?? false;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
