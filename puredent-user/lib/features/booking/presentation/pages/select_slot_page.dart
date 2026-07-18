import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../doctors/domain/repositories/doctors_repository.dart';
import '../bloc/booking_bloc.dart';

class SelectSlotPage extends StatefulWidget {
  const SelectSlotPage({super.key});

  @override
  State<SelectSlotPage> createState() => _SelectSlotPageState();
}

class _SelectSlotPageState extends State<SelectSlotPage> {
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String? _selectedTime;
  List<String> _slots = [];
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchSlots();
  }

  Future<void> _fetchSlots() async {
    setState(() {
      _loading = true;
      _error = null;
      _selectedTime = null;
    });

    final doctorId = context.read<BookingBloc>().state.doctorId!;
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final result = await getIt<DoctorsRepository>().getAvailability(doctorId, dateStr);

    if (!mounted) return;
    result.when(
      success: (slots) => setState(() {
        _slots = _filterPastSlots(slots);
        _loading = false;
      }),
      failure: (f) => setState(() {
        _error = f.message;
        _loading = false;
      }),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
      _fetchSlots();
    }
  }

  void _continue() {
    if (_selectedTime == null) return;
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    context.read<BookingBloc>().add(BookingSlotSelected(date: dateStr, time: _selectedTime!));
    context.push('/booking/patient-details');
  }

  @override
  Widget build(BuildContext context) {
    final booking = context.watch<BookingBloc>().state;

    return Scaffold(
      appBar: AppBar(title: const Text('Select Appointment Slot')),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.marginMobile),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${booking.doctorName} · ${booking.serviceName}', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: AppSpacing.lg),
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded, size: 18, color: AppColors.primary),
                    const SizedBox(width: 10),
                    Text(DateFormat('EEEE, MMM d, yyyy').format(_selectedDate), style: Theme.of(context).textTheme.bodyLarge),
                    const Spacer(),
                    const Icon(Icons.chevron_right_rounded, color: AppColors.outline),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Available Times', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: AppSpacing.md),
            Expanded(child: _buildSlots()),
            const SizedBox(height: AppSpacing.md),
            AppPrimaryButton(label: 'Continue', onPressed: _selectedTime == null ? null : _continue),
          ],
        ),
      ),
    );
  }

  Widget _buildSlots() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            OutlinedButton(onPressed: _fetchSlots, child: const Text('Retry')),
          ],
        ),
      );
    }
    if (_slots.isEmpty) {
      return const Center(child: Text('No available slots for this date. Try another day.'));
    }
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 2.2,
      ),
      itemCount: _slots.length,
      itemBuilder: (context, index) {
        final slot = _slots[index];
        final selected = slot == _selectedTime;
        return ChoiceChip(
          label: Text(_formatTime(slot)),
          selected: selected,
          onSelected: (_) => setState(() => _selectedTime = slot),
          selectedColor: AppColors.primary,
          labelStyle: TextStyle(color: selected ? Colors.white : AppColors.onSurface, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.base)),
        );
      },
    );
  }


  List<String> _filterPastSlots(List<String> slots) {
    final now = DateTime.now();
    final isToday = _selectedDate.year == now.year &&
        _selectedDate.month == now.month &&
        _selectedDate.day == now.day;
    if (!isToday) return slots;

    return slots.where((slot) {
      final parts = slot.split(':');
      final slotMinutes = int.parse(parts[0]) * 60 + int.parse(parts[1]);
      final nowMinutes = now.hour * 60 + now.minute;
      return slotMinutes > nowMinutes;
    }).toList();
  }

  String _formatTime(String hhmm) {
    final parts = hhmm.split(':');
    final hour = int.parse(parts[0]);
    final minute = parts[1];
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;
    return '$displayHour:$minute $period';
  }
}