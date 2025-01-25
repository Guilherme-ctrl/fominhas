import 'package:dio/dio.dart';

class BasicInterceptor implements Interceptor {
  final String email;
  final String token;

  BasicInterceptor(this.email, this.token);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) => handler.next(err);

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    options.headers['Content-Type'] = 'application/json';
    options.headers['Authorization'] = 'Bearer $token';
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) => handler.next(response);
}
