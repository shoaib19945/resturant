  import 'package:flutter/material.dart';

  class AppConfig extends InheritedWidget {
    const AppConfig({
      super.key,
      required this.baseUrl,
      required this.headers,
      required super.child,
    });

    static const String defaultBaseUrl =
        'https://dev-api.livelongfit.com/api/v2';

    static const String _authToken =
        'Y8FyZBClwGhrOYaq1sOi5Kr+vqgI9ZUlRWuqzVaqljqSzejGXrxD158TZ0fSbJWbugCpYXu8w6P'
        'eRSpZjgZJ+Vur1B0ktJDByxpgVdweAJ+4CO1YQ5DltkgFjk+TmgmTmFNc/IwFAVGBtu2kCeWV'
        'ZUf7t5A/dKkQUdCBdfkJaVkYHQRbM+ekxvpVLWsrBp8wLsM12O2UJiy01EMd7MlUUyErdT9K9'
        '+047LTgMTZXs5fiKkPP1GJKx7BjAjMIIF7Mf3k1Z6BQZ0bv/+orMLaGYbpoRvClPdEpRV23pZfe'
        'TqE=';

    static const Map<String, String> defaultHeaders = {
      'Accept': 'application/json',
      'Accept-Charset': 'UTF-8',
      'Content-Type': 'application/json',
      'User-Agent':
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:127.0) Gecko/20100101 Firefox/127.0',
      'auth': _authToken,
      'sessiontoken': '',
    };

    factory AppConfig.create({required Widget child}) {
      return AppConfig(
        baseUrl: defaultBaseUrl,
        headers: defaultHeaders,
        child: child,
      );
    }

    final String baseUrl;
    final Map<String, String> headers;

    static AppConfig of(BuildContext context) {
      final AppConfig? result =
      context.dependOnInheritedWidgetOfExactType<AppConfig>();
      assert(result != null, 'No AppConfig found in context');
      return result!;
    }

    @override
    bool updateShouldNotify(AppConfig oldWidget) {
      return oldWidget.baseUrl != baseUrl || oldWidget.headers != headers;
    }
  }
