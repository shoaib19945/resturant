class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => 'ApiException: $message (status: $statusCode)';
}

class NetworkException implements Exception {
  final String _rawCause;
  NetworkException([this._rawCause = '']);

  String get message => 'No internet connection. Please check your network settings and try again.';

  @override
  String toString() => 'NetworkException: $_rawCause';
}

String friendlyErrorMessage(Object error) {
  if (error is NetworkException) {
    return error.message;
  } else if (error is ApiException) {
    return error.message;
  } else if (error.toString().contains('SocketException') ||
      error.toString().contains('HandshakeException') ||
      error.toString().contains('Failed host lookup') ||
      error.toString().contains('Connection refused')) {
    return 'No internet connection. Please check your network settings and try again.';
  }
  return 'Something went wrong. Please try again.';
}
