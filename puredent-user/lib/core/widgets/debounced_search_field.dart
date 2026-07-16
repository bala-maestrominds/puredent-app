import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../utils/app_config.dart';
import '../utils/debouncer.dart';

/// Search field that only calls [onChanged] after the user has paused
/// typing for [AppConfig.searchDebounce] — prevents firing a filter/rebuild
/// (or a network call, if the backend later grows server-side search) on
/// every keystroke.
class DebouncedSearchField extends StatefulWidget {
  const DebouncedSearchField({super.key, required this.hint, required this.onChanged});

  final String hint;
  final void Function(String query) onChanged;

  @override
  State<DebouncedSearchField> createState() => _DebouncedSearchFieldState();
}

class _DebouncedSearchFieldState extends State<DebouncedSearchField> {
  late final Debouncer _debouncer = Debouncer(delay: AppConfig.searchDebounce);
  final _controller = TextEditingController();

  @override
  void dispose() {
    _debouncer.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: (value) => _debouncer.run(() => widget.onChanged(value)),
      decoration: InputDecoration(
        hintText: widget.hint,
        prefixIcon: const Icon(Icons.search_rounded, size: 20, color: AppColors.outline),
        suffixIcon: ValueListenableBuilder(
          valueListenable: _controller,
          builder: (context, value, _) {
            if (value.text.isEmpty) return const SizedBox.shrink();
            return IconButton(
              icon: const Icon(Icons.close_rounded, size: 18),
              onPressed: () {
                _controller.clear();
                _debouncer.cancel();
                widget.onChanged('');
              },
            );
          },
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: AppSpacing.md),
      ),
    );
  }
}
