import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../../core/data/app_exceptions.dart';
import '../../core/domain/session_manager.dart';
import '../error_logging_service/error_logging_service.dart';
import 'rest_network_service.dart';

/// Implementation of [RestfulApiService] using the Dio library.
class DioNetworkService extends RestNetworkService {
  final Dio _dio;
  final SessionManager sessionManager;

  DioNetworkService({
    required this.sessionManager,
    required super.baseUrl,
    required super.isProd,
    required super.sendTimeout,
    super.receiveTimeout,
  }) : _dio = Dio(
         BaseOptions(
           baseUrl: Uri.parse(baseUrl).toString(),
           connectTimeout: sendTimeout,
           sendTimeout: sendTimeout,
           receiveTimeout: receiveTimeout ?? sendTimeout,
         ),
       ) {
    _dio.interceptors.addAll([
      if (!isProd || kDebugMode) NetworkLoggerInterceptor(),
      DataErrorInterceptor(),
    ]);
  }

  @override
  Future<Json> sendFormDataRequest<T>(FormDataRequest request) async {
    // assert(initialized, 'This Network Service has not been initialized');

    final files = request.files.map((key, file) {
      final type = lookupMimeType(file.path);
      final contentType = type != null ? MediaType.parse(type) : null;
      return MapEntry(key, MultipartFile.fromFileSync(file.path, contentType: contentType));
    });
    final otherData = request.body;

    final data = FormData.fromMap({...files, ...otherData});

    try {
      final response = await _dio.request(
        request.endpoint,
        data: data,
        queryParameters: request.queryParams,
        options: Options(
          method: request.method,
          contentType: 'multipart/form-data',
          headers: sessionManager.sessionHeaders(request.useToken),
        ),
      );
      final res = response.data;
      if (res is! Map) {
        return {'data': res};
      }
      return res as Json;
    } on DioException catch (e) {
      throw e.error!;
    }
  }

  @override
  Future<Json> sendJsonRequest<T>(JsonRequest request) async {
    // assert(initialized, 'This Network Service has not been initialized');
    try {
      final headers = sessionManager.sessionHeaders(request.useToken);
      final response = await _dio.request(
        request.endpoint,
        data: request.body,
        queryParameters: request.queryParams,
        options: Options(
          method: request.method,
          contentType: 'Application/json',
          responseType: ResponseType.json,
          headers: headers,
        ),
      );
      final res = response.data;
      if (res is! Map) {
        return {'data': res};
      }
      // Handle errors coming with success status code
      if (res['error'] as bool? ?? false) {
        throw InputException(errorMessage: res['message'].toString());
      }

      return res as Json;
    } on DioException catch (e) {
      throw e.error!;
    }
  }
}

class DataErrorInterceptor extends Interceptor {
  DataErrorInterceptor();

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (response.data is! Map) {
      response.data = {'data': response.data};
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    ErrorLogService.instance.recordError(
      err.error,
      err.stackTrace,
      information: [err.response ?? '', err.requestOptions],
    );
    if (err.isNetworkError) {
      handler.next(DioException(requestOptions: err.requestOptions, error: NetworkException()));
    } else if (err.isTimeoutError) {
      handler.next(
        DioException(
          requestOptions: err.requestOptions,
          error: TimeoutException('Request Timed out. Try again'),
        ),
      );
    } else if (err.isServerError || err.isUnauthorised) {
      String? message;
      if (err.response?.data is Map) {
        message = err.response?.data['message'];
      }
      handler.next(
        DioException(
          requestOptions: err.requestOptions,
          error: err.isServerError
              ? ServerException(errorMessage: message)
              : UnauthorisedException(errorMessage: message ?? ''),
        ),
      );
    } else {
      Map json;
      if (err.response == null) {
        json = {};
      } else if (err.response?.data is Map) {
        json = err.response!.data;
      } else {
        json = jsonDecode(err.response!.data);
      }
      handler.next(
        DioException(
          requestOptions: err.requestOptions,
          error: InputException(errorMessage: json['message']),
        ),
      );
    }
  }
}

class NetworkLoggerInterceptor extends PrettyDioLogger {
  NetworkLoggerInterceptor()
    : super(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
        maxWidth: 88,
      );
}

extension DioExceptionExtension on DioException {
  bool get isTimeoutError => [
    DioExceptionType.sendTimeout,
    DioExceptionType.receiveTimeout,
    DioExceptionType.connectionTimeout,
  ].contains(type);

  bool get isNetworkError => error is SocketException || type == DioExceptionType.connectionError;

  bool get isServerError => (response?.statusCode ?? 501) >= 500;

  bool get isUnauthorised => [401, 403].contains(response?.statusCode);
}
