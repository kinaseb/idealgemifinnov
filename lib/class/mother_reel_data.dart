import 'package:flutter/material.dart';

class CutRow {
  final TextEditingController widthController;
  final TextEditingController qtyController;
  final String id;

  CutRow({String? width, String? qty})
      : widthController = TextEditingController(text: width),
        qtyController = TextEditingController(text: qty),
        id = DateTime.now().microsecondsSinceEpoch.toString();

  void dispose() {
    widthController.dispose();
    qtyController.dispose();
  }
}

class MotherReelData {
  final TextEditingController widthController;
  final TextEditingController quantityController;
  final List<CutRow> cuts;
  final String id;

  // Results for this reel
  double totalUsed = 0;
  double waste = 0;
  bool isOverLimit = false;

  MotherReelData()
      : widthController = TextEditingController(),
        quantityController = TextEditingController(text: "1"),
        cuts = [],
        id = DateTime.now().microsecondsSinceEpoch.toString();

  void dispose() {
    widthController.dispose();
    quantityController.dispose();
    for (var cut in cuts) {
      cut.dispose();
    }
  }
}
