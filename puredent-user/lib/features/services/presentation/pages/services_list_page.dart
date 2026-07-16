import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/debounced_search_field.dart';
import '../../../../core/widgets/lazy_load_scroll_controller.dart';
import '../bloc/services_bloc.dart';
import '../widgets/service_card.dart';

class ServicesListPage extends StatelessWidget {
  const ServicesListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ServicesBloc>()..add(const ServicesFetchRequested()),
      child: const _ServicesListView(),
    );
  }
}

class _ServicesListView extends StatefulWidget {
  const _ServicesListView();

  @override
  State<_ServicesListView> createState() => _ServicesListViewState();
}

class _ServicesListViewState extends State<_ServicesListView> {
  final _scrollController = ScrollController();
  late final LazyLoadScrollController _lazyLoad;

  @override
  void initState() {
    super.initState();
    _lazyLoad = LazyLoadScrollController(
      controller: _scrollController,
      onLoadMore: () => context.read<ServicesBloc>().add(const ServicesLoadMoreRequested()),
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
      appBar: AppBar(title: const Text('Our Services')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.marginMobile),
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.sm),
            DebouncedSearchField(
              hint: 'Search services…',
              onChanged: (query) => context.read<ServicesBloc>().add(ServicesSearchChanged(query)),
            ),
            const SizedBox(height: AppSpacing.sm),
            BlocBuilder<ServicesBloc, ServicesState>(
              buildWhen: (prev, curr) => prev.categories != curr.categories || prev.category != curr.category,
              builder: (context, state) {
                return SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: state.categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final category = state.categories[index];
                      final selected = category == state.category;
                      return ChoiceChip(
                        label: Text(category),
                        selected: selected,
                        onSelected: (_) => context.read<ServicesBloc>().add(ServicesCategoryChanged(category)),
                        selectedColor: AppColors.primaryContainer,
                        labelStyle: TextStyle(color: selected ? AppColors.onPrimaryContainer : AppColors.onSurfaceVariant),
                      );
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: BlocBuilder<ServicesBloc, ServicesState>(
                builder: (context, state) {
                  if (state.status == ServicesStatus.loading) {
                    return const _ServiceGridSkeleton();
                  }
                  if (state.status == ServicesStatus.failure) {
                    return Center(child: Text(state.failure?.message ?? 'Failed to load services'));
                  }
                  if (state.visibleServices.isEmpty) {
                    return const Center(child: Text('No services found'));
                  }
                  return RefreshIndicator(
                    onRefresh: () async => context.read<ServicesBloc>().add(const ServicesRefreshRequested()),
                    child: GridView.builder(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: AppSpacing.sm,
                        crossAxisSpacing: AppSpacing.sm,
                        childAspectRatio: 0.68,
                      ),
                      itemCount: state.visibleServices.length,
                      itemBuilder: (context, index) {
                        final service = state.visibleServices[index];
                        return ServiceCard(
                          service: service,
                          onTap: () => context.push('/services/${service.slug}'),
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

class _ServiceGridSkeleton extends StatelessWidget {
  const _ServiceGridSkeleton();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppSpacing.sm,
        crossAxisSpacing: AppSpacing.sm,
        childAspectRatio: 0.72,
      ),
      itemCount: 6,
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: AppColors.surfaceContainerHigh,
        highlightColor: AppColors.surfaceContainerLowest,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
        ),
      ),
    );
  }
}
