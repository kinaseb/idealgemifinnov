///Classe qui calcule laize et repeat de l'etiquette
///
class Etiquette {
  //variable d'instance
  double? hauteur = 0;
  double? largeur = 0;
  double? hauteurChain = 3;
  double? largeurChain = 3;
  int bobM = 1000;
  //variable de classe
  List<int> repWeigangEtiq = [85, 94, 112, 135];
  List<int> repWeigangSleeve = [76, 85, 94, 112, 135, 190];
  List<int> repEdale = [74, 85, 94, 115];
  int spot = 0;
  int poseParRepeat = 0;
  int poseParLaize = 0;
  var bobF = 0;

  Etiquette(
      {this.hauteur,
      this.largeur,
      this.hauteurChain = 3.0,
      this.largeurChain = 3.0,
      this.bobM = 1000}) {
    if (hauteur != null) {
      print("Hauteur : $hauteur");
    }
    // Constructeur de la classe Etiquette
  }
  Etiquette.weigang({
    this.hauteur,
    this.largeur = 0,
    this.hauteurChain = 0.0,
    this.largeurChain = 3.0,
    this.bobM = 1000,
  }) {
    //print(calc_Repeat(hauteur));
  }

  ///calc_Repeat est une meilleur approche
  ///pour calculer le repeat plus rapidement
  ///elle exige un parametre hauteur int
  ///et retourne une liste
  ///[repeat, Nbrpose , chainage]

  calc_repeat(hauteur, [hauteurChain = 0]) {
    ///lalalalala

    double procheH = 1000;
    double calcule = 0;

    if (hauteur != null) {
      int? repIdeal;
      var tabrepeat = [85, 94, 112, 135]; // test pour weigang etiquette
      int? nbrPose;
      double hauteurConvert =
          (hauteur! + hauteurChain!) / 3.175; //hauteur+chainage
      for (var element in tabrepeat) {
        calcule = (element) % (hauteurConvert);
        int pose = (element) ~/ (hauteurConvert);
        if (procheH > calcule) {
          procheH = calcule;
          repIdeal = element;
          nbrPose = pose;
        }
      }
      var chainage = (procheH * 3.175 + hauteurChain) / nbrPose!;

      return [repIdeal, nbrPose, chainage.toStringAsFixed(4)];
    }
  }

  ///nouvele calc repeat qui est iteligente elle prend comme parametre hauteur, [hauteurChain = 0, echelle = 5] echelle represente le maximum qu'on peux retricire la hauteur d'etiquette afin qu'elle s'adapte mieux avec nos jeux de repeat
  calc_Repeat_Inteligent(hauteur, [hauteurChain = 0, echelle = 5]) {
    double newChute = 1000;
    double chuteRepeatEiq = 0;

    if (hauteur != null) {
      int? repIdeal;
      var tabrepeat = [85, 94, 112, 135]; // test pour weigang etiquette
      int? nbrPose;
      int? hautFinal;
      //double hauteurConvert =(hauteur! + hauteurChain!) / 3.175; //hauteur+chainage en dent(2.54/8)
      for (var newHauteur = hauteur;
          newHauteur >= hauteur - echelle;
          newHauteur--) {
        double hauteurConvert = (newHauteur! + hauteurChain!) /
            3.175; //hauteur+chainage en dent(2.54/8)
        for (var repeat in tabrepeat) {
          chuteRepeatEiq = (repeat) % (hauteurConvert); //%modulo
          int pose = (repeat) ~/ (hauteurConvert); //~/ entier de la division)
          double chuteSupposer = (chuteRepeatEiq / pose) + hauteurChain;
          if ((newChute > chuteRepeatEiq) && ((chuteSupposer * 3.175) >= 3)) {
            newChute = chuteRepeatEiq;
            repIdeal = repeat;
            nbrPose = pose;
            hautFinal = newHauteur;
          }
        }
      }
      var chainage = ((newChute * 3.175) / nbrPose!) + hauteurChain;
      poseParRepeat = nbrPose;
      return [hautFinal, repIdeal, nbrPose, chainage.toStringAsFixed(4)];
    }
  }

  //TODO: Calcule laize
  //
  var lzPossible,
      etiqAndChainage,
      chuteSupportPossible,
      etiqParLz,
      lzSupportCalc,
      bestNbrEtiqLaize;

  ///calcLaize est une meilleur approche
  ///pour calculer la laize plus rapidement
  ///elle exige un parametre Largeur int
  ///et retourne une liste
  ///[laize, piste , chute]
  ///
  List<int> calcLaize(int largeur,
      {largeurChainage = 3,
      machine = "Weigang",
      spot = 3,
      gb = 4,
      lzBobM = 1000}) {
    /*
        nouvelle aproche 
        maxpiste = bobM/(hauteur+ chainage)
        je fais une boucle en ajoutant gb et spot et evantuellement moustach pour le sleeve
        ja cherche le moin de chutte 
        */
    int maxlaize, bestchute, bestLaizeSupport = 0;

    switch (machine) {
      case "Weigang":
        maxlaize = 450;
        bestchute = 450;
        bestLaizeSupport = 450;
        break;
      case "sleeve":
        maxlaize = 450;
        bestchute = 450;
        bestLaizeSupport = 450;
        break;
      case "bopp":
        maxlaize = 450;
        bestchute = 450;
        bestLaizeSupport = 450;
        break;
      case "edale":
        maxlaize = 240;
        bestchute = 240;
        bestLaizeSupport = 240;
        break;
      default:
        maxlaize = 450;
        bestchute = 450;
        bestLaizeSupport = 450;
        break;
    } //sw
    var largeurPiste = largeur + largeurChainage;

    int maxPiste = (maxlaize / largeurPiste).floor();
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

//TODO : calculer nombre de Etiquette par Bobine Mere

  List<int> nbEtiquetParBobMere(int lbob) {
    int poseDevloppement = poseParLaize * poseParRepeat;
    int bobFille = bobM ~/ calcLaize(100)[0];

    return [bobFille];
  }

// ignore: todo
//TODO: Calcule Prix revien
  calcPrixRevienEtiquette(int Hauteur, int Largeur, int PrixSupport) {
    calcLaize(Largeur);
    calc_Repeat_Inteligent(Hauteur);
  }
}
