import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../features/about/presentation/pages/about_us_screen.dart';
import '../../features/appointments/presentation/pages/appointments_list_page.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/booking/presentation/bloc/booking_bloc.dart';
import '../../features/booking/presentation/pages/confirmation_page.dart';
import '../../features/booking/presentation/pages/patient_details_page.dart';
import '../../features/booking/presentation/pages/payment_page.dart';
import '../../features/booking/presentation/pages/select_doctor_page.dart';
import '../../features/booking/presentation/pages/select_service_page.dart';
import '../../features/booking/presentation/pages/select_slot_page.dart';
import '../../features/contact/presentation/pages/contact_page.dart';
import '../../features/doctors/domain/entities/doctor_entity.dart';
import '../../features/doctors/presentation/pages/doctor_detail_page.dart';
import '../../features/doctors/presentation/pages/doctors_list_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/services/domain/entities/service_entity.dart';
import '../../features/services/presentation/pages/service_detail_page.dart';
import '../../features/services/presentation/pages/services_list_page.dart';
import '../../features/settings/presentation/pages/settings_screen.dart';
import '../di/service_locator.dart';
import 'root_shell.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  AppRouter(this._authBloc);
  final AuthBloc _authBloc;

  late final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    refreshListenable: _GoRouterRefreshStream(_authBloc.stream),
    redirect: (context, state) {
      final authState = _authBloc.state;
      final isSplash = state.matchedLocation == '/splash';
      // ignore: unused_local_variable
      final isAuthRoute = state.matchedLocation == '/login' || state.matchedLocation == '/register';

      // Wait for the initial session check before making any redirect
      // decisions, otherwise we'd bounce a logged-in user to /login for a
      // frame while restoreSession() is still resolving.
      if (authState is AuthInitial || authState is AuthChecking) {
        return isSplash ? null : null;
      }
      if (isSplash) {
        return '/home';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (context, state) => const SplashPage()),
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(path: '/register', builder: (context, state) => const RegisterPage()),
      GoRoute(path: '/profile', builder: (context, state) => const ProfilePage()),
      GoRoute(path: '/settings', builder: (context, state) => const SettingsScreen()),
      GoRoute(path: '/about', builder: (context, state) => const AboutUsScreen()),
      GoRoute(path: '/contact', builder: (context, state) => const ContactPage()),

      // --- Booking flow (wrapped in its own BookingBloc so the draft
      // persists across steps but resets once you leave the flow) ---
      ShellRoute(
        builder: (context, state, child) => BlocProvider(
          create: (_) => getIt<BookingBloc>(),
          child: child,
        ),
        routes: [
          GoRoute(
            path: '/booking/select-service',
            builder: (context, state) => SelectServicePage(doctor: state.extra as DoctorEntity),
          ),
          GoRoute(
            path: '/booking/select-doctor',
            builder: (context, state) => SelectDoctorPage(service: state.extra as ServiceEntity),
          ),
          GoRoute(path: '/booking/select-slot', builder: (context, state) => const SelectSlotPage()),
          GoRoute(path: '/booking/patient-details', builder: (context, state) => const PatientDetailsPage()),
          GoRoute(path: '/booking/payment', builder: (context, state) => const PaymentPage()),
          GoRoute(path: '/booking/confirmation', builder: (context, state) => const ConfirmationPage()),
        ],
      ),

      // --- Bottom-nav shell ---
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => RootShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            navigatorKey: _shellNavigatorKey,
            routes: [GoRoute(path: '/home', builder: (context, state) => const HomePage())],
          ),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/services',
              builder: (context, state) => const ServicesListPage(),
              routes: [
                GoRoute(
                  path: ':idOrSlug',
                  builder: (context, state) => ServiceDetailPage(idOrSlug: state.pathParameters['idOrSlug']!),
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/doctors',
              builder: (context, state) => const DoctorsListPage(),
              routes: [
                GoRoute(
                  path: ':id',
                  builder: (context, state) => DoctorDetailPage(doctorId: state.pathParameters['id']!),
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/appointments', builder: (context, state) => const AppointmentsListPage()),
          ]),
        ],
      ),
    ],
  );
}

/// Bridges a [Stream] (the AuthBloc's state stream) into a [Listenable] so
/// go_router re-evaluates `redirect` whenever auth state changes (e.g. a
/// forced logout from an expired session).
class _GoRouterRefreshStream extends ChangeNotifier {
  _GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final dynamic _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
