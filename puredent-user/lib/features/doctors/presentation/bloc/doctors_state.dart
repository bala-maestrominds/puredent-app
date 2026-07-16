part of 'doctors_bloc.dart';

enum DoctorsStatus { initial, loading, success, failure }

class DoctorsState extends Equatable {
  final DoctorsStatus status;
  final List<DoctorEntity> allDoctors;
  final List<DoctorEntity> filteredDoctors;
  final String query;
  final int visibleCount;
  final Failure? failure;

  const DoctorsState({
    this.status = DoctorsStatus.initial,
    this.allDoctors = const [],
    this.filteredDoctors = const [],
    this.query = '',
    this.visibleCount = 0,
    this.failure,
  });

  List<DoctorEntity> get visibleDoctors => filteredDoctors.take(visibleCount).toList();
  bool get hasMore => visibleCount < filteredDoctors.length;

  DoctorsState copyWith({
    DoctorsStatus? status,
    List<DoctorEntity>? allDoctors,
    List<DoctorEntity>? filteredDoctors,
    String? query,
    int? visibleCount,
    Failure? failure,
  }) {
    return DoctorsState(
      status: status ?? this.status,
      allDoctors: allDoctors ?? this.allDoctors,
      filteredDoctors: filteredDoctors ?? this.filteredDoctors,
      query: query ?? this.query,
      visibleCount: visibleCount ?? this.visibleCount,
      failure: failure,
    );
  }

  @override
  List<Object?> get props => [status, allDoctors, filteredDoctors, query, visibleCount, failure];
}
