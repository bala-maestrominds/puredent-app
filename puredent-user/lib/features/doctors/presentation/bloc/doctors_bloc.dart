import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/utils/app_config.dart';
import '../../domain/entities/doctor_entity.dart';
import '../../domain/repositories/doctors_repository.dart';

part 'doctors_event.dart';
part 'doctors_state.dart';

/// The backend returns the whole doctor list in one call (no server
/// pagination/search). To keep the UI fast and the list scrollable without
/// jank on hundreds of doctors, we:
///  - fetch once and cache (handled in the repository)
///  - filter client-side on debounced search text (debounce lives in the
///    search field widget, see [DoctorsSearchField])
///  - reveal results in pages of [AppConfig.pageSize] as the user scrolls,
///    so `ListView.builder` never has to lay out more than it needs to.
class DoctorsBloc extends Bloc<DoctorsEvent, DoctorsState> {
  DoctorsBloc({required DoctorsRepository repository})
      : _repository = repository,
        super(const DoctorsState()) {
    on<DoctorsFetchRequested>(_onFetchRequested);
    on<DoctorsSearchChanged>(_onSearchChanged);
    on<DoctorsLoadMoreRequested>(_onLoadMoreRequested);
    on<DoctorsRefreshRequested>(_onRefreshRequested);
  }

  final DoctorsRepository _repository;

  Future<void> _onFetchRequested(DoctorsFetchRequested event, Emitter<DoctorsState> emit) async {
    emit(state.copyWith(status: DoctorsStatus.loading));
    final result = await _repository.getDoctors();
    result.when(
      success: (doctors) => emit(_buildPagedState(all: doctors, query: state.query)),
      failure: (f) => emit(state.copyWith(status: DoctorsStatus.failure, failure: f)),
    );
  }

  Future<void> _onRefreshRequested(DoctorsRefreshRequested event, Emitter<DoctorsState> emit) async {
    final result = await _repository.getDoctors(forceRefresh: true);
    result.when(
      success: (doctors) => emit(_buildPagedState(all: doctors, query: state.query)),
      failure: (f) => emit(state.copyWith(status: DoctorsStatus.failure, failure: f)),
    );
  }

  void _onSearchChanged(DoctorsSearchChanged event, Emitter<DoctorsState> emit) {
    emit(_buildPagedState(all: state.allDoctors, query: event.query));
  }

  void _onLoadMoreRequested(DoctorsLoadMoreRequested event, Emitter<DoctorsState> emit) {
    if (state.visibleCount >= state.filteredDoctors.length) return;
    final nextCount = (state.visibleCount + AppConfig.pageSize).clamp(0, state.filteredDoctors.length);
    emit(state.copyWith(visibleCount: nextCount));
  }

  DoctorsState _buildPagedState({required List<DoctorEntity> all, required String query}) {
    final filtered = query.trim().isEmpty
        ? all
        : all.where((d) {
            final q = query.trim().toLowerCase();
            return d.name.toLowerCase().contains(q) || d.specialty.toLowerCase().contains(q);
          }).toList();

    return state.copyWith(
      status: DoctorsStatus.success,
      allDoctors: all,
      filteredDoctors: filtered,
      query: query,
      visibleCount: filtered.length.clamp(0, AppConfig.pageSize),
    );
  }
}
