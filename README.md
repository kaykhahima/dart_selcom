
# Selcom Dart Package

```dart_selcom``` is a Dart package for accessing Selcom APIs

## Motivation

As a Flutter developer, being competent in [Dart](https://dart.dev/) language, I wanted to integrate Selcom payment gateway into my backend server. However, I found that there were no existing Dart packages available for this purpose. To fill this gap, I created this package to provide a simple way to use Selcom APIs with backend servers that support Dart.

## Installation

Add `dart_selcom` to your `pubspec.yaml` file:

```yaml
dependencies:
  dart_selcom: latest_version
```

Run `dart pub get` to install the package, or, install it directly from the command line:

```yaml
dart pub add dart_selcom
```

## Example: Create Order

```dart
// Initialize the Selcom client
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
```

## Contributing

Contributions are welcome! If you have suggestions for improvements or new features, please open an issue or submit a pull request.

## License

This project is licensed under the BSD 3-Clause License. See the [LICENSE](LICENSE) file for details.

