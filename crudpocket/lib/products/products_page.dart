import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import '../models/product_model.dart'; // Corrected import path
import '../pocketbase_client.dart';
import 'edit_product_page.dart'; // Corrected import path
import 'create.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  List<Product> _products = [];
  bool _isLoading = true;
  bool _isFetchingMore = false;
  bool _hasMore = true;
  int _page = 1;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _setupRealtime();
    _fetchProducts();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        _fetchMoreProducts();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    pb.collection('products').unsubscribe();
    super.dispose();
  }

  void _setupRealtime() {
    pb.collection('products').subscribe('*', (e) {
      if (e.action == 'create') {
        final newProduct = Product.fromRecord(e.record!);
        setState(() {
          _products.insert(0, newProduct);
        });
      } else if (e.action == 'update') {
        final updatedProduct = Product.fromRecord(e.record!);
        final index = _products.indexWhere((p) => p.id == updatedProduct.id);
        if (index != -1) {
          setState(() {
            _products[index] = updatedProduct;
          });
        }
      } else if (e.action == 'delete') {
        final deletedId = e.record!.id;
        setState(() {
          _products.removeWhere((p) => p.id == deletedId);
        });
      }
    });
  }

  Future<void> _fetchProducts() async {
    try {
      final result = await pb.collection('products').getList(
        page: _page,
        perPage: 20,
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

  Future<void> _deleteProduct(String productId) async {
    try {
      await pb.collection('products').delete(productId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product deleted successfully!')),
      );
    } on ClientException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting product: ${e.response}')),
      );
    }
  }

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Products'),
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
                  if (index == _products.length) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  final product = _products[index];
                  return ProductCard(
                    product: product,
                    onDelete: () => _deleteProduct(product.id),
                    onEdit: _fetchProducts,
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const CreateProductPage()),
          );
          _fetchProducts(); // Refresh after adding
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onDelete;
  final VoidCallback onEdit; // Add this callback

  const ProductCard({
    super.key,
    required this.product,
    this.onDelete,
    required this.onEdit, // Update the constructor
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => EditProductPage(product: product),
          ),
        );
        onEdit(); // Call the passed-in method to refresh the list
      },
      child: Card(
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
                  child: Container(
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(Icons.shopping_bag, size: 40, color: Colors.grey),
                    ),
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
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}