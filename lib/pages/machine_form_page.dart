import 'package:flutter/material.dart';
import '../class/machine.dart';
import '../class/machine_type.dart';
import '../services/database_helper.dart';

class MachineFormPage extends StatefulWidget {
  final Machine? machine;

  const MachineFormPage({super.key, this.machine});

  @override
  State<MachineFormPage> createState() => _MachineFormPageState();
}

class _MachineFormPageState extends State<MachineFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _referenceController = TextEditingController();
  final _laizeMinController = TextEditingController();
  final _laizeMaxController = TextEditingController();
  final _nbrStationsController = TextEditingController();
  final _nbrStationsDecoupeController = TextEditingController();
  final _notesController = TextEditingController();

  int? _selectedTypeId;
  List<MachineType> _types = [];
  bool _isEditing = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMachineTypes();
    _isEditing = widget.machine != null;
    if (_isEditing) {
      _loadMachineData();
    }
  }

  Future<void> _loadMachineTypes() async {
    final typesData = await DatabaseHelper().getMachineTypes();
    setState(() {
      _types = typesData.map((e) => MachineType.fromMap(e)).toList();
      _isLoading = false;
    });
  }

  void _loadMachineData() {
    final machine = widget.machine!;
    _referenceController.text = machine.reference;
    _laizeMinController.text = machine.laizeMin.toString();
    _laizeMaxController.text = machine.laizeMax.toString();
    _nbrStationsController.text = machine.nbrStations?.toString() ?? '';
    _nbrStationsDecoupeController.text =
        machine.nbrStationsDecoupe?.toString() ?? '';
    _notesController.text = machine.notes ?? '';
    _selectedTypeId = machine.typeId;
  }

  @override
  void dispose() {
    _referenceController.dispose();
    _laizeMinController.dispose();
    _laizeMaxController.dispose();
    _nbrStationsController.dispose();
    _nbrStationsDecoupeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedTypeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner un type')),
      );
      return;
    }

    try {
      final machine = Machine(
        id: widget.machine?.id,
        typeId: _selectedTypeId!,
        reference: _referenceController.text,
        laizeMin: double.parse(_laizeMinController.text),
        laizeMax: double.parse(_laizeMaxController.text),
        nbrStations: _nbrStationsController.text.isEmpty
            ? null
            : int.parse(_nbrStationsController.text),
        nbrStationsDecoupe: _nbrStationsDecoupeController.text.isEmpty
            ? null
            : int.parse(_nbrStationsDecoupeController.text),
        notes: _notesController.text.isEmpty ? null : _notesController.text,
        typeName: _types.firstWhere((t) => t.id == _selectedTypeId).name,
      );

      if (_isEditing) {
        await DatabaseHelper().updateMachine(machine.toMap());
      } else {
        await DatabaseHelper().insertMachine(machine.toMap());
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Modifier Machine' : 'Nouvelle Machine'),
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
            // Type de machine
            DropdownButtonFormField<int>(
              value: _selectedTypeId,
              decoration: const InputDecoration(
                labelText: 'Type de machine *',
                prefixIcon: Icon(Icons.category),
              ),
              items: _types.map((type) {
                return DropdownMenuItem(
                  value: type.id,
                  child: Text(type.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedTypeId = value;
                });
              },
              validator: (value) => value == null ? 'Requis' : null,
            ),
            const SizedBox(height: 16),

            // Référence
            TextFormField(
              controller: _referenceController,
              decoration: const InputDecoration(
                labelText: 'Référence *',
                prefixIcon: Icon(Icons.tag),
                helperText: 'Ex: Weigang ZJR 450, Edale Alpha',
              ),
              validator: (value) => value?.isEmpty ?? true ? 'Requis' : null,
            ),
            const SizedBox(height: 16),

            // Laize section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Plage de Laize (mm)',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _laizeMinController,
                            decoration: const InputDecoration(
                              labelText: 'Min *',
                              prefixIcon: Icon(Icons.straighten),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value?.isEmpty ?? true) return 'Requis';
                              if (double.tryParse(value!) == null)
                                return 'Nombre invalide';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _laizeMaxController,
                            decoration: const InputDecoration(
                              labelText: 'Max *',
                              prefixIcon: Icon(Icons.straighten),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value?.isEmpty ?? true) return 'Requis';
                              final max = double.tryParse(value!);
                              if (max == null) return 'Nombre invalide';
                              final min =
                                  double.tryParse(_laizeMinController.text);
                              if (min != null && max < min) {
                                return 'Max < Min';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Stations section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Stations (optionnel)',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _nbrStationsController,
                            decoration: const InputDecoration(
                              labelText: 'Nombre stations',
                              prefixIcon: Icon(Icons.layers),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value != null && value.isNotEmpty) {
                                if (int.tryParse(value) == null) {
                                  return 'Nombre invalide';
                                }
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _nbrStationsDecoupeController,
                            decoration: const InputDecoration(
                              labelText: 'Stations découpe',
                              prefixIcon: Icon(Icons.content_cut),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value != null && value.isNotEmpty) {
                                if (int.tryParse(value) == null) {
                                  return 'Nombre invalide';
                                }
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
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
          ],
        ),
      ),
    );
  }
}
