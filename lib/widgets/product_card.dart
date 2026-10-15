import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../models/product.dart';
import '../theme/app_theme.dart';
import '../utils/responsive.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final VoidCallback onAddToCart;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    final formatPrice = NumberFormat('#,###', 'fr_FR');
    final r = Responsive.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(r.space(16)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: r.space(12),
              offset: Offset(0, r.space(4)),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 1.0,
                  child: ClipRRect(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(r.space(16)),
                    ),
                    child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: product.imageUrl!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            placeholder: (context, url) => Container(
                              color: Colors.grey[100],
                              child: const Center(
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: Colors.grey[100],
                              child: Icon(
                                Icons.image_not_supported,
                                size: r.fontSize(50),
                                color: Colors.grey,
                              ),
                            ),
                          )
                        : Container(
                            color: Colors.grey[100],
                            child: Icon(
                              Icons.shopping_bag_outlined,
                              size: r.fontSize(60),
                              color: Colors.grey,
                            ),
                          ),
                  ),
                ),
                if (product.stock > 0 && product.stock < 5)
                  Positioned(
                    top: r.space(8),
                    left: r.space(8),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: r.space(8),
                        vertical: r.space(4),
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(r.space(8)),
                      ),
                      child: Text(
                        "Plus que ${product.stock}",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: r.fontSize(10),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                if (product.stock == 0)
                  Positioned(
                    top: r.space(8),
                    right: r.space(8),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: r.space(8),
                        vertical: r.space(4),
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(r.space(8)),
                      ),
                      child: Text(
                        "Rupture",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: r.fontSize(10),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(r.space(10)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (product.categoryName != null)
                    Text(
                      product.categoryName!.toUpperCase(),
                      style: TextStyle(
                        fontSize: r.fontSize(9),
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  SizedBox(height: r.space(4)),
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: r.fontSize(14),
                      color: Colors.black87,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: r.space(6)),
                  Text(
                    '${formatPrice.format(product.price)} FCFA',
                    style: TextStyle(
                      color: AppColors.price,
                      fontWeight: FontWeight.bold,
                      fontSize: r.fontSize(16),
                    ),
                  ),
                  SizedBox(height: r.space(8)),
                  SizedBox(
                    width: double.infinity,
                    height: r.space(34),
                    child: ElevatedButton(
                      onPressed: product.stock > 0 ? onAddToCart : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey[300],
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(r.space(8)),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        product.stock > 0 ? "Ajouter" : "Indisponible",
                        style: TextStyle(
                          fontSize: r.fontSize(12),
                          fontWeight: FontWeight.w600,
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
    );
  }
}
