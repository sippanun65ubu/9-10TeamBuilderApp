import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'models/product_model.dart';
import 'products/products_page.dart'; // Import the new products page
import 'pocketbase_client.dart';

// You can remove fetchProducts() and setupRealtimeListener() from here
// // as they are now in the ProductsPage.

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PocketBase Shop',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ShopPage(),
    );
  }
}

// A simple data model for a review
class Review {
  final String reviewerName;
  final double rating;
  final String comment;

  const Review({
    required this.reviewerName,
    required this.rating,
    required this.comment,
  });
}

class ShopPage extends StatefulWidget {
  const ShopPage({super.key});

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  final ScrollController _scrollController = ScrollController();
  int _currentIndex = 0;

  List<Product> _products = [];
  bool _isLoading = true;

  static const List<Review> popularReviews = [
    Review(
      reviewerName: 'Alice C.',
      rating: 5.0,
      comment: 'Excellent product, works perfectly and the quality is superb!',
    ),
    Review(
      reviewerName: 'Bob M.',
      rating: 4.5,
      comment: 'Great value for the price. I would highly recommend it.',
    ),
    Review(
      reviewerName: 'Charlie L.',
      rating: 5.0,
      comment: 'Fast shipping and a fantastic product. Couldn\'t be happier!',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    try {
      final records = await pb.collection('products').getFullList(
        sort: '-created',
      );
      setState(() {
        _products = records.map((record) => Product.fromRecord(record)).toList();
        _isLoading = false;
      });
    } on ClientException catch (e) {
      print('Error fetching products: ${e.response}');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _slideToNextProduct() {
    if (_products.isEmpty) return;
    setState(() {
      _currentIndex = (_currentIndex + 1) % _products.length;
    });
    _animateScroll();
  }

  void _slideToPreviousProduct() {
    if (_products.isEmpty) return;
    setState(() {
      _currentIndex = (_currentIndex - 1 + _products.length) % _products.length;
    });
    _animateScroll();
  }

  void _animateScroll() {
    const double cardWidthWithMargin = 180 + 16;
    final double nextOffset = _currentIndex * cardWidthWithMargin;

    _scrollController.animateTo(
      nextOffset,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PocketBase Shop'),
        backgroundColor: Colors.blue,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Categories Section
                    const Text(
                      'Shop Categories',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(onPressed: () {}, child: const Text('Button 1')),
                        ElevatedButton(onPressed: () {}, child: const Text('Button 2')),
                        ElevatedButton(onPressed: () {}, child: const Text('Button 3')),
                      ],
                    ),
                    const SizedBox(height: 32),
                    
                    const Divider(),
                    const SizedBox(height: 32),

                    // Top Products Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Top Products',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        // New button to navigate to the full product list
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ProductsPage(),
                              ),
                            );
                          },
                          child: const Text('View All'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    SizedBox(
                      height: 250,
                      child: ListView.builder(
                        controller: _scrollController,
                        scrollDirection: Axis.horizontal,
                        itemCount: _products.length,
                        itemBuilder: (context, index) {
                          final product = _products[index];
                          return ProductCard(product: product);
                        },
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    const Divider(),
                    const SizedBox(height: 32),

                    // Popular Reviews Section
                    const Text(
                      'Popular Reviews',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Column(
                      children: popularReviews.map((review) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: ReviewCard(review: review),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

// A reusable widget to display a single product from a PocketBase record
class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // This section now uses a placeholder since the image is removed
          Container(
            height: 100,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: const Center(
              child: Icon(Icons.shopping_bag, size: 50, color: Colors.grey),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${product.price.toStringAsFixed(2)}',
                  style: const TextStyle(color: Colors.green, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  product.description,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// A reusable widget to display a single review
class ReviewCard extends StatelessWidget {
  final Review review;

  const ReviewCard({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                review.reviewerName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < review.rating.floor() ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 18,
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            review.comment,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}