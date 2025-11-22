import 'package:flutter/material.dart';

class InputFieldWithButton extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String buttonText;
  final VoidCallback onPressed;
  final IconData? icon;

  const InputFieldWithButton({
    super.key,
    required this.label,
    required this.controller,
    required this.buttonText,
    required this.onPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: label,
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(width: 8.0),
          ElevatedButton.icon(
            onPressed: onPressed,
            icon: Icon(icon),
            label: Text(buttonText),
          ),
        ],
      ),
    );
  }
}
