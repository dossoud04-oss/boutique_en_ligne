import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../theme/app_theme.dart';
import '../utils/responsive.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final formatPrice = NumberFormat('#,###', 'fr_FR');
    final r = Responsive.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Text("Détail", style: TextStyle(fontSize: r.fontSize(18))),
      ),
      body: ResponsiveContainer(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: r.isMobile ? 280 : 400,
                width: double.infinity,
                child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: product.imageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[100],
                          child: const Center(child: CircularProgressIndicator()),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[100],
                          child: Icon(
                            Icons.image_not_supported,
                            size: r.fontSize(80),
                            color: Colors.grey,
                          ),
                        ),
                      )
                    : Container(
                        color: Colors.grey[100],
                        child: Icon(
                          Icons.shopping_bag,
                          size: r.fontSize(100),
                          color: Colors.grey,
                        ),
                      ),
              ),
              Padding(
                padding: EdgeInsets.all(r.space(16)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (product.categoryName != null)
                      Chip(
                        label: Text(product.categoryName!),
                        backgroundColor: const Color(0xFFFFF3E0),
                      ),
                    SizedBox(height: r.space(8)),
                    Text(
                      product.name,
                      style: TextStyle(
                        fontSize: r.fontSize(22),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: r.space(8)),
                    Text(
                      '${formatPrice.format(product.price)} FCFA',
                      style: TextStyle(
                        fontSize: r.fontSize(26),
                        fontWeight: FontWeight.bold,
                        color: AppColors.price,
                      ),
                    ),
                    SizedBox(height: r.space(12)),
                    Text(
                      product.stock > 0
                          ? "En stock (${product.stock})"
                          : "Rupture de stock",
                      style: TextStyle(
                        color: product.stock > 0 ? Colors.green : Colors.red,
                        fontWeight: FontWeight.w500,
                        fontSize: r.fontSize(14),
                      ),
                    ),
                    Divider(height: r.space(30)),
                    Text(
                      "Description",
                      style: TextStyle(
                        fontSize: r.fontSize(16),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: r.space(8)),
                    Text(
                      product.description.isEmpty
                          ? "Aucune description."
                          : product.description,
                      style: TextStyle(
                        fontSize: r.fontSize(15),
                        height: 1.5,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: r.space(30)),
                    SizedBox(
                      width: double.infinity,
                      height: r.space(55),
                      child: ElevatedButton.icon(
                        onPressed: product.stock > 0
                            ? () {
                                context.read<CartProvider>().addProduct(product);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text("Produit ajouté au panier !"),
                                    backgroundColor: AppColors.success,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(r.space(10)),
                                    ),
                                  ),
                                );
                              }
                            : null,
                        icon: const Icon(Icons.shopping_cart),
                        label: Text(
                          "Ajouter au panier",
                          style: TextStyle(fontSize: r.fontSize(16)),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(r.space(10)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
