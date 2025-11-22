import 'package:flutter/foundation.dart';

/// Classe qui calcule laize et repeat de l'etiquette
class Etiquette {
  // Variable d'instance
  double? hauteur = 0;
  double? largeur = 0;
  double? hauteurChain = 3;
  double? largeurChain = 3;
  int bobM = 1000;

  // Variable de classe
  List<int> repWeigangEtiq = [85, 94, 112, 135];
  List<int> repWeigangSleeve = [76, 85, 94, 112, 135, 190];
  List<int> repEdale = [74, 85, 94, 115];

  // Constants moved from donnees.dart
  static const List<String> availableRepeats = ["74", "76", "85", "94", "112", "115", "135", "190"];
  static final List<String> availablePoses = List.generate(100, (index) => (index + 1).toString());
  static const List<String> includeWasteOptions = ["oui", "non"];

  int spot = 0;
  int poseParRepeat = 0;
  int poseParLaize = 0;
  int bobF = 0;

  Etiquette({
    this.hauteur,
    this.largeur,
    this.hauteurChain = 3.0,
    this.largeurChain = 3.0,
    this.bobM = 1000,
  }) {
    if (hauteur != null) {
      if (kDebugMode) {
        print("Hauteur : $hauteur");
      }
    }
  }

  Etiquette.weigang({
    this.hauteur,
    this.largeur = 0,
    this.hauteurChain = 0.0,
    this.largeurChain = 3.0,
    this.bobM = 1000,
  });

  /// calcRepeat est une meilleur approche
  /// pour calculer le repeat plus rapidement
  /// elle exige un parametre hauteur int
  /// et retourne une liste
  /// [repeat, Nbrpose , chainage]
  List<dynamic> calcRepeat(double? hauteur, [double hauteurChain = 0]) {
    double procheH = 1000;
    double calcule = 0;

    if (hauteur != null) {
      int? repIdeal;
      var tabRepeat = [85, 94, 112, 135]; // test pour weigang etiquette
      int? nbrPose;
      double hauteurConvert = (hauteur + hauteurChain) / 3.175; // hauteur+chainage

      for (var element in tabRepeat) {
        calcule = (element) % (hauteurConvert);
        int pose = (element) ~/ (hauteurConvert);
        if (procheH > calcule) {
          procheH = calcule;
          repIdeal = element;
          nbrPose = pose;
        }
      }
      var chainage = (procheH * 3.175 + hauteurChain) / (nbrPose ?? 1);

      return [repIdeal, nbrPose, chainage.toStringAsFixed(4)];
    }
    return [];
  }

  /// nouvelle calc repeat qui est intelligente elle prend comme parametre hauteur, [hauteurChain = 0, echelle = 5] echelle represente le maximum qu'on peux retricire la hauteur d'etiquette afin qu'elle s'adapte mieux avec nos jeux de repeat
  List<dynamic> calcRepeatIntelligent(double? hauteur,
      [double hauteurChain = 0, int echelle = 5]) {
    double newChute = 1000;
    double chuteRepeatEiq = 0;

    if (hauteur != null) {
      int? repIdeal;
      var tabRepeat = [85, 94, 112, 135]; // test pour weigang etiquette
      int? nbrPose;
      double? hautFinal;

      // On boucle sur la hauteur en réduisant jusqu'à 'echelle'
      for (var i = 0; i <= echelle; i++) {
        double newHauteur = hauteur - i;
        
        double hauteurConvert = (newHauteur + hauteurChain) / 3.175; 

        for (var repeat in tabRepeat) {
          chuteRepeatEiq = (repeat) % (hauteurConvert); // % modulo
          int pose = (repeat) ~/ (hauteurConvert); // ~/ entier de la division
          
          if (pose == 0) continue;

          double chuteSupposer = (chuteRepeatEiq / pose) + hauteurChain;
          
          if ((newChute > chuteRepeatEiq) && ((chuteSupposer * 3.175) >= 3)) {
            newChute = chuteRepeatEiq;
            repIdeal = repeat;
            nbrPose = pose;
            hautFinal = newHauteur;
          }
        }
      }
      
      var chainage = 0.0;
      if (nbrPose != null && nbrPose > 0) {
         chainage = ((newChute * 3.175) / nbrPose) + hauteurChain;
      }
      
      poseParRepeat = nbrPose ?? 0;
      return [hautFinal, repIdeal, nbrPose, chainage.toStringAsFixed(4)];
    }
    return [];
  }

  /// calcLaize est une meilleur approche
  /// pour calculer la laize plus rapidement
  /// elle exige un parametre Largeur int
  /// et retourne une liste
  /// [laize, piste , chute]
  List<int> calcLaize(int largeur,
      {int largeurChainage = 3,
      String machine = "Weigang",
      int spot = 3,
      int gb = 4,
      int lzBobM = 1000}) {
    
    int maxLaize;
    // ignore: unused_local_variable
    int bestChute;
    // ignore: unused_local_variable
    int bestLaizeSupport = 0;

    switch (machine) {
      case "Weigang":
      case "sleeve":
      case "bopp":
        maxLaize = 450;
        bestChute = 450;
        bestLaizeSupport = 450;
        break;
      case "edale":
        maxLaize = 240;
        bestChute = 240;
        bestLaizeSupport = 240;
        break;
      default:
        maxLaize = 450;
        bestChute = 450;
        bestLaizeSupport = 450;
        break;
    }

    var largeurPiste = largeur + largeurChainage;
    if (largeurPiste == 0) return [0, 0, lzBobM];

    int maxPiste = (maxLaize / largeurPiste).floor();
    int lzPossible;
    int chutePossible;
    int chuteIdeal = lzBobM;
    int lzIdeal = 0;
    int pisteIdeal = 0;

    for (var piste = maxPiste; piste >= 1; piste--) {
      lzPossible = ((piste * largeurPiste) + (gb + spot)).round();
      chutePossible = lzBobM % lzPossible;
      if (chuteIdeal > chutePossible) {
        lzIdeal = lzPossible;
        chuteIdeal = chutePossible;
        pisteIdeal = piste;
      }
    }
    poseParLaize = pisteIdeal;
    return [lzIdeal, pisteIdeal, chuteIdeal];
  }

  /// Calcule le métrage nécessaire pour une commande donnée
  static double calculateMetrageRequired(int repeat, int pose, int commande) {
    if (repeat <= 0 || pose <= 0 || commande <= 0) return 0;
    // Circonférence en mm = repeat * 3.175 (1/8 inch)
    double circumference = repeat * 3.175;
    // Nombre de poses par mètre (ou par 1000mm ?)
    // La formule originale était: commande / (1000 / (repeat * 3.175) * pose)
    // 1000 / circumference = nombre de tours par mètre (si circumference en mm)
    // * pose = nombre d'étiquettes par mètre
    double labelsPerMeter = (1000 / circumference) * pose;
    return (commande / labelsPerMeter).floor().toDouble();
  }

  /// Calcule le nombre d'étiquettes pour 1000m (ou une quantité donnée de métrage)
  static double calculateLabelsCount(int repeat, int pose, double metrage) {
    if (repeat <= 0 || pose <= 0 || metrage <= 0) return 0;
    double circumference = repeat * 3.175;
    double labelsPerMeter = (1000 / circumference) * pose;
    return (labelsPerMeter * metrage).floor().toDouble();
  }

  /// Calcule le nombre de bobines filles et la chute
  static List<int> calculateCuts(int motherWidth, int daughterWidth) {
    if (daughterWidth <= 0 || motherWidth <= 0) return [0, 0];
    int nbrBobF = motherWidth ~/ daughterWidth;
    int chute = motherWidth % daughterWidth;
    return [nbrBobF, chute];
  }

  /// Calcule le prix de revient de l'étiquette
  static double calculateCostPrice({
    required double prixSupportM2,
    required int lzBobMer,
    required int etiqBobMere,
    required bool inclureChute,
    required int chutteBobMere,
  }) {
    if (etiqBobMere <= 0) return 0;
    
    if (inclureChute) {
      return (prixSupportM2 * lzBobMer) / etiqBobMere;
    } else {
      double prixSupportSansChutte = (prixSupportM2 * (lzBobMer - chutteBobMere));
      return prixSupportSansChutte / etiqBobMere;
    }
  }

  // TODO : calculer nombre de Etiquette par Bobine Mere
  List<int> nbEtiquetParBobMere() {
    int poseDevloppement = poseParLaize * poseParRepeat;
    
    // Utilise la largeur de l'instance, convertie en int (ou 100 par défaut si null/0)
    int largeurInt = (largeur ?? 100).toInt();
    if (largeurInt == 0) largeurInt = 100;

    var laizeResult = calcLaize(largeurInt, lzBobM: bobM);
    int bobFille = 0;
    if (laizeResult[0] > 0) {
        bobFille = bobM ~/ laizeResult[0];
    }

    return [bobFille, poseDevloppement];
  }

  // TODO: Calcule Prix revien
  void calcPrixRevientEtiquette(double hauteur, double largeur, double prixSupport) {
    calcLaize(largeur.toInt());
    calcRepeatIntelligent(hauteur);
  }
}
