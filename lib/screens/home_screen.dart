import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../widgets/product_card.dart';
import '../providers/cart_provider.dart';
import 'product_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  bool _isLoading = true;
  String? _error;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    try {
      final data = await Supabase.instance.client
          .from('products')
          .select('*, categories(name)')
          .eq('is_active', true);

      final products = (data as List).map((e) => Product.fromMap(e)).toList();

      setState(() {
        _products = products;
        _filteredProducts = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _search(String query) {
    setState(() {
      _filteredProducts = _products
          .where((p) => p.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  // --- FONCTION QUI CALCULE LE NOMBRE DE COLONNES SELON LA LARGEUR DE L'ÉCRAN ---
  int _getCrossAxisCount(double width) {
    if (width < 500) {
      return 2; // Mobile : 2 colonnes
    } else if (width < 900) {
      return 3; // Tablette : 3 colonnes
    } else if (width < 1400) {
      return 4; // Petit écran : 4 colonnes
    } else {
      return 5; // Grand écran : 5 colonnes
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF6F00),
        foregroundColor: Colors.white,
        title: const Text(
          "Ma Boutique",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          // --- BARRE DE RECHERCHE ---
          Container(
            color: const Color(0xFFFF6F00),
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: TextField(
              controller: _searchController,
              onChanged: _search,
              decoration: InputDecoration(
                hintText: "Rechercher un produit...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          
          // --- GRILLE DE PRODUITS RESPONSIVE ---
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            "Erreur : $_error",
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : _filteredProducts.isEmpty
                        ? const Center(child: Text("Aucun produit trouvé"))
                        : LayoutBuilder(
                            builder: (context, constraints) {
                              final crossAxisCount = _getCrossAxisCount(constraints.maxWidth);
                              
                              // Calcul du ratio pour que les cartes ne soient ni trop larges ni trop hautes
                              final childAspectRatio = crossAxisCount == 2
                                  ? 0.68
                                  : crossAxisCount == 3
                                      ? 0.72
                                      : 0.75;

                              return GridView.builder(
                                padding: const EdgeInsets.all(10),
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  childAspectRatio: childAspectRatio,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                ),
                                itemCount: _filteredProducts.length,
                                itemBuilder: (context, index) {
                                  final product = _filteredProducts[index];
                                  return ProductCard(
                                    product: product,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => ProductDetailScreen(product: product),
                                        ),
                                      );
                                    },
                                    onAddToCart: () {
                                      context.read<CartProvider>().addProduct(product);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text("${product.name} ajouté au panier"),
                                          duration: const Duration(seconds: 1),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    },
                                  );
                                },
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}