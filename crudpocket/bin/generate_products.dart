import 'package:pocketbase/pocketbase.dart';
import 'package:faker/faker.dart';
import 'dart:io';

// Initialize PocketBase client
final pb = PocketBase('http://127.0.0.1:8090');
final faker = Faker();

Future<void> main() async {
  try {
    // Authenticate as an admin
    await pb.admins.authWithPassword('YOUR_ADMIN_EMAIL', 'YOUR_ADMIN_PASSWORD');

    // Number of products to create
    const int numberOfProducts = 50;

    for (int i = 0; i < numberOfProducts; i++) {
      // Generate fake data
      final name = faker.food.cuisine();
      final description = faker.lorem.sentences(3).join(' ');
      final price = faker.randomGenerator.decimal(min: 1, scale: 1000);

      final body = {
        'name': name,
        'description': description,
        'price': price,
      };

      await pb.collection('products').create(
        body: body,
      );

      print('Created product ${i + 1}: $name');
    }

    print('\nSuccessfully created $numberOfProducts products.');
  } on ClientException catch (e) {
    print('Error: ${e.response}');
  } catch (e) {
    print('An unexpected error occurred: $e');
  }
}