import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../constants/app_constants.dart';
import '../error/exceptions.dart';

class ApiClient {
  late final Dio _dio;

  ApiClient({String? token}) {
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: Duration(seconds: AppConstants.connectTimeout),
      receiveTimeout: Duration(seconds: AppConstants.receiveTimeout),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    ));

    debugPrint('[ApiClient] baseUrl = ${AppConstants.baseUrl}');

    _dio.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseHeader: false,
      responseBody: true,
      error: true,
      compact: false,
      logPrint: (o) => debugPrint(o.toString()),
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onError: (DioException e, handler) {
        handler.next(e);
      },
    ));
  }

  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
  }

  Future<Map<String, dynamic>> get(String path) async {
    try {
      final response = await _dio.get(path);
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> post(String path, {Map<String, dynamic>? data}) async {
    try {
      final response = await _dio.post(path, data: data);
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> put(String path, {Map<String, dynamic>? data}) async {
    try {
      final response = await _dio.put(path, data: data);
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Map<String, dynamic> _handleResponse(Response response) {
    final data = response.data as Map<String, dynamic>;
    if (data['success'] == false) {
      final errorCode = data['error_code'] as String?;
      final message = data['message'] as String? ?? 'Terjadi kesalahan.';

      if (response.statusCode == 401) {
        if (errorCode == 'INVALID_OTP' || errorCode == 'INVALID_TOTP') {
          throw InvalidOtpException(message);
        }
        throw UnauthorizedException(message, errorCode: errorCode);
      }
      if (errorCode == 'INSUFFICIENT_BALANCE') {
        final d = data['data'] as Map<String, dynamic>?;
        throw InsufficientBalanceException(
          message,
          balance: (d?['balance'] as num?)?.toDouble(),
          amount: (d?['amount'] as num?)?.toDouble(),
        );
      }
      throw ServerException(message, errorCode: errorCode, statusCode: response.statusCode);
    }
    return data;
  }

  Exception _handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout) {
      return const NetworkException();
    }
    if (e.response != null) {
      try {
        final data = e.response!.data as Map<String, dynamic>;
        final message = data['message'] as String? ?? 'Terjadi kesalahan.';
        final errorCode = data['error_code'] as String?;
        final status = e.response!.statusCode;

        if (status == 401) {
          if (errorCode == 'INVALID_OTP' || errorCode == 'INVALID_TOTP') {
            return InvalidOtpException(message);
          }
          if (errorCode == 'INSUFFICIENT_BALANCE') {
            final d = data['data'] as Map<String, dynamic>?;
            return InsufficientBalanceException(
              message,
              balance: (d?['balance'] as num?)?.toDouble(),
              amount: (d?['amount'] as num?)?.toDouble(),
            );
          }
          return UnauthorizedException(message, errorCode: errorCode);
        }
        return ServerException(message, errorCode: errorCode, statusCode: status);
      } catch (_) {
        return ServerException('Terjadi kesalahan server.', statusCode: e.response?.statusCode);
      }
    }
    return ServerException('Terjadi kesalahan jaringan.');
  }
}
