import 'package:flutter/material.dart';

/// Système responsive centralisé
/// Utilisation : Responsive.of(context).fontSize(16)
class Responsive {
  final BuildContext context;
  late final Size screenSize;
  late final double screenWidth;
  late final double screenHeight;
  late final bool isMobile;
  late final bool isTablet;
  late final bool isDesktop;
  late final double scale;

  Responsive(this.context) {
    screenSize = MediaQuery.of(context).size;
    screenWidth = screenSize.width;
    screenHeight = screenSize.height;
    isMobile = screenWidth < 600;
    isTablet = screenWidth >= 600 && screenWidth < 1024;
    isDesktop = screenWidth >= 1024;

    // Facteur d'échelle : 1.0 sur mobile, plus grand sur tablette/desktop
    if (isMobile) {
      scale = 1.0;
    } else if (isTablet) {
      scale = 1.15;
    } else {
      scale = 1.3;
    }
  }

  static Responsive of(BuildContext context) => Responsive(context);

  /// Taille de police adaptative
  double fontSize(double base) => base * scale;

  /// Espacement adaptatif (padding, margin)
  double space(double base) => base * scale;

  /// Nombre de colonnes pour une grille de produits
  int get gridColumns {
    if (screenWidth < 400) return 2;       // Petit téléphone
    if (screenWidth < 600) return 2;       // Téléphone
    if (screenWidth < 900) return 3;       // Tablette portrait
    if (screenWidth < 1200) return 4;      // Tablette paysage / petit PC
    if (screenWidth < 1600) return 5;      // PC moyen
    return 6;                               // Grand écran
  }

  /// Ratio des cartes produits (largeur / hauteur)
  double get cardAspectRatio {
    if (isMobile) return 0.68;
    if (isTablet) return 0.72;
    return 0.75;
  }

  /// Largeur max du contenu (pour éviter que le contenu soit étiré sur grand écran)
  double get maxContentWidth {
    if (isMobile) return screenWidth;
    if (isTablet) return 900;
    return 1200;
  }

  /// Hauteur d'une bannière
  double get bannerHeight {
    if (isMobile) return 170;
    if (isTablet) return 220;
    return 280;
  }

  /// Largeur du drawer (menu latéral)
  double get drawerWidth {
    if (isMobile) return screenWidth * 0.75;
    return 320;
  }
}

/// Widget utilitaire pour centrer et limiter la largeur du contenu sur grand écran
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double? maxWidth;
  final EdgeInsets? padding;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth ?? r.maxContentWidth),
        child: Padding(
          padding: padding ?? EdgeInsets.zero,
          child: child,
        ),
      ),
    );
  }
}
