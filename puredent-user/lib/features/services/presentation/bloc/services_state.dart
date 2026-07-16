part of 'services_bloc.dart';

enum ServicesStatus { initial, loading, success, failure }

class ServicesState extends Equatable {
  final ServicesStatus status;
  final List<ServiceEntity> allServices;
  final List<ServiceEntity> filteredServices;
  final List<String> categories;
  final String query;
  final String? category;
  final int visibleCount;
  final Failure? failure;

  const ServicesState({
    this.status = ServicesStatus.initial,
    this.allServices = const [],
    this.filteredServices = const [],
    this.categories = const ['All'],
    this.query = '',
    this.category = 'All',
    this.visibleCount = 0,
    this.failure,
  });

  List<ServiceEntity> get visibleServices => filteredServices.take(visibleCount).toList();
  bool get hasMore => visibleCount < filteredServices.length;

  ServicesState copyWith({
    ServicesStatus? status,
    List<ServiceEntity>? allServices,
    List<ServiceEntity>? filteredServices,
    List<String>? categories,
    String? query,
    String? category,
    int? visibleCount,
    Failure? failure,
  }) {
    return ServicesState(
      status: status ?? this.status,
      allServices: allServices ?? this.allServices,
      filteredServices: filteredServices ?? this.filteredServices,
      categories: categories ?? this.categories,
      query: query ?? this.query,
      category: category ?? this.category,
      visibleCount: visibleCount ?? this.visibleCount,
      failure: failure,
    );
  }

  @override
  List<Object?> get props =>
      [status, allServices, filteredServices, categories, query, category, visibleCount, failure];
}
