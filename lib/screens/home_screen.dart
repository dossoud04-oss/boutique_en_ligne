import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../widgets/product_card.dart';
import '../widgets/banner_carousel.dart';
import '../widgets/category_bar.dart';
import '../widgets/product_skeleton.dart';
import '../providers/cart_provider.dart';
import '../theme/app_theme.dart';
import '../utils/responsive.dart';
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
  String _selectedCategory = 'Tous';
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

  void _applyFilters() {
    setState(() {
      _filteredProducts = _products.where((p) {
        final matchesSearch = _searchController.text.isEmpty ||
            p.name.toLowerCase().contains(_searchController.text.toLowerCase());
        final matchesCategory = _selectedCategory == 'Tous' ||
            (p.categoryName ?? '').toLowerCase() == _selectedCategory.toLowerCase();
        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: _fetchProducts,
        color: AppColors.primary,
        child: CustomScrollView(
          slivers: [
            // --- APPBAR RESPONSIVE ---
            SliverAppBar(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              pinned: true,
              floating: true,
              elevation: 0,
              expandedHeight: r.isMobile ? 0 : 0,
              title: Row(
                children: [
                  Icon(Icons.storefront, size: r.fontSize(26)),
                  SizedBox(width: r.space(8)),
                  Text(
                    "Kado Boutique",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: r.fontSize(20),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(Icons.notifications_outlined, size: r.fontSize(24)),
                    onPressed: () {},
                  ),
                ],
              ),
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(r.isMobile ? 60 : 70),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(r.space(12), 0, r.space(12), r.space(12)),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (_) => _applyFilters(),
                    style: TextStyle(fontSize: r.fontSize(14)),
                    decoration: InputDecoration(
                      hintText: "Rechercher un produit...",
                      prefixIcon: Icon(Icons.search, color: AppColors.textSecondary, size: r.fontSize(22)),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.symmetric(vertical: r.space(4)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(r.space(12)),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // --- BANNIÈRE ---
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(0, 16, 0, 8),
                child: BannerCarousel(),
              ),
            ),

            // --- TITRE CATÉGORIES ---
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(r.space(16), r.space(16), r.space(16), r.space(8)),
                child: Text(
                  "Catégories",
                  style: TextStyle(
                    fontSize: r.fontSize(18),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // --- CATÉGORIES ---
            SliverToBoxAdapter(
              child: CategoryBar(
                selectedCategory: _selectedCategory,
                onCategorySelected: (cat) {
                  setState(() => _selectedCategory = cat);
                  _applyFilters();
                },
              ),
            ),

            // --- TITRE PRODUITS ---
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(r.space(16), r.space(24), r.space(16), r.space(8)),
                child: Text(
                  "Nos produits",
                  style: TextStyle(
                    fontSize: r.fontSize(18),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // --- GRILLE DE PRODUITS RESPONSIVE ---
            if (_isLoading)
              const SliverToBoxAdapter(child: ProductSkeleton())
            else if (_error != null)
              SliverFillRemaining(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(r.space(24)),
                    child: Text(
                      "Erreur : $_error",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: r.fontSize(14),
                      ),
                    ),
                  ),
                ),
              )
            else if (_filteredProducts.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: r.fontSize(64), color: Colors.grey),
                      SizedBox(height: r.space(12)),
                      Text(
                        "Aucun produit trouvé",
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: r.fontSize(14),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: EdgeInsets.all(r.space(12)),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: r.gridColumns,
                    childAspectRatio: r.cardAspectRatio,
                    crossAxisSpacing: r.space(12),
                    mainAxisSpacing: r.space(12),
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
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
                              backgroundColor: AppColors.success,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(r.space(10)),
                              ),
                            ),
                          );
                        },
                      );
                    },
                    childCount: _filteredProducts.length,
                  ),
                ),
              ),

            SliverToBoxAdapter(child: SizedBox(height: r.space(24))),
          ],
        ),
      ),
    );
  }
}
