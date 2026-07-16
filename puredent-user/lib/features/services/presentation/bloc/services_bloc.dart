import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/utils/app_config.dart';
import '../../domain/entities/service_entity.dart';
import '../../domain/repositories/services_repository.dart';

part 'services_event.dart';
part 'services_state.dart';

/// Mirrors [DoctorsBloc]'s approach: fetch-once + cache, client-side
/// debounced search, and paged reveal for lazy `ListView` rendering.
class ServicesBloc extends Bloc<ServicesEvent, ServicesState> {
  ServicesBloc({required ServicesRepository repository})
      : _repository = repository,
        super(const ServicesState()) {
    on<ServicesFetchRequested>(_onFetchRequested);
    on<ServicesSearchChanged>(_onSearchChanged);
    on<ServicesCategoryChanged>(_onCategoryChanged);
    on<ServicesLoadMoreRequested>(_onLoadMoreRequested);
    on<ServicesRefreshRequested>(_onRefreshRequested);
  }

  final ServicesRepository _repository;

  Future<void> _onFetchRequested(ServicesFetchRequested event, Emitter<ServicesState> emit) async {
    emit(state.copyWith(status: ServicesStatus.loading));
    final result = await _repository.getServices();
    result.when(
      success: (services) => emit(_buildPagedState(all: services, query: state.query, category: state.category)),
      failure: (f) => emit(state.copyWith(status: ServicesStatus.failure, failure: f)),
    );
  }

  Future<void> _onRefreshRequested(ServicesRefreshRequested event, Emitter<ServicesState> emit) async {
    final result = await _repository.getServices(forceRefresh: true);
    result.when(
      success: (services) => emit(_buildPagedState(all: services, query: state.query, category: state.category)),
      failure: (f) => emit(state.copyWith(status: ServicesStatus.failure, failure: f)),
    );
  }

  void _onSearchChanged(ServicesSearchChanged event, Emitter<ServicesState> emit) {
    emit(_buildPagedState(all: state.allServices, query: event.query, category: state.category));
  }

  void _onCategoryChanged(ServicesCategoryChanged event, Emitter<ServicesState> emit) {
    emit(_buildPagedState(all: state.allServices, query: state.query, category: event.category));
  }

  void _onLoadMoreRequested(ServicesLoadMoreRequested event, Emitter<ServicesState> emit) {
    if (state.visibleCount >= state.filteredServices.length) return;
    final nextCount = (state.visibleCount + AppConfig.pageSize).clamp(0, state.filteredServices.length);
    emit(state.copyWith(visibleCount: nextCount));
  }

  ServicesState _buildPagedState({
    required List<ServiceEntity> all,
    required String query,
    required String? category,
  }) {
    var filtered = all;
    if (category != null && category.isNotEmpty && category != 'All') {
      filtered = filtered.where((s) => s.category == category).toList();
    }
    if (query.trim().isNotEmpty) {
      final q = query.trim().toLowerCase();
      filtered = filtered
          .where((s) => s.name.toLowerCase().contains(q) || s.shortDescription.toLowerCase().contains(q))
          .toList();
    }

    final categories = <String>{'All', ...all.map((s) => s.category)}.toList();

    return state.copyWith(
      status: ServicesStatus.success,
      allServices: all,
      filteredServices: filtered,
      query: query,
      category: category,
      categories: categories,
      visibleCount: filtered.length.clamp(0, AppConfig.pageSize),
    );
  }
}
