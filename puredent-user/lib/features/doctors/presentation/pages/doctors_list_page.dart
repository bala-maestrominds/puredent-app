import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/debounced_search_field.dart';
import '../../../../core/widgets/lazy_load_scroll_controller.dart';
import '../bloc/doctors_bloc.dart';
import '../widgets/doctor_card.dart';

class DoctorsListPage extends StatelessWidget {
  const DoctorsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<DoctorsBloc>()..add(const DoctorsFetchRequested()),
      child: const _DoctorsListView(),
    );
  }
}

class _DoctorsListView extends StatefulWidget {
  const _DoctorsListView();

  @override
  State<_DoctorsListView> createState() => _DoctorsListViewState();
}

class _DoctorsListViewState extends State<_DoctorsListView> {
  final _scrollController = ScrollController();
  late final LazyLoadScrollController _lazyLoad;

  @override
  void initState() {
    super.initState();
    _lazyLoad = LazyLoadScrollController(
      controller: _scrollController,
      onLoadMore: () => context.read<DoctorsBloc>().add(const DoctorsLoadMoreRequested()),
    );
  }

  @override
  void dispose() {
    _lazyLoad.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Our Doctors')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.marginMobile),
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.sm),
            DebouncedSearchField(
              hint: 'Search doctors or specialty…',
              onChanged: (query) => context.read<DoctorsBloc>().add(DoctorsSearchChanged(query)),
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: BlocBuilder<DoctorsBloc, DoctorsState>(
                builder: (context, state) {
                  if (state.status == DoctorsStatus.loading) {
                    return const _DoctorListSkeleton();
                  }
                  if (state.status == DoctorsStatus.failure) {
                    return _ErrorView(
                      message: state.failure?.message ?? 'Failed to load doctors',
                      onRetry: () => context.read<DoctorsBloc>().add(const DoctorsFetchRequested()),
                    );
                  }
                  if (state.visibleDoctors.isEmpty) {
                    return const Center(child: Text('No doctors found'));
                  }
                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<DoctorsBloc>().add(const DoctorsRefreshRequested());
                      await Future.delayed(const Duration(milliseconds: 400));
                    },
                    child: ListView.separated(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: state.visibleDoctors.length + (state.hasMore ? 1 : 0),
                      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (context, index) {
                        if (index >= state.visibleDoctors.length) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                          );
                        }
                        final doctor = state.visibleDoctors[index];
                        return DoctorCard(
                          doctor: doctor,
                          onTap: () => context.push('/doctors/${doctor.id}'),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DoctorListSkeleton extends StatelessWidget {
  const _DoctorListSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: 6,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: AppColors.surfaceContainerHigh,
        highlightColor: AppColors.surfaceContainerLowest,
        child: Container(
          height: 96,
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.wifi_off_rounded, size: 40, color: AppColors.outline),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
