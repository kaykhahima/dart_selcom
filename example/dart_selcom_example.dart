import 'dart:convert';

import 'package:dart_selcom/dart_selcom.dart';

void main() async {
  final selcomClient = SelcomClient(
    baseUrl: 'SELCOM_BASE_URL',
    apiKey: 'SELCOM_API_KEY',
    apiSecret: 'SELCOM_API_SECRET',
  );

  // Example data. Replace with actual values.
  final data = {
    'vendor': '{{vendor}}',
    'order_id': '{{order_id}}',
    'no_of_items': '{{no_of_items}}',
    'buyer_email': '{{buyer_email}}',
    'buyer_name': '{{buyer_name}}',
    'buyer_phone': '{{buyer_phone}}',
    'amount': '{{amount}}',
    'currency': '{{currency}}',
    'webhook': base64.encode(utf8.encode('{{webhook}}')),
  };

  try {
    final path = '/checkout/create-order-minimal';

    final res = await selcomClient.postFunc(path, data);
    if (res.statusCode == 200) {
      // Successful response
      print('Order created: ${res.body}');
    } else {
      // Failed response
      print('Failed to create order: ${res.body}');
    }
  } catch (e) {
    print('Failed to create order: ${e.toString()}');
  }
}
