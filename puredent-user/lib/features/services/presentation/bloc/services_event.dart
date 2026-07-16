part of 'services_bloc.dart';

sealed class ServicesEvent extends Equatable {
  const ServicesEvent();
  @override
  List<Object?> get props => [];
}

class ServicesFetchRequested extends ServicesEvent {
  const ServicesFetchRequested();
}

class ServicesRefreshRequested extends ServicesEvent {
  const ServicesRefreshRequested();
}

class ServicesSearchChanged extends ServicesEvent {
  final String query;
  const ServicesSearchChanged(this.query);
  @override
  List<Object?> get props => [query];
}

class ServicesCategoryChanged extends ServicesEvent {
  final String category;
  const ServicesCategoryChanged(this.category);
  @override
  List<Object?> get props => [category];
}

class ServicesLoadMoreRequested extends ServicesEvent {
  const ServicesLoadMoreRequested();
}
