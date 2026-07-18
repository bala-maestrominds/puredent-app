import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import '../network/auth_event_bus.dart';
import '../network/dio_client.dart';
import '../storage/token_storage.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/doctors/data/datasources/doctors_remote_datasource.dart';
import '../../features/doctors/data/repositories/doctors_repository_impl.dart';
import '../../features/doctors/domain/repositories/doctors_repository.dart';
import '../../features/doctors/presentation/bloc/doctors_bloc.dart';
import '../../features/services/data/datasources/services_remote_datasource.dart';
import '../../features/services/data/repositories/services_repository_impl.dart';
import '../../features/services/domain/repositories/services_repository.dart';
import '../../features/services/presentation/bloc/services_bloc.dart';
import '../../features/booking/data/datasources/booking_remote_datasource.dart';
import '../../features/booking/data/repositories/booking_repository_impl.dart';
import '../../features/booking/domain/repositories/booking_repository.dart';
import '../../features/booking/presentation/bloc/booking_bloc.dart';
import '../../features/appointments/data/datasources/appointments_remote_datasource.dart';
import '../../features/appointments/data/repositories/appointments_repository_impl.dart';
import '../../features/appointments/domain/repositories/appointments_repository.dart';
import '../../features/appointments/presentation/bloc/appointments_bloc.dart';

final getIt = GetIt.instance;


Future<void> setupServiceLocator() async {
  // --- Core / infra ---
  getIt.registerLazySingleton<FlutterSecureStorage>(() => const FlutterSecureStorage());
  getIt.registerLazySingleton<TokenStorage>(() => TokenStorage(getIt()));
  getIt.registerLazySingleton<AuthEventBus>(() => AuthEventBus());
  getIt.registerLazySingleton<DioClient>(
    () => DioClient(tokenStorage: getIt(), authEventBus: getIt()),
  );

  // --- Auth ---
  getIt.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSource(getIt<DioClient>().dio));
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remote: getIt(), tokenStorage: getIt()),
  );
  getIt.registerFactory<AuthBloc>(() => AuthBloc(authRepository: getIt(), authEventBus: getIt()));

  // --- Doctors ---
  getIt.registerLazySingleton<DoctorsRemoteDataSource>(() => DoctorsRemoteDataSource(getIt<DioClient>().dio));
  getIt.registerLazySingleton<DoctorsRepository>(() => DoctorsRepositoryImpl(getIt()));
  getIt.registerFactory<DoctorsBloc>(() => DoctorsBloc(repository: getIt()));

  // --- Services ---
  getIt.registerLazySingleton<ServicesRemoteDataSource>(() => ServicesRemoteDataSource(getIt<DioClient>().dio));
  getIt.registerLazySingleton<ServicesRepository>(() => ServicesRepositoryImpl(getIt()));
  getIt.registerFactory<ServicesBloc>(() => ServicesBloc(repository: getIt()));

  // --- Booking ---
  getIt.registerLazySingleton<BookingRemoteDataSource>(() => BookingRemoteDataSource(getIt<DioClient>().dio));
  getIt.registerLazySingleton<BookingRepository>(() => BookingRepositoryImpl(getIt()));
  getIt.registerFactory<BookingBloc>(() => BookingBloc(repository: getIt()));

  // --- Appointments ---
  getIt.registerLazySingleton<AppointmentsRemoteDataSource>(
      () => AppointmentsRemoteDataSource(getIt<DioClient>().dio));
  getIt.registerLazySingleton<AppointmentsRepository>(() => AppointmentsRepositoryImpl(getIt()));
  getIt.registerFactory<AppointmentsBloc>(() => AppointmentsBloc(repository: getIt()));
}
