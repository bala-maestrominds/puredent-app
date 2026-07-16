part of 'doctors_bloc.dart';

sealed class DoctorsEvent extends Equatable {
  const DoctorsEvent();
  @override
  List<Object?> get props => [];
}

class DoctorsFetchRequested extends DoctorsEvent {
  const DoctorsFetchRequested();
}

class DoctorsRefreshRequested extends DoctorsEvent {
  const DoctorsRefreshRequested();
}

/// Dispatched by the search field *after* it has already been debounced.
class DoctorsSearchChanged extends DoctorsEvent {
  final String query;
  const DoctorsSearchChanged(this.query);
  @override
  List<Object?> get props => [query];
}

/// Dispatched when the list scrolls near the bottom (lazy loading).
class DoctorsLoadMoreRequested extends DoctorsEvent {
  const DoctorsLoadMoreRequested();
}
