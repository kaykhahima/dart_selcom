import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

/// A client for interacting with the Selcom API.
///
/// This class handles authentication, request signing, and communication
/// with the Selcom API endpoints.
class SelcomClient {
  /// Base URL for the Selcom API.
  final String baseUrl;

  /// API key used for authentication.
  final String apiKey;

  /// API secret used for signing requests.
  final String apiSecret;

  /// Creates a new [SelcomClient] instance.
  ///
  /// [baseUrl] is the base URL of the Selcom API.
  /// [apiKey] is the API key provided by Selcom.
  /// [apiSecret] is the API secret used for signing requests.
  SelcomClient({
    required this.baseUrl,
    required this.apiKey,
    required this.apiSecret,
  });

  /// Computes authentication headers for a request.
  ///
  /// [jsonData] is the data to be sent in the request.
  ///
  /// Returns a list containing:
  /// - [0]: Authorization token
  /// - [1]: Timestamp
  /// - [2]: Request digest
  /// - [3]: Signed fields
  List<String> computeHeader(Map<String, dynamic> jsonData) {
    // Create base64 encoded authorization token
    final authToken = 'SELCOM ${base64.encode(utf8.encode(apiKey))}';

    // Generate timestamp
    final timestamp = _getTimestamp();

    // Build data string for HMAC signing
    var data = 'timestamp=$timestamp';
    var signedFields = '';

    jsonData.forEach((key, value) {
      data += '&$key=$value';

      if (signedFields.isEmpty) {
        signedFields = key;
      } else {
        signedFields += ',$key';
      }
    });

    // Create HMAC-SHA256 signature
    final hmacBytes =
        Hmac(sha256, utf8.encode(apiSecret)).convert(utf8.encode(data)).bytes;
    final digest = base64.encode(Uint8List.fromList(hmacBytes));

    return [authToken, timestamp, digest, signedFields];
  }

  /// Sends a POST request to the specified path.
  ///
  /// [path] is the API endpoint path.
  /// [jsonData] is the data to be sent in the request body.
  ///
  /// Returns the response data or error information.
  Future<http.Response> postFunc(
    String path,
    Map<String, dynamic> jsonData,
  ) async {
    final headers = _prepareHeaders(jsonData);

    try {
      final trimmedUrl = (baseUrl + path).trim();
      final response = await http.post(
        Uri.parse(trimmedUrl),
        headers: headers,
        body: jsonEncode(jsonData),
      );

      return response;
    } catch (e) {
      if (e is http.ClientException) {
        return http.Response('{"error": "${e.message}"}', 500);
      }
      return http.Response('{"error": "${e.toString()}"}', 500);
    }
  }

  /// Sends a GET request to the specified path.
  ///
  /// [path] is the API endpoint path.
  /// [queryParams] is the data to be sent as query parameters.
  ///
  /// Returns the response data or error information.
  Future<dynamic> getFunc(String path, Map<String, dynamic> queryParams) async {
    final headers = _prepareHeaders(queryParams);
    final trimmedUrl = (baseUrl + path).trim();

    // Build URL with query parameters
    final uri = Uri.parse(trimmedUrl).replace(
      queryParameters: queryParams.map(
        (key, value) => MapEntry(key, value.toString()),
      ),
    );

    try {
      final response = await http.get(uri, headers: headers);
      return jsonDecode(response.body);
    } catch (e) {
      if (e is http.ClientException) {
        return {'error': e.message};
      }
      return {'error': e.toString()};
    }
  }

  /// Sends a DELETE request to the specified path.
  ///
  /// [path] is the API endpoint path.
  /// [queryParams] is the data to be sent as query parameters.
  ///
  /// Returns the response data or error information.
  Future<dynamic> deleteFunc(
    String path,
    Map<String, dynamic> queryParams,
  ) async {
    final headers = _prepareHeaders(queryParams);
    final trimmedUrl = (baseUrl + path).trim();

    // Build URL with query parameters
    final uri = Uri.parse(trimmedUrl).replace(
      queryParameters: queryParams.map(
        (key, value) => MapEntry(key, value.toString()),
      ),
    );

    try {
      final response = await http.delete(uri, headers: headers);
      return jsonDecode(response.body);
    } catch (e) {
      if (e is http.ClientException) {
        return {'error': e.message};
      }
      return {'error': e.toString()};
    }
  }

  /// Helper method to prepare HTTP headers.
  ///
  /// [data] is the data used to compute authentication headers.
  ///
  /// Returns a map of HTTP headers.
  Map<String, String> _prepareHeaders(Map<String, dynamic> data) {
    final [authToken, timestamp, digest, signedFields] = computeHeader(data);

    return {
      'Content-Type': 'application/json',
      'Accept': '*/*',
      'Accept-Encoding': '*',
      'Accept-Language': '*',
      'Authorization': authToken,
      'Digest-Method': 'HS256',
      'Digest': digest,
      'Timestamp': timestamp,
      'Signed-Fields': signedFields,
    };
  }

  /// Helper method to get the current timestamp in Nairobi time zone.
  String _getTimestamp() {
    // Timestamp in UTC+3:00
    final DateTime nowUtc = DateTime.now().toUtc();
    final DateTime nairobiTime = nowUtc.add(Duration(hours: 3));

    return "${DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(nairobiTime)}+03:00";
  }
}
