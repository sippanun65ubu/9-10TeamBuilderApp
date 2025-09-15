import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'models/product_model.dart'; // Import the Product model

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PocketBase Products',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ProductsPage(),
    );
  }
}

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  // Store the fetched products
  List<Product> _products = [];

  // Manage the state of data fetching
  bool _isLoading = true;
  bool _isFetchingMore = false;
  bool _hasMore = true;
  int _page = 1;

  // Controller for infinite scrolling
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Start listening for real-time updates and fetch the initial products.
    _setupRealtime();
    _fetchProducts();

    // Add a listener to the scroll controller to detect when to fetch more data.
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        // User has scrolled to the bottom, fetch more products.
        _fetchMoreProducts();
      }
    });
  }

  @override
  void dispose() {
    // Clean up the scroll controller and real-time listener.
    _scrollController.dispose();
    pb.collection('products').unsubscribe();
    super.dispose();
  }

  // Set up the real-time listener for the 'products' collection.
  void _setupRealtime() {
    pb.collection('products').subscribe('*', (e) {
      if (e.action == 'create') {
        // A new product was added. Add it to the top of the list.
        final newProduct = Product.fromRecord(e.record!);
        setState(() {
          _products.insert(0, newProduct);
        });
      } else if (e.action == 'update') {
        // An existing product was updated. Find it and replace it.
        final updatedProduct = Product.fromRecord(e.record!);
        final index = _products.indexWhere((p) => p.id == updatedProduct.id);
        if (index != -1) {
          setState(() {
            _products[index] = updatedProduct;
          });
        }
      } else if (e.action == 'delete') {
        // A product was deleted. Remove it from the list.
        final deletedId = e.record!.id;
        setState(() {
          _products.removeWhere((p) => p.id == deletedId);
        });
      }
    });
  }

  // Initial fetch of products.
  Future<void> _fetchProducts() async {
    try {
      final result = await pb.collection('products').getList(
        page: _page,
        perPage: 20, // Fetch 20 items per page.
        sort: '-created',
      );
      setState(() {
        _products = result.items.map((record) => Product.fromRecord(record)).toList();
        _isLoading = false;
        _hasMore = result.items.isNotEmpty;
      });
    } catch (e) {
      print('Error fetching products: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Fetch the next page of products for infinite scrolling.
  Future<void> _fetchMoreProducts() async {
    if (_isFetchingMore || !_hasMore) return;
    
    setState(() {
      _isFetchingMore = true;
    });

    try {
      final nextPage = _page + 1;
      final result = await pb.collection('products').getList(
        page: nextPage,
        perPage: 20,
        sort: '-created',
      );

      setState(() {
        _products.addAll(result.items.map((record) => Product.fromRecord(record)));
        _page = nextPage;
        _hasMore = result.items.isNotEmpty;
        _isFetchingMore = false;
      });
    } catch (e) {
      print('Error fetching more products: $e');
      setState(() {
        _isFetchingMore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        backgroundColor: Colors.blue,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchProducts,
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _products.length + (_isFetchingMore ? 1 : 0),
                itemBuilder: (context, index) {
                  // Show a loading indicator at the bottom if more data is being fetched.
                  if (index == _products.length) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  final product = _products[index];
                  return ProductCard(product: product);
                },
              ),
            ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 80,
              height: 80,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(
                  product.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.broken_image),
                ),
              ),
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.green,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    product.description,
                    style: const TextStyle(fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}