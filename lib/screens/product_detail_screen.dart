// lib/screens/product_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../main.dart';
import '../models/product.dart';
import '../widgets/quantity_stepper.dart';
import 'write_review_screen.dart';
import 'checkout_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen>
    with TickerProviderStateMixin {
  final PageController _imagePageController = PageController();
  late TabController _tabController;
  bool _isFavorited = false;

  late final List<String> _productImages;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _isFavorited = widget.product.isFavorite;

    _productImages = [
      widget.product.imagePath,
      'assets/images/tomatoes.jpg',
      'assets/images/avocado.jpg',
      'assets/images/brocoli.jpg',
    ];
  }

  @override
  void dispose() {
    _imagePageController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImageSlider(context),
                _buildProductInfo(),
                const SizedBox(height: 24),
                _buildTabs(),
                const SizedBox(height: 120),
              ],
            ),
          ),
          _buildBottomActionButtons(),
        ],
      ),
    );
  }

  // ================= IMAGE SLIDER =================
  Widget _buildImageSlider(BuildContext context) {
    return SizedBox(
      height: 300,
      child: Stack(
        children: [
          PageView.builder(
            controller: _imagePageController,
            itemCount: _productImages.length,
            itemBuilder: (context, index) {
              return Image.asset(
                _productImages[index],
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey[200],
                  child: const Icon(Icons.broken_image,
                      size: 50, color: Colors.grey),
                ),
              );
            },
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildTransparentButton(
                      Icons.arrow_back, () => Navigator.pop(context)),
                  _buildTransparentButton(Icons.share, () {}),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: SmoothPageIndicator(
                controller: _imagePageController,
                count: _productImages.length,
                effect: const WormEffect(
                  dotColor: Colors.white54,
                  activeDotColor: Colors.white,
                  dotHeight: 8,
                  dotWidth: 8,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransparentButton(IconData icon, VoidCallback onPressed) {
    return CircleAvatar(
      backgroundColor: Colors.black.withOpacity(0.3),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: onPressed,
      ),
    );
  }

  // ================= PRODUCT INFO =================
  Widget _buildProductInfo() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('FRUITS',
              style: TextStyle(color: kTextLightColor, fontSize: 16)),
          const SizedBox(height: 8),
          Text(
            widget.product.name,
            style: const TextStyle(
              color: kTextColor,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '\$${widget.product.price}',
                style: const TextStyle(
                  color: kPrimaryColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const QuantityStepper(initialValue: 1),
            ],
          ),
        ],
      ),
    );
  }

  // ================= TAB =================
  Widget _buildTabs() {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          labelColor: kPrimaryColor,
          unselectedLabelColor: kTextLightColor,
          indicatorColor: kPrimaryColor,
          tabs: const [
            Tab(text: 'Description'),
            Tab(text: 'Review'),
            Tab(text: 'Discussion'),
          ],
        ),
        const Divider(height: 1),
        SizedBox(
          height: 200,
          child: TabBarView(
            controller: _tabController,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  widget.product.description,
                  style: const TextStyle(
                    color: kTextLightColor,
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
              ),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            WriteReviewScreen(product: widget.product),
                      ),
                    );
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('WRITE A REVIEW'),
                ),
              ),
              const Center(child: Text('Discussion will be shown here')),
            ],
          ),
        ),
      ],
    );
  }

  // ================= BOTTOM BUTTON =================
  Widget _buildBottomActionButtons() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(20).copyWith(bottom: 30),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -5))
          ],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => setState(() => _isFavorited = !_isFavorited),
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: _isFavorited
                      ? Colors.pink.withOpacity(0.1)
                      : Colors.grey[100],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  _isFavorited ? Icons.favorite : Icons.favorite_border,
                  color: _isFavorited ? Colors.pink : kTextColor,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const CheckoutScreen()),
                  );
                },
                child:
                    Text('ADD TO CART \$${widget.product.price}'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
