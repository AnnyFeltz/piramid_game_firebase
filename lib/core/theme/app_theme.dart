import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  static const EdgeInsets paddingSm = EdgeInsets.all(sm);
  static const EdgeInsets paddingMd = EdgeInsets.all(md);
  static const EdgeInsets paddingLg = EdgeInsets.all(lg);
  static const EdgeInsets paddingXl = EdgeInsets.all(xl);
  static const EdgeInsets horizontalMd = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets verticalMd = EdgeInsets.symmetric(vertical: md);
}

class AppRadius {
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
}

extension TextStyleContext on BuildContext {
  TextTheme get textStyles => Theme.of(this).textTheme;
}

extension TextStyleExtensions on TextStyle {
  TextStyle get bold => copyWith(fontWeight: FontWeight.bold);
  TextStyle get semiBold => copyWith(fontWeight: FontWeight.w600);
  TextStyle get medium => copyWith(fontWeight: FontWeight.w500);
  TextStyle withColor(Color color) => copyWith(color: color);
  TextStyle withSize(double size) => copyWith(fontSize: size);
}

// =============================================================================
// PALETA — Lilás/Roxo + Azul Céu + Branco
// Lilás/roxo: primary, cards, appbar
// Azul céu:   secondary, botões de ação, destaques
// Branco:     fundos, superfícies, texto sobre cores escuras
// =============================================================================

class LightModeColors {
  // PRIMARY — Lilás médio (appbar, headers, chips primários)
  static const primary            = Color(0xFF7C5CBF); // lilás/roxo
  static const onPrimary          = Color(0xFFFFFFFF);
  static const primaryContainer   = Color(0xFFE8DEFF); // lilás bem claro
  static const onPrimaryContainer = Color(0xFF3A1F7A);

  // SECONDARY — Azul céu (FAB, botões de ação, ranking bar)
  static const secondary            = Color(0xFF4DA8DA); // azul céu
  static const onSecondary          = Color(0xFFFFFFFF);
  static const secondaryContainer   = Color(0xFFD6EFFF); // azul céu bem claro
  static const onSecondaryContainer = Color(0xFF0D3A52);

  // TERTIARY — Roxo escuro (acentos, badge Nível Lenda)
  static const tertiary            = Color(0xFF5C3D9E);
  static const onTertiary          = Color(0xFFFFFFFF);

  // SUPERFÍCIES — Branco e lilás quase branco
  static const background          = Color(0xFFF5F3FF); // branco com leve lilás
  static const surface             = Color(0xFFFFFFFF);
  static const surfaceVariant      = Color(0xFFEDE7FF); // lilás claro para cards
  static const onSurface           = Color(0xFF1C1B1F);
  static const onSurfaceVariant    = Color(0xFF49454F);

  // OUTLINE / ERRO
  static const outline             = Color(0xFFB0A8D4); // lilás acinzentado
  static const error               = Color(0xFFB3261E);
  static const onError             = Color(0xFFFFFFFF);
}

class DarkModeColors {
  // PRIMARY — Lilás claro sobre fundo escuro
  static const primary            = Color(0xFFCBB3FF); // lilás claro
  static const onPrimary          = Color(0xFF3A1F7A);
  static const primaryContainer   = Color(0xFF5C3D9E); // roxo médio
  static const onPrimaryContainer = Color(0xFFEADDFF);

  // SECONDARY — Azul céu claro
  static const secondary            = Color(0xFF82CFFF); // azul céu claro
  static const onSecondary          = Color(0xFF003549);
  static const secondaryContainer   = Color(0xFF004D6E);
  static const onSecondaryContainer = Color(0xFFCCE5FF);

  // TERTIARY
  static const tertiary            = Color(0xFFD4AAFF);
  static const onTertiary          = Color(0xFF2B0057);

  // SUPERFÍCIES — Escuro com toque de roxo
  static const surface             = Color(0xFF1A1625); // quase preto com toque roxo
  static const surfaceVariant      = Color(0xFF2C2542); // roxo bem escuro
  static const onSurface           = Color(0xFFE8E0F0);
  static const onSurfaceVariant    = Color(0xFFCBC4DC);

  // OUTLINE / ERRO
  static const outline             = Color(0xFF6C6484);
  static const error               = Color(0xFFF2B8B5);
  static const onError             = Color(0xFF601410);
}

// =============================================================================
// LIGHT THEME
// AppBar: azul céu  |  Cards/containers: lilás claro  |  FAB: lilás
// =============================================================================
ThemeData get lightTheme => ThemeData(
  useMaterial3: true,
  colorScheme: const ColorScheme.light(
    primary:              LightModeColors.primary,
    onPrimary:            LightModeColors.onPrimary,
    primaryContainer:     LightModeColors.primaryContainer,
    onPrimaryContainer:   LightModeColors.onPrimaryContainer,
    secondary:            LightModeColors.secondary,
    onSecondary:          LightModeColors.onSecondary,
    secondaryContainer:   LightModeColors.secondaryContainer,
    onSecondaryContainer: LightModeColors.onSecondaryContainer,
    tertiary:             LightModeColors.tertiary,
    onTertiary:           LightModeColors.onTertiary,
    surface:              LightModeColors.surface,
    onSurface:            LightModeColors.onSurface,
    surfaceContainerHighest: LightModeColors.surfaceVariant,
    onSurfaceVariant:     LightModeColors.onSurfaceVariant,
    outline:              LightModeColors.outline,
    error:                LightModeColors.error,
    onError:              LightModeColors.onError,
  ),
  scaffoldBackgroundColor: LightModeColors.background,

  // AppBar — azul céu
  appBarTheme: const AppBarTheme(
    backgroundColor: LightModeColors.secondary,
    foregroundColor: LightModeColors.onSecondary,
    elevation: 0,
    centerTitle: false,
  ),

  // Cards — fundo branco com borda lilás suave
  cardTheme: CardThemeData(
    color: LightModeColors.surface,
    elevation: 2,
    shadowColor: LightModeColors.primary.withValues(alpha: 0.15),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      side: const BorderSide(color: LightModeColors.primaryContainer, width: 1),
    ),
  ),

  // FAB — lilás
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: LightModeColors.primary,
    foregroundColor: LightModeColors.onPrimary,
  ),

  // FilledButton — azul céu
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      backgroundColor: LightModeColors.secondary,
      foregroundColor: LightModeColors.onSecondary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
    ),
  ),

  // Chips — lilás claro
  chipTheme: ChipThemeData(
    backgroundColor: LightModeColors.primaryContainer,
    labelStyle: const TextStyle(color: LightModeColors.onPrimaryContainer),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.sm),
    ),
  ),

  // InputDecoration
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.sm),
      borderSide: const BorderSide(color: LightModeColors.outline),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.sm),
      borderSide: const BorderSide(color: LightModeColors.primary, width: 2),
    ),
    labelStyle: const TextStyle(color: LightModeColors.primary),
    prefixIconColor: LightModeColors.secondary,
  ),

  textTheme: _buildTextTheme(),
);

// =============================================================================
// DARK THEME
// AppBar: roxo escuro  |  Cards: roxo bem escuro  |  FAB: azul céu
// =============================================================================
ThemeData get darkTheme => ThemeData(
  useMaterial3: true,
  colorScheme: const ColorScheme.dark(
    primary:              DarkModeColors.primary,
    onPrimary:            DarkModeColors.onPrimary,
    primaryContainer:     DarkModeColors.primaryContainer,
    onPrimaryContainer:   DarkModeColors.onPrimaryContainer,
    secondary:            DarkModeColors.secondary,
    onSecondary:          DarkModeColors.onSecondary,
    secondaryContainer:   DarkModeColors.secondaryContainer,
    onSecondaryContainer: DarkModeColors.onSecondaryContainer,
    tertiary:             DarkModeColors.tertiary,
    onTertiary:           DarkModeColors.onTertiary,
    surface:              DarkModeColors.surface,
    onSurface:            DarkModeColors.onSurface,
    surfaceContainerHighest: DarkModeColors.surfaceVariant,
    onSurfaceVariant:     DarkModeColors.onSurfaceVariant,
    outline:              DarkModeColors.outline,
    error:                DarkModeColors.error,
    onError:              DarkModeColors.onError,
  ),
  scaffoldBackgroundColor: DarkModeColors.surface,

  // AppBar — roxo escuro
  appBarTheme: const AppBarTheme(
    backgroundColor: DarkModeColors.primaryContainer,
    foregroundColor: DarkModeColors.onPrimaryContainer,
    elevation: 0,
    centerTitle: false,
  ),

  // Cards — roxo bem escuro
  cardTheme: CardThemeData(
    color: DarkModeColors.surfaceVariant,
    elevation: 4,
    shadowColor: Colors.black45,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      side: BorderSide(
          color: DarkModeColors.primary.withValues(alpha: 0.25), width: 1),
    ),
  ),

  // FAB — azul céu
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: DarkModeColors.secondary,
    foregroundColor: DarkModeColors.onSecondary,
  ),

  // FilledButton — lilás claro
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      backgroundColor: DarkModeColors.primary,
      foregroundColor: DarkModeColors.onPrimary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
    ),
  ),

  chipTheme: ChipThemeData(
    backgroundColor: DarkModeColors.primaryContainer,
    labelStyle: const TextStyle(color: DarkModeColors.onPrimaryContainer),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.sm),
    ),
  ),

  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.sm),
      borderSide: const BorderSide(color: DarkModeColors.outline),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.sm),
      borderSide: const BorderSide(color: DarkModeColors.primary, width: 2),
    ),
    labelStyle: const TextStyle(color: DarkModeColors.primary),
    prefixIconColor: DarkModeColors.secondary,
  ),

  textTheme: _buildTextTheme(),
);

TextTheme _buildTextTheme() => TextTheme(
  headlineLarge:  GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.w700),
  headlineMedium: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w600),
  headlineSmall:  GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w600),
  titleLarge:     GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w600),
  titleMedium:    GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
  titleSmall:     GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
  bodyLarge:      GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w400),
  bodyMedium:     GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400),
  bodySmall:      GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400),
  labelLarge:     GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
  labelMedium:    GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500),
  labelSmall:     GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500),
);