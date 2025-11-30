import 'dart:io';
import 'package:flutter/material.dart';

class AvatarImage extends StatelessWidget {
  final String? imagePath;
  final String fallbackText;
  final double radius;

  const AvatarImage({
    super.key,
    required this.imagePath,
    required this.fallbackText,
    this.radius = 20,
  });

  @override
  Widget build(BuildContext context) {
    if (imagePath == null) {
      return CircleAvatar(
        radius: radius,
        child:
            Text(fallbackText.isNotEmpty ? fallbackText[0].toUpperCase() : '?'),
      );
    }

    if (imagePath!.startsWith('http')) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: NetworkImage(imagePath!),
        onBackgroundImageError: (exception, stackTrace) {
          print('❌ Erreur chargement image ($imagePath): $exception');
        },
        child: null, // You could add a fallback icon here if needed
      );
    } else {
      return CircleAvatar(
        radius: radius,
        backgroundImage: FileImage(File(imagePath!)),
        onBackgroundImageError: (exception, stackTrace) {
          print('❌ Erreur chargement fichier local ($imagePath): $exception');
        },
      );
    }
  }
}
