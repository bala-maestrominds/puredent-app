import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../errors/failure.dart';
import '../storage/token_storage.dart';
import '../utils/app_config.dart';
import 'auth_event_bus.dart';

/// Builds and configures the single [Dio] instance used across the app.
///
/// Responsibilities:
/// - attaches the bearer access token to every request
/// - transparently refreshes the access token on a 401 and retries the
///   original request exactly once (queues concurrent 401s so we only
///   refresh a single time)
/// - retries idempotent GET requests on transient network/timeout errors
///   with exponential backoff
/// - normalizes every error into a [Failure] via [DioException.error]
class DioClient {
  DioClient({
    required TokenStorage tokenStorage,
    required AuthEventBus authEventBus,
  })  : _tokenStorage = tokenStorage,
        _authEventBus = authEventBus {
    dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: AppConfig.connectTimeout,
        receiveTimeout: AppConfig.receiveTimeout,
        headers: {'Content-Type': 'application/json'},
      ),
    );

    dio.interceptors.add(_authInterceptor());
    dio.interceptors.add(_retryInterceptor());

    if (AppConfig.enableNetworkLogs) {
      dio.interceptors.add(PrettyDioLogger(
        requestHeader: false,
        requestBody: true,
        responseBody: true,
        compact: true,
      ));
    }
  }

  late final Dio dio;
  final TokenStorage _tokenStorage;
  final AuthEventBus _authEventBus;

  // Ensures only one refresh call is in-flight at a time; concurrent 401s
  // await this same future instead of each triggering their own refresh.
  Completer<bool>? _refreshCompleter;

  InterceptorsWrapper _authInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        if (!options.extra.containsKey('skipAuth')) {
          final token = await _tokenStorage.accessToken;
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        final isUnauthorized = error.response?.statusCode == 401;
        // Only the endpoints that themselves establish/replace tokens should be
        // excluded from the refresh-and-retry flow (retrying them on a 401
        // makes no sense / could loop). Authenticated endpoints that merely
        // *use* a token -- like /auth/me, /auth/logout, /auth/change-password --
        // must still go through the refresh flow, otherwise a session that's
        // still valid (via the refresh token) incorrectly looks "logged out"
        // the moment the short-lived access token expires, e.g. when opening
        // the Profile screen after 15+ minutes.
        const noRefreshPaths = ['/auth/login', '/auth/register', '/auth/refresh'];
        final isNoRefreshEndpoint =
            noRefreshPaths.any((p) => error.requestOptions.path.contains(p));

        if (isUnauthorized && !isNoRefreshEndpoint) {
          final refreshed = await _refreshToken();
          if (refreshed) {
            try {
              final response = await _retryRequest(error.requestOptions);
              return handler.resolve(response);
            } catch (_) {
              // fall through to normalized error below
            }
          } else {
            _authEventBus.emit(AuthBusEvent.sessionExpired);
          }
        }
        handler.next(_normalize(error));
      },
    );
  }

  Future<bool> _refreshToken() async {
    if (_refreshCompleter != null) {
      return _refreshCompleter!.future;
    }
    final completer = Completer<bool>();
    _refreshCompleter = completer;

    try {
      final refreshToken = await _tokenStorage.refreshToken;
      if (refreshToken == null) {
        completer.complete(false);
        return false;
      }

      final refreshDio = Dio(BaseOptions(baseUrl: AppConfig.apiBaseUrl));
      final response = await refreshDio.post(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );

      final data = response.data['data'];
      await _tokenStorage.saveTokens(
        accessToken: data['accessToken'],
        refreshToken: data['refreshToken'],
      );
      completer.complete(true);
      return true;
    } catch (_) {
      await _tokenStorage.clear();
      completer.complete(false);
      return false;
    } finally {
      _refreshCompleter = null;
    }
  }

  Future<Response<dynamic>> _retryRequest(RequestOptions requestOptions) async {
    final token = await _tokenStorage.accessToken;
    final options = Options(method: requestOptions.method, headers: {
      ...requestOptions.headers,
      if (token != null) 'Authorization': 'Bearer $token',
    });
    return dio.request(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }

  InterceptorsWrapper _retryInterceptor() {
    const maxRetries = 2;
    return InterceptorsWrapper(
      onError: (error, handler) async {
        final isRetryable = error.type == DioExceptionType.connectionTimeout ||
            error.type == DioExceptionType.receiveTimeout ||
            error.type == DioExceptionType.connectionError;
        final isGet = error.requestOptions.method == 'GET';
        final attempt =
            (error.requestOptions.extra['retryAttempt'] as int?) ?? 0;

        if (isRetryable && isGet && attempt < maxRetries) {
          await Future.delayed(Duration(milliseconds: 400 * (attempt + 1)));
          final options = error.requestOptions;
          options.extra['retryAttempt'] = attempt + 1;
          try {
            final response = await dio.fetch(options);
            return handler.resolve(response);
          } catch (e) {
            return handler.next(e is DioException ? e : error);
          }
        }
        handler.next(error);
      },
    );
  }

  DioException _normalize(DioException error) {
    Failure failure;

    if (error.type == DioExceptionType.connectionError) {
      failure = Failure.network();
    } else if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      failure = Failure.timeout();
    } else if (error.response?.statusCode == 401) {
      failure = Failure.unauthorized();
    } else if (error.response != null) {
      final body = error.response!.data;
      final message = (body is Map && body['error'] is String)
          ? body['error'] as String
          : 'Something went wrong.';
      final rawDetails = (body is Map) ? body['details'] : null;
      List<FieldError>? fieldErrors;
      if (rawDetails is List) {
        fieldErrors = rawDetails
            .whereType<Map>()
            .map((e) => FieldError(
                e['field']?.toString() ?? '', e['message']?.toString() ?? ''))
            .toList();
      }
      failure = Failure(message,
          statusCode: error.response!.statusCode, fieldErrors: fieldErrors);
    } else if (error.error is SocketException) {
      failure = Failure.network();
    } else {
      failure = Failure.unknown();
    }

    return error.copyWith(error: failure);
  }
}

/// Quick connectivity check usable before firing off a request from the UI
/// (e.g. to show an offline banner immediately instead of waiting on a
/// timeout).
Future<bool> hasInternetConnection() async {
  final result = await Connectivity().checkConnectivity();
  return !result.contains(ConnectivityResult.none);
}
