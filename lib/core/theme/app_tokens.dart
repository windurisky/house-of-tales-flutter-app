import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  static const bgBase = Color(0xFFFDFBF7);
  static const bgReaderPaper = Color(0xFFFFF7EA);
  static const surfaceCard = Color(0xFFFFFFFF);
  static const surfaceParchment = Color(0xFFFFEED3);
  static const brandPrimary = Color(0xFF1A3C40);
  static const brandSoft = Color(0xFFA8E6CF);
  static const brandSoftDark = Color(0xFF52D09B);
  static const actionPrimary = Color(0xFFFF8B3D);
  static const actionPrimaryPressed = Color(0xFFE86A1C);
  static const actionPrimarySoft = Color(0xFFFFE8D6);
  static const accentMagic = Color(0xFF7A5CFF);
  static const textPrimary = Color(0xFF1A3C40);
  static const textReader = Color(0xFF2B241F);
  static const textSecondary = Color(0xFF6B8E92);
  static const textInverse = Color(0xFFFFFFFF);
  static const borderSubtle = Color(0xFFF5F3EF);
  static const borderDefault = Color(0xFFE8E5E0);
  static const overlayScrim = Color(0x801A3C40);
  static const success = Color(0xFF52D09B);
  static const warning = Color(0xFFF5A623);
  static const error = Color(0xFFE85D5D);
  static const info = Color(0xFF5BA4CF);
}

class AppSpacing {
  const AppSpacing._();
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const page = 20.0;
}

class AppRadii {
  const AppRadii._();
  static const sm = 12.0;
  static const md = 18.0;
  static const lg = 24.0;
  static const xl = 32.0;
}

class AppMotion {
  const AppMotion._();
  static const quick = Duration(milliseconds: 160);
  static const pageTurn = Duration(milliseconds: 220);
}
