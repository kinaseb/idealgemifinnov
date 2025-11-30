import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../class/article.dart';
import '../class/client.dart';
import '../class/support.dart';
import '../services/database_helper.dart';
import '../services/supabase_service.dart';
import '../widgets/avatar_image.dart';
import '../widgets/image_zoom_dialog.dart';

class ArticleFormPage extends StatefulWidget {
  final Client client;
  final Article? article;

  const ArticleFormPage({super.key, required this.client, this.article});

  @override
  State<ArticleFormPage> createState() => _ArticleFormPageState();
}

class _ArticleFormPageState extends State<ArticleFormPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late TextEditingController _nameController;
  late TextEditingController _typeAutreController;
  late TextEditingController _costPriceController;

  late TextEditingController _poseCountController;
  late TextEditingController _widthController;
  late TextEditingController _colorCountController;
  late TextEditingController _sleeveCaseController;
  late TextEditingController _labelsPerReelController;
  late TextEditingController _coreController;

  // State variables
  String? _photoPath;
  String _selectedType = 'etiquette';
  String _selectedMachine = 'ZJR 450';
  int? _selectedSupportId;
  bool _isAmalgam = false;
  List<Support> _supports = [];
  bool _isLoadingSupports = true;

  // Machine Repeats
  List<double> _availableRepeats = [];
  double? _selectedRepeat;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadSupports();
    _loadRepeatsForMachine(_selectedMachine);
  }

  void _initializeControllers() {
    final a = widget.article;
    _nameController = TextEditingController(text: a?.name ?? '');
    _typeAutreController = TextEditingController(text: a?.typeAutre ?? '');
    _costPriceController =
        TextEditingController(text: a?.costPrice.toString() ?? '');
    // _repeatController removed in favor of dropdown logic
    _poseCountController =
        TextEditingController(text: a?.poseCount.toString() ?? '');
    _widthController = TextEditingController(text: a?.width.toString() ?? '');
    _colorCountController =
        TextEditingController(text: a?.colorCount.toString() ?? '');
    _sleeveCaseController =
        TextEditingController(text: a?.sleeveCase.toString() ?? '');
    _labelsPerReelController =
        TextEditingController(text: a?.labelsPerReel.toString() ?? '');
    _coreController = TextEditingController(text: a?.core ?? '');

    if (a != null) {
      _photoPath = a.photo;
      _selectedType = a.type;
      _selectedMachine = a.machine;
      _selectedSupportId = a.supportId;
      _isAmalgam = a.amalgam;
      _selectedRepeat = a.repeat;
    }
  }

  Future<void> _loadRepeatsForMachine(String machine) async {
    final repeats = await DatabaseHelper().getRepeatsForMachine(machine);
    setState(() {
      _availableRepeats = repeats;
      if (_selectedRepeat != null &&
          !_availableRepeats.contains(_selectedRepeat)) {
        // If current repeat not in list (maybe new machine?), add it temporarily or handle it
        _availableRepeats.add(_selectedRepeat!);
        _availableRepeats.sort();
      }
      // If no repeat selected and list not empty, select first? No, let user choose.
    });
  }

  Future<void> _addRepeat(double value) async {
    await DatabaseHelper().insertMachineRepeat(_selectedMachine, value);
    await _loadRepeatsForMachine(_selectedMachine);
    setState(() {
      _selectedRepeat = value;
    });
  }

  Future<void> _loadSupports() async {
    final data = await DatabaseHelper().getSupports();
    setState(() {
      _supports = data.map((e) => Support.fromMap(e)).toList();
      _isLoadingSupports = false;

      // If editing and support not found (deleted?), clear selection
      if (_selectedSupportId != null &&
          !_supports.any((s) => s.id == _selectedSupportId)) {
        _selectedSupportId = null;
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _typeAutreController.dispose();
    _costPriceController.dispose();
    // _repeatController.dispose();
    _poseCountController.dispose();
    _widthController.dispose();
    _colorCountController.dispose();
    _sleeveCaseController.dispose();
    _labelsPerReelController.dispose();
    _coreController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);

    if (image != null) {
      setState(() {
        _photoPath = image.path;
      });
    }
  }

  Future<void> _saveArticle() async {
    if (_formKey.currentState!.validate()) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      try {
        String? photoUrl = _photoPath;

        // Upload image if it's a local file
        if (_photoPath != null && !_photoPath!.startsWith('http')) {
          final file = File(_photoPath!);
          final uploadedUrl =
              await SupabaseService().uploadImage(file, 'articles');
          if (uploadedUrl != null) {
            photoUrl = uploadedUrl;
          }
        }

        final article = Article(
          id: widget.article?.id,
          clientId: widget.client.id!,
          name: _nameController.text,
          photo: photoUrl,
          type: _selectedType,
          typeAutre:
              _selectedType == 'autre' ? _typeAutreController.text : null,
          supportId: _selectedSupportId,
          costPrice: double.tryParse(_costPriceController.text) ?? 0.0,
          repeat: _selectedRepeat ?? 0.0,
          poseCount: int.tryParse(_poseCountController.text) ?? 1,
          amalgam: _isAmalgam,
          width: double.tryParse(_widthController.text) ?? 0.0,
          machine: _selectedMachine,
          colorCount: int.tryParse(_colorCountController.text) ?? 0,
          sleeveCase: _selectedType == 'sleeve'
              ? (double.tryParse(_sleeveCaseController.text) ?? 0.0)
              : 0.0,
          labelsPerReel: int.tryParse(_labelsPerReelController.text) ?? 0,
          core: _coreController.text,
        );

        final articleData = article.toSupabaseMap();

        if (widget.article == null) {
          articleData.remove('id');
          await SupabaseService().insertArticle(articleData);
        } else {
          await SupabaseService().updateArticle(article.id!, articleData);
        }

        if (mounted) {
          Navigator.pop(context); // Close loading
          Navigator.pop(context); // Close form
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Article saved successfully'),
                backgroundColor: Colors.green),
          );
        }
      } catch (e) {
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.article == null ? 'New Article' : 'Edit Article'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Image Picker
            Center(
              child: GestureDetector(
                onTap: () {
                  if (_photoPath != null) {
                    showDialog(
                      context: context,
                      builder: (context) => ImageZoomDialog(
                          imagePath: !_photoPath!.startsWith('http')
                              ? _photoPath
                              : null,
                          imageUrl: _photoPath!.startsWith('http')
                              ? _photoPath
                              : null),
                    );
                  } else {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) => SafeArea(
                        child: Wrap(
                          children: [
                            ListTile(
                              leading: const Icon(Icons.photo_library),
                              title: const Text('Gallery'),
                              onTap: () {
                                Navigator.pop(context);
                                _pickImage(ImageSource.gallery);
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.camera_alt),
                              title: const Text('Camera'),
                              onTap: () {
                                Navigator.pop(context);
                                _pickImage(ImageSource.camera);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                },
                onLongPress: () {
                  // Allow changing image on long press if already set
                  showModalBottomSheet(
                    context: context,
                    builder: (context) => SafeArea(
                      child: Wrap(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.photo_library),
                            title: const Text('Gallery'),
                            onTap: () {
                              Navigator.pop(context);
                              _pickImage(ImageSource.gallery);
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.camera_alt),
                            title: const Text('Camera'),
                            onTap: () {
                              Navigator.pop(context);
                              _pickImage(ImageSource.camera);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
                child: AvatarImage(
                  imagePath: _photoPath,
                  fallbackText: '',
                  radius: 60,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Basic Info
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nom de l\'article'),
              validator: (v) => v?.isEmpty == true ? 'Required' : null,
            ),
            const SizedBox(height: 12),

            // Type
            DropdownButtonFormField<String>(
              value: _selectedType,
              decoration: const InputDecoration(labelText: 'Type'),
              items: ['etiquette', 'sleeve', 'autre']
                  .map((t) => DropdownMenuItem(
                        value: t,
                        child: Text(t.toUpperCase()),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _selectedType = v!),
            ),
            if (_selectedType == 'autre') ...[
              const SizedBox(height: 12),
              TextFormField(
                controller: _typeAutreController,
                decoration: const InputDecoration(labelText: 'Specify Type'),
                validator: (v) => _selectedType == 'autre' && v?.isEmpty == true
                    ? 'Required'
                    : null,
              ),
            ],
            const SizedBox(height: 12),

            // Support
            _isLoadingSupports
                ? const LinearProgressIndicator()
                : DropdownButtonFormField<int>(
                    value: _selectedSupportId,
                    decoration:
                        const InputDecoration(labelText: 'Support (Material)'),
                    items: _supports
                        .map((s) => DropdownMenuItem(
                              value: s.id,
                              child: Text(
                                  '${s.name} (${s.supplier ?? "No Supplier"})'),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedSupportId = v),
                    validator: (v) => v == null ? 'Required' : null,
                  ),
            const SizedBox(height: 12),

            // Technical Specs Row 1
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedMachine,
                    decoration: const InputDecoration(labelText: 'Machine'),
                    items: ['ZJR 450', 'Alpha 240']
                        .map((m) => DropdownMenuItem(
                              value: m,
                              child: Text(m),
                            ))
                        .toList(),
                    onChanged: (v) {
                      setState(() {
                        _selectedMachine = v!;
                        _selectedRepeat =
                            null; // Reset repeat on machine change
                        _loadRepeatsForMachine(v);
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<double>(
                          value: _selectedRepeat,
                          decoration:
                              const InputDecoration(labelText: 'Repeat'),
                          items: _availableRepeats.map((r) {
                            return DropdownMenuItem(
                              value: r,
                              child: Text(r.toString()),
                            );
                          }).toList(),
                          onChanged: (v) => setState(() => _selectedRepeat = v),
                          validator: (v) => v == null ? 'Required' : null,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          final controller = TextEditingController();
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('Add Repeat for $_selectedMachine'),
                              content: TextField(
                                controller: controller,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                    labelText: 'Repeat Value'),
                                autofocus: true,
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    final val =
                                        double.tryParse(controller.text);
                                    if (val != null) {
                                      _addRepeat(val);
                                      Navigator.pop(context);
                                    }
                                  },
                                  child: const Text('Add'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Technical Specs Row 1 (Modified)
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _costPriceController,
                    decoration: const InputDecoration(labelText: 'Prix revien'),
                    keyboardType: TextInputType.number,
                    validator: (v) => v?.isEmpty == true ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 12),
                // Repeat moved up
              ],
            ),
            const SizedBox(height: 12),

            // Technical Specs Row 2
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _widthController,
                    decoration:
                        const InputDecoration(labelText: 'Largeur (Laize)'),
                    keyboardType: TextInputType.number,
                    validator: (v) => v?.isEmpty == true ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _poseCountController,
                    decoration:
                        const InputDecoration(labelText: 'Nombre de pose'),
                    keyboardType: TextInputType.number,
                    validator: (v) => v?.isEmpty == true ? 'Required' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Colors (Moved out of Machine Row)
            TextFormField(
              controller: _colorCountController,
              decoration:
                  const InputDecoration(labelText: 'Nombre de couleurs'),
              keyboardType: TextInputType.number,
              validator: (v) => v?.isEmpty == true ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            const SizedBox(height: 12),

            // Sleeve Specific
            if (_selectedType == 'sleeve') ...[
              TextFormField(
                controller: _sleeveCaseController,
                decoration: const InputDecoration(labelText: 'Etuit (Case)'),
                keyboardType: TextInputType.number,
                validator: (v) => v?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 12),
            ],

            // Delivery Specs
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _labelsPerReelController,
                    decoration: const InputDecoration(
                        labelText: 'Livraison Etiq / bobine'),
                    keyboardType: TextInputType.number,
                    validator: (v) => v?.isEmpty == true ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _coreController,
                    decoration:
                        const InputDecoration(labelText: 'Livraison (Mandrin)'),
                    validator: (v) => v?.isEmpty == true ? 'Required' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Amalgam
            SwitchListTile(
              title: const Text('Amalgam'),
              value: _isAmalgam,
              onChanged: (v) => setState(() => _isAmalgam = v),
            ),
            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: _saveArticle,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Ajouter Article'),
            ),
          ],
        ),
      ),
    );
  }
}
