import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../../../../../di/injector.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_variant.dart';
import '../bloc/product_detail/product_detail_bloc.dart';
import '../bloc/product_detail/product_detail_event.dart';
import '../bloc/product_detail/product_detail_state.dart';
import '../widgets/product_gallery.dart';
import '../widgets/product_price.dart';
import '../widgets/product_variant_selector.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;

  const ProductDetailScreen({
    super.key,
    required this.productId,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late final ProductDetailBloc _bloc;
  ProductVariant? _selectedVariant;

  @override
  void initState() {
    super.initState();
    _bloc = sl<ProductDetailBloc>()
      ..add(ProductDetailRequested(widget.productId));
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: BlocBuilder<ProductDetailBloc, ProductDetailState>(
        builder: (context, state) {
          final product = state is ProductDetailLoaded ? state.product : null;
          final selectedVariant =
          product == null ? null : _selectedVariantFor(product);
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black87,
              elevation: 0,
              title: Text(
                product?.title ?? 'Product',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            body: _buildBody(state, selectedVariant),
            bottomNavigationBar: product == null
                ? null
                : _ProductActionBar(
              product: product,
              selectedVariant: selectedVariant,
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(
      ProductDetailState state,
      ProductVariant? selectedVariant,
      ) {
    if (state is ProductDetailLoading || state is ProductDetailInitial) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is ProductDetailFailure) {
      return _StateMessage(
        icon: Icons.error_outline,
        title: state.message,
        onRetry: () => _bloc.add(ProductDetailRequested(widget.productId)),
      );
    }

    if (state is! ProductDetailLoaded) {
      return const SizedBox.shrink();
    }

    final product = state.product;
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: ProductGallery(product: product),
        ),
        SliverToBoxAdapter(
          child: _ProductInfo(
            product: product,
            selectedVariant: selectedVariant,
          ),
        ),
        if (product.variants.isNotEmpty)
          SliverToBoxAdapter(
            child: ProductVariantSelector(
              variants: product.variants,
              selectedVariant: selectedVariant,
              currency: product.currency,
              onChanged: (variant) {
                setState(() => _selectedVariant = variant);
              },
            ),
          ),
        SliverToBoxAdapter(
          child: _DescriptionSection(product: product),
        ),
        const SliverToBoxAdapter(
          child: SizedBox(height: 96),
        ),
      ],
    );
  }

  ProductVariant? _selectedVariantFor(Product product) {
    if (product.variants.isEmpty) return null;

    final current = _selectedVariant;
    if (current != null &&
        current.productId == product.id &&
        product.variants.any((variant) => variant.id == current.id)) {
      return current;
    }

    for (final variant in product.variants) {
      if (variant.isActive && variant.isInStock) return variant;
    }

    for (final variant in product.variants) {
      if (variant.isActive) return variant;
    }

    return product.variants.first;
  }
}

class _ProductInfo extends StatelessWidget {
  final Product product;
  final ProductVariant? selectedVariant;

  const _ProductInfo({
    required this.product,
    required this.selectedVariant,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProductPrice(
            product: product,
            variant: selectedVariant,
            fontSize: 22,
          ),
          if (selectedVariant?.compareAtPrice != null &&
              selectedVariant!.compareAtPrice! > selectedVariant!.price) ...[
            const SizedBox(height: 3),
            Text(
              ProductPrice.formatAmount(
                selectedVariant!.compareAtPrice!,
                product.currency,
              ),
              style: const TextStyle(
                color: Colors.black38,
                decoration: TextDecoration.lineThrough,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(height: AppSizes.sm),
          Text(
            product.title,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 20,
              height: 1.25,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSizes.md),
          Row(
            children: [
              const Icon(Icons.storefront_outlined, size: 18),
              const SizedBox(width: AppSizes.xs),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    context.push('/shop/${product.shopId}');
                  },
                  child: Text(
                    product.shopName ?? 'Shop',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSizes.sm),
              Text(
                'Đã bán ${product.soldCount}',
                style: const TextStyle(color: Colors.black54),
              ),
            ],
          ),
          if (product.brand != null && product.brand!.trim().isNotEmpty) ...[
            const SizedBox(height: AppSizes.sm),
            GestureDetector(
              onTap: () {
                context.push('/shop/${product.shopId}');
              },
              child: Row(
                children: [
                  const Icon(Icons.verified_outlined, color: Color(0xFFEE4D2D), size: 18),
                  const SizedBox(width: AppSizes.xs),
                  const Text(
                    'Thương hiệu: ',
                    style: TextStyle(color: Colors.black54, fontSize: 14),
                  ),
                  Text(
                    product.brand!,
                    style: const TextStyle(
                      color: Color(0xFFEE4D2D),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppSizes.sm),
          Row(
            children: [
              const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
              const SizedBox(width: AppSizes.xs),
              Text(
                '${product.ratingAvg.toStringAsFixed(1)} (${product.ratingCount})',
                style: const TextStyle(color: Colors.black54),
              ),
              const SizedBox(width: AppSizes.lg),
              Icon(
                _isInStock
                    ? Icons.inventory_2_outlined
                    : Icons.remove_shopping_cart_outlined,
                color: _isInStock ? Colors.green : AppColors.error,
                size: 18,
              ),
              const SizedBox(width: AppSizes.xs),
              Text(
                _isInStock ? '$_stockQty sản phẩm có sẵn' : 'Hết hàng',
                style: TextStyle(
                  color: _isInStock ? Colors.green : AppColors.error,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  int get _stockQty => selectedVariant?.stockQty ?? product.stockTotal;

  bool get _isInStock => _stockQty > 0;
}

class _DescriptionSection extends StatelessWidget {
  final Product product;

  const _DescriptionSection({required this.product});

  @override
  Widget build(BuildContext context) {
    final description = product.description?.trim();
    if (description == null || description.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.xl,
        0,
        AppSizes.xl,
        AppSizes.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 1),
          const SizedBox(height: AppSizes.xl),
          const Text(
            'Mô tả sản phẩm',
            style: TextStyle(
              color: Colors.black87,
              fontSize: AppSizes.fontXl,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            description,
            style: const TextStyle(
              color: Colors.black87,
              height: 1.45,
              fontSize: AppSizes.fontMd,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductActionBar extends StatelessWidget {
  final Product product;
  final ProductVariant? selectedVariant;

  const _ProductActionBar({
    required this.product,
    required this.selectedVariant,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.all(AppSizes.md),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFEDEDED))),
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _canBuy ? () {
                  // TODO: Thêm chức năng giỏ hàng ở Sprint sau
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Chức năng giỏ hàng sẽ được cập nhật sau')),
                  );
                } : null,
                icon: const Icon(Icons.add_shopping_cart_outlined),
                label: const Text('Thêm vào giỏ'),
              ),
            ),
            const SizedBox(width: AppSizes.md),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _canBuy ? () {
                  // TODO: Thêm chức năng mua ngay ở Sprint sau
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Chức năng mua ngay sẽ được cập nhật sau')),
                  );
                } : null,
                icon: const Icon(Icons.flash_on_rounded),
                label: const Text('Mua ngay'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool get _canBuy {
    if (product.variants.isEmpty) return product.isInStock;
    return selectedVariant != null &&
        selectedVariant!.isActive &&
        selectedVariant!.isInStock;
  }
}

class _StateMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onRetry;

  const _StateMessage({
    required this.icon,
    required this.title,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.textMuted, size: 42),
            const SizedBox(height: AppSizes.md),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: AppSizes.md),
            TextButton(
              onPressed: onRetry,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }
}
