/// Spacing scale, copied from the `spacing` block in the tailwind config
/// shared by all four mockups (values are in logical pixels == the
/// original px values, since the mockups target mobile web at 1x).
class AppSpacing {
  AppSpacing._();

  static const base = 4.0;
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const marginMobile = 16.0;
  static const lg = 24.0;
  static const gutter = 24.0;
  static const xl = 32.0;
  static const xxl = 48.0;
  static const marginDesktop = 40.0;
}

/// Radius scale, copied from the `borderRadius` block. The HTML also uses
/// a couple of one-off values (rounded-2xl / rounded-3xl on doctor-list)
/// which aren't in the shared config but are included here for parity.
class AppRadius {
  AppRadius._();

  static const xs = 4.0; // DEFAULT / rounded
  static const lg = 8.0;
  static const xl = 12.0;
  static const xxl = 16.0; // rounded-2xl
  static const xxxl = 24.0; // rounded-3xl
  static const full = 999.0;
}
