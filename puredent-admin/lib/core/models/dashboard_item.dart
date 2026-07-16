import 'package:flutter/material.dart';

/// Describes one tile in the dashboard's icon grid (the IndOasis-style
/// layout), replacing the website's sidebar navigation.
class DashboardItem {
  final String label;
  final IconData icon;
  final Color color;
  final Widget Function() screenBuilder;

  const DashboardItem({
    required this.label,
    required this.icon,
    required this.color,
    required this.screenBuilder,
  });
}