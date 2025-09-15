import 'package:pocketbase/pocketbase.dart';
import '../pocketbase_client.dart';

class Product {
  final String id;
  final String name;
  final String description;
  final double price;

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
  });

  factory Product.fromRecord(RecordModel record) {
    // Corrected line: Convert the Uri returned by getUrl to a String
    final imageUrl = pb.files.getUrl(record, record.data['image'] as String? ?? '').toString();

    return Product(
      id: record.id,
      name: record.data['name'] as String? ?? 'N/A',
      description: record.data['description'] as String? ?? 'N/A',
      price: (record.data['price'] as num?)?.toDouble() ?? 0.0,
    );
  }
}