import 'package:flutter/widgets.dart';


class LazyLoadScrollController {
  LazyLoadScrollController({
    required this.controller,
    required this.onLoadMore,
    this.threshold = 300,
  }) {
    controller.addListener(_listener);
  }

  final ScrollController controller;
  final VoidCallback onLoadMore;
  final double threshold;

  void _listener() {
    if (!controller.hasClients) return;
    final position = controller.position;
    if (position.pixels >= position.maxScrollExtent - threshold) {
      onLoadMore();
    }
  }

  void dispose() => controller.removeListener(_listener);
}
