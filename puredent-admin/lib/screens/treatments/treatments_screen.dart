import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/models/clinic_service.dart';
import '../../core/services/api_client.dart';
import '../../core/services/services_api_service.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/admin_page_scaffold.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/staggered_fade_in.dart';

class TreatmentsScreen extends StatefulWidget {
  const TreatmentsScreen({super.key});

  @override
  State<TreatmentsScreen> createState() => _TreatmentsScreenState();
}

class _TreatmentsScreenState extends State<TreatmentsScreen> {
  String _category = 'All';
  late Future<List<ClinicService>> _future;

  @override
  void initState() {
    super.initState();
    _future = ServicesApiService.instance.list();
  }

  Future<void> _refresh() async {
    final future = ServicesApiService.instance.list();
    setState(() => _future = future);
    await future;
  }

  Future<void> _openForm({ClinicService? existing}) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ServiceFormSheet(existing: existing),
    );
    if (saved == true) _refresh();
  }

  Future<void> _confirmDelete(ClinicService service) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Remove treatment?'),
        content: Text('"${service.name}" will no longer be bookable on the website.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        await ServicesApiService.instance.delete(service.id);
        if (!mounted) return;
        Navigator.pop(context); // close detail sheet if open
        _refresh();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminPageScaffold(
      title: 'Treatments',
      subtitle: 'Services offered at the clinic',
      action: IconButton(
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add_circle_rounded, color: AppColors.primary, size: 28),
      ),
      child: FutureBuilder<List<ClinicService>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _ErrorState(message: '${snapshot.error}', onRetry: _refresh);
          }
          final all = snapshot.data ?? const [];
          final categories = ['All', ...{for (final s in all) s.category}];
          if (!categories.contains(_category)) _category = 'All';
          final filtered = _category == 'All' ? all : all.where((t) => t.category == _category).toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final c = categories[index];
                    final selected = _category == c;
                    return GestureDetector(
                      onTap: () => setState(() => _category = c),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: selected ? AppColors.primary : AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          c,
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: selected ? Colors.white : AppColors.onSurfaceVariant),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: filtered.isEmpty
                    ? Center(child: Text('No treatments yet.', style: Theme.of(context).textTheme.bodyMedium))
                    : RefreshIndicator(
                        color: AppColors.primary,
                        onRefresh: _refresh,
                        child: GridView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                          itemCount: filtered.length,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 14,
                            crossAxisSpacing: 14,
                            childAspectRatio: 0.85,
                          ),
                          itemBuilder: (context, index) {
                            final t = filtered[index];
                            return StaggeredFadeIn(
                              index: index,
                              child: GestureDetector(
                                onLongPress: () => _confirmDelete(t),
                                onTap: () => _openForm(existing: t),
                                child: GlassCard(
                                  padding: const EdgeInsets.all(14),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                                            child: Icon(t.icon, color: AppColors.primary, size: 22),
                                          ),
                                          if (!t.isActive)
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(color: AppColors.errorContainer.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(999)),
                                              child: const Text('Inactive', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700)),
                                            ),
                                        ],
                                      ),
                                      const Spacer(),
                                      Text(t.name, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 14), maxLines: 2, overflow: TextOverflow.ellipsis),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(Icons.schedule_rounded, size: 13, color: AppColors.onSurfaceVariant),
                                          const SizedBox(width: 4),
                                          Text('${t.durationMinutes} min', style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        t.priceFrom != null ? '₹${t.priceFrom}' : 'Ask clinic',
                                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.primary),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded, color: AppColors.outline, size: 40),
            const SizedBox(height: 12),
            Text('Could not load treatments', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12)),
            const SizedBox(height: 16),
            OutlinedButton.icon(onPressed: onRetry, icon: const Icon(Icons.refresh_rounded), label: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

class _ServiceFormSheet extends StatefulWidget {
  final ClinicService? existing;
  const _ServiceFormSheet({this.existing});

  @override
  State<_ServiceFormSheet> createState() => _ServiceFormSheetState();
}

class _ServiceFormSheetState extends State<_ServiceFormSheet> {
  late final _nameController = TextEditingController(text: widget.existing?.name ?? '');
  late final _categoryController = TextEditingController(text: widget.existing?.category ?? 'General');
  late final _shortDescController = TextEditingController(text: widget.existing?.shortDescription ?? '');
  late final _descController = TextEditingController(text: widget.existing?.description ?? '');
  late final _priceController = TextEditingController(text: widget.existing?.priceFrom?.toString() ?? '');
  late final _durationController = TextEditingController(text: widget.existing?.durationMinutes.toString() ?? '30');
  late bool _isActive = widget.existing?.isActive ?? true;

  XFile? _image;
  bool _isSubmitting = false;
  String? _error;

  bool get _isEditing => widget.existing != null;

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _shortDescController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery, maxWidth: 1200, imageQuality: 85);
    if (file != null) setState(() => _image = file);
  }

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty || _durationController.text.trim().isEmpty) {
      setState(() => _error = 'Name and duration are required.');
      return;
    }
    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    try {
      if (_isEditing) {
        await ServicesApiService.instance.update(
          widget.existing!.id,
          name: _nameController.text.trim(),
          category: _categoryController.text.trim(),
          shortDescription: _shortDescController.text.trim(),
          description: _descController.text.trim(),
          priceFrom: num.tryParse(_priceController.text.trim()),
          durationMinutes: int.tryParse(_durationController.text.trim()) ?? 30,
          isActive: _isActive,
          imagePath: _image?.path,
        );
      } else {
        await ServicesApiService.instance.create(
          name: _nameController.text.trim(),
          category: _categoryController.text.trim().isEmpty ? 'General' : _categoryController.text.trim(),
          shortDescription: _shortDescController.text.trim(),
          description: _descController.text.trim(),
          priceFrom: num.tryParse(_priceController.text.trim()),
          durationMinutes: int.tryParse(_durationController.text.trim()) ?? 30,
          imagePath: _image?.path,
        );
      }
      if (!mounted) return;
      Navigator.pop(context, true);
    } on ApiException catch (e) {
      setState(() {
        _isSubmitting = false;
        _error = e.message;
      });
    } catch (e) {
      setState(() {
        _isSubmitting = false;
        _error = '$e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: ListView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: AppColors.outlineVariant, borderRadius: BorderRadius.circular(999)),
              ),
            ),
            const SizedBox(height: 16),
            Text(_isEditing ? 'Edit Treatment' : 'Add Treatment', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 20),
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.outlineVariant, width: 2),
                    image: _image != null
                        ? DecorationImage(image: FileImage(File(_image!.path)), fit: BoxFit.cover)
                        : (widget.existing?.resolvedImageUrl.isNotEmpty ?? false)
                            ? DecorationImage(image: NetworkImage(widget.existing!.resolvedImageUrl), fit: BoxFit.cover)
                            : null,
                  ),
                  child: _image == null && (widget.existing?.resolvedImageUrl.isEmpty ?? true)
                      ? const Icon(Icons.add_photo_alternate_outlined, color: AppColors.outline, size: 30)
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 20),
            _label('Name'),
            TextField(controller: _nameController, decoration: const InputDecoration(hintText: 'Teeth Whitening')),
            const SizedBox(height: 16),
            _label('Category'),
            TextField(controller: _categoryController, decoration: const InputDecoration(hintText: 'Cosmetic')),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('Price (₹)'),
                      TextField(
                        controller: _priceController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(hintText: '350'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('Duration (min)'),
                      TextField(
                        controller: _durationController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(hintText: '60'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _label('Short Description'),
            TextField(controller: _shortDescController, decoration: const InputDecoration(hintText: 'One-line summary shown in listings')),
            const SizedBox(height: 16),
            _label('Full Description'),
            TextField(controller: _descController, maxLines: 4, decoration: const InputDecoration(hintText: 'Details shown on the service page...')),
            if (_isEditing) ...[
              const SizedBox(height: 16),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Active (bookable on website)'),
                value: _isActive,
                onChanged: (v) => setState(() => _isActive = v),
                activeTrackColor: AppColors.primary,
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(color: AppColors.errorContainer.withValues(alpha: 0.4), borderRadius: BorderRadius.circular(12)),
                child: Text(_error!, style: const TextStyle(color: AppColors.error, fontSize: 13)),
              ),
            ],
            const SizedBox(height: 24),
            Row(
              children: [
                if (_isEditing) ...[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isSubmitting
                          ? null
                          : () async {
                              Navigator.pop(context); // close sheet first
                              // Parent list handles the confirm+delete flow via long-press,
                              // but from here we just close so they can long-press the card.
                            },
                      label: const Text('Cancel', style: TextStyle(color: AppColors.error, fontSize: 14)),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: _isSubmitting ? null : _save,
                    icon: _isSubmitting
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.check_rounded, size: 18),
                    label: Text(_isSubmitting ? 'Saving...' : 'Save Treatment'),
                  ),
                ),
              ],
            ),
            if (_isEditing) ...[
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Tip: long-press a treatment card in the list to remove it.',
                  style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant)),
      );
}
