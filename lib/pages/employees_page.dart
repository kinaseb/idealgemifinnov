import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/supabase_service.dart';
import '../class/employee.dart';

class EmployeesPage extends StatefulWidget {
  const EmployeesPage({super.key});

  @override
  State<EmployeesPage> createState() => _EmployeesPageState();
}

class _EmployeesPageState extends State<EmployeesPage> {
  List<Employee> _employees = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEmployees();
  }

  Future<void> _loadEmployees() async {
    setState(() => _isLoading = true);
    try {
      final data = await SupabaseService().getEmployees();
      setState(() {
        _employees = data.map((e) => Employee.fromMap(e)).toList();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur chargement employés: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteEmployee(Employee employee) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer suppression'),
        content: Text('Voulez-vous vraiment supprimer ${employee.fullName} ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true && employee.id != null) {
      try {
        await SupabaseService().deleteEmployee(employee.id!);
        _loadEmployees();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur suppression: $e')),
          );
        }
      }
    }
  }

  void _showEmployeeDialog([Employee? employee]) {
    showDialog(
      context: context,
      builder: (context) => EmployeeDialog(
        employee: employee,
        onSave: _loadEmployees,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Employés'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _employees.isEmpty
              ? const Center(child: Text('Aucun employé'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _employees.length,
                  itemBuilder: (context, index) {
                    final employee = _employees[index];
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: employee.photoUrl != null
                              ? NetworkImage(employee.photoUrl!)
                              : null,
                          child: employee.photoUrl == null
                              ? Text(employee.firstName[0])
                              : null,
                        ),
                        title: Text(employee.fullName),
                        subtitle: Text(employee.jobTitle ?? 'Sans poste'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _showEmployeeDialog(employee),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteEmployee(employee),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEmployeeDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class EmployeeDialog extends StatefulWidget {
  final Employee? employee;
  final VoidCallback onSave;

  const EmployeeDialog({super.key, this.employee, required this.onSave});

  @override
  State<EmployeeDialog> createState() => _EmployeeDialogState();
}

class _EmployeeDialogState extends State<EmployeeDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _jobController;
  late TextEditingController _phoneController;
  String? _photoUrl;
  File? _newPhotoFile;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _firstNameController =
        TextEditingController(text: widget.employee?.firstName);
    _lastNameController =
        TextEditingController(text: widget.employee?.lastName);
    _jobController = TextEditingController(text: widget.employee?.jobTitle);
    _phoneController = TextEditingController(text: widget.employee?.phone);
    _photoUrl = widget.employee?.photoUrl;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _newPhotoFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      String? finalPhotoUrl = _photoUrl;

      if (_newPhotoFile != null) {
        finalPhotoUrl =
            await SupabaseService().uploadImage(_newPhotoFile!, 'employees');
      }

      final employeeData = {
        'first_name': _firstNameController.text,
        'last_name': _lastNameController.text,
        'job_title': _jobController.text,
        'phone': _phoneController.text,
        'photo_url': finalPhotoUrl,
      };

      if (widget.employee == null) {
        employeeData['hire_date'] = DateTime.now().toIso8601String();
        await SupabaseService().insertEmployee(employeeData);
      } else {
        await SupabaseService()
            .updateEmployee(widget.employee!.id!, employeeData);
      }

      widget.onSave();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur sauvegarde: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title:
          Text(widget.employee == null ? 'Nouvel Employé' : 'Modifier Employé'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 40,
                  backgroundImage: _newPhotoFile != null
                      ? FileImage(_newPhotoFile!)
                      : (_photoUrl != null ? NetworkImage(_photoUrl!) : null)
                          as ImageProvider?,
                  child: (_newPhotoFile == null && _photoUrl == null)
                      ? const Icon(Icons.camera_alt, size: 40)
                      : null,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(labelText: 'Prénom'),
                validator: (v) => v?.isEmpty == true ? 'Requis' : null,
              ),
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(labelText: 'Nom'),
                validator: (v) => v?.isEmpty == true ? 'Requis' : null,
              ),
              TextFormField(
                controller: _jobController,
                decoration: const InputDecoration(labelText: 'Poste'),
              ),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Téléphone'),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _save,
          child: _isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Enregistrer'),
        ),
      ],
    );
  }
}
