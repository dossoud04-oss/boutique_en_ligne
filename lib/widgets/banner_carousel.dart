import 'package:flutter/material.dart';
import '../utils/responsive.dart';

class BannerCarousel extends StatefulWidget {
  const BannerCarousel({super.key});

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  final PageController _controller = PageController(viewportFraction: 0.92);
  int _currentPage = 0;

  final List<Map<String, String>> _banners = [
    {
      'image': 'https://images.unsplash.com/photo-1607082348824-0a96f2a4b9da?w=800',
      'title': 'Soldes Exceptionnelles',
      'subtitle': '-50% sur tout',
    },
    {
      'image': 'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=800',
      'title': 'Nouveautés Mode',
      'subtitle': 'Découvrez la collection',
    },
    {
      'image': 'https://images.unsplash.com/photo-1519389950473-47ba0277781c?w=800',
      'title': 'High-Tech',
      'subtitle': 'Les meilleurs prix',
    },
  ];

  @override
  void initState() {
    super.initState();
    _startAutoPlay();
  }

  void _startAutoPlay() {
    Future.delayed(const Duration(seconds: 4), () {
      if (!mounted) return;
      final nextPage = (_currentPage + 1) % _banners.length;
      _controller.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
      _startAutoPlay();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);

    return Column(
      children: [
        SizedBox(
          height: r.bannerHeight,
          child: PageView.builder(
            controller: _controller,
            itemCount: _banners.length,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder: (context, index) {
              final banner = _banners[index];
              return Container(
                margin: EdgeInsets.symmetric(horizontal: r.space(4)),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(r.space(18)),
                  image: DecorationImage(
                    image: NetworkImage(banner['image']!),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.35),
                      BlendMode.darken,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: r.space(10),
                      offset: Offset(0, r.space(4)),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.all(r.space(20)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        banner['title']!,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: r.fontSize(22),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: r.space(6)),
                      Text(
                        banner['subtitle']!,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: r.fontSize(14),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(height: r.space(8)),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_banners.length, (index) {
            final isActive = index == _currentPage;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: EdgeInsets.symmetric(horizontal: r.space(4)),
              height: r.space(6),
              width: isActive ? r.space(20) : r.space(6),
              decoration: BoxDecoration(
                color: isActive ? const Color(0xFFFF6F00) : Colors.grey[300],
                borderRadius: BorderRadius.circular(r.space(3)),
              ),
            );
          }),
        ),
      ],
    );
  }
}
