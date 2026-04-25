import 'package:flutter/material.dart';

import '../core/api_client.dart';
import '../core/app_config.dart';
import '../models/restaurant.dart';
import '../models/restaurant_detail.dart';
import '../widgets/error_fallback.dart';

class RestaurantDetailScreen extends StatefulWidget {
  final Restaurant restaurant;

  const RestaurantDetailScreen({
    super.key,
    required this.restaurant,
  });

  @override
  State<RestaurantDetailScreen> createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen> {
  RestaurantDetail? _detail;
  bool _isLoading = true;
  Object? _error;
  late ApiClient _apiClient;
  int _selectedCategoryIndex = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final config = AppConfig.of(context);
    _apiClient = ApiClient(headers: config.headers);
    if (_detail == null && _error == null) {
      _fetchDetail();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _fetchDetail() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final raw = await _apiClient.getRestaurantDetail(widget.restaurant.id);
      setState(() {
        _detail = RestaurantDetail.fromJson(raw);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    // error state
    if (_error != null) {
      return SafeArea(
        child: Column(
          children: [
            _buildBackButton(context),
            Expanded(
              child: ErrorFallbackWidget(
                error: _error!,
                onRetry: _fetchDetail,
              ),
            ),
          ],
        ),
      );
    }

    // loading
    if (_isLoading || _detail == null) {
      return SafeArea(
        child: Column(
          children: [
            // still show the Hero image while loading
            _buildHeroImage(context),
            const Expanded(
              child: Center(child: CircularProgressIndicator()),
            ),
          ],
        ),
      );
    }

    // loaded — use LayoutBuilder for responsiveness
    return SafeArea(
      bottom: false,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 600;
          return CustomScrollView(
            slivers: [
              _buildSliverAppBar(context, isWide),
              SliverToBoxAdapter(child: _buildRestaurantInfo(context)),
              SliverToBoxAdapter(child: _buildWorkingHours(context)),
              SliverToBoxAdapter(child: _buildCategoryTabs(context)),
              _buildMenuGrid(context, isWide),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
              const SliverSafeArea(top: false, sliver: SliverToBoxAdapter(child: SizedBox.shrink())),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }

  Widget _buildHeroImage(BuildContext context) {
    return Hero(
      tag: 'restaurant_img_${widget.restaurant.id}',
      child: SizedBox(
        width: double.infinity,
        height: 220,
        child: widget.restaurant.image.isNotEmpty
            ? Image.network(
          widget.restaurant.image,
          fit: BoxFit.cover,
          errorBuilder: (ctx, err, stack) => Container(
            color: Colors.grey.shade200,
            child: const Icon(Icons.restaurant, size: 48),
          ),
        )
            : Container(
          color: Colors.grey.shade200,
          child: const Icon(Icons.restaurant, size: 48),
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, bool isWide) {
    final theme = Theme.of(context);
    final detail = _detail!;
    return SliverAppBar(
      expandedHeight: isWide ? 300 : 240,
      pinned: true,
      stretch: true,
      iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
      flexibleSpace: FlexibleSpaceBar(
        background: Hero(
          tag: 'restaurant_img_${widget.restaurant.id}',
          child: Stack(
            fit: StackFit.expand,
            children: [
              detail.image.isNotEmpty
                  ? Image.network(
                detail.image,
                fit: BoxFit.cover,
                errorBuilder: (ctx, err, stack) => Container(
                  color: Colors.grey.shade300,
                ),
              )
                  : Container(color: Colors.grey.shade300),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      theme.colorScheme.surface.withValues(alpha: 0.8),
                      Colors.transparent,
                      Colors.black87
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 16,
                left: 16,
                child: Row(
                  children: [
                    _statusChip(
                      detail.isOpen ? 'Open Now' : 'Closed',
                      detail.isOpen ? Colors.green : Colors.red,
                    ),
                    if (detail.livelongVerified) ...[
                      const SizedBox(width: 8),
                      _statusChip('Verified', Colors.blue),
                    ],
                    if (detail.isBusy) ...[
                      const SizedBox(width: 8),
                      _statusChip('Busy', Colors.orange),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildRestaurantInfo(BuildContext context) {
    final detail = _detail!;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // name + rating row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // logo
              if (detail.logo.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    detail.logo,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, stack) => Container(
                      width: 56,
                      height: 56,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.restaurant),
                    ),
                  ),
                ),
              if (detail.logo.isNotEmpty) const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      detail.name,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (detail.address != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 16,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                detail.address!.fullAddress,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // info row: rating, delivery, distance, min order
          _buildQuickInfo(theme, detail),

          const SizedBox(height: 16),

          // description
          if (detail.description.trim().isNotEmpty) ...[
            Text(
              'About',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              detail.description.trim(),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ],

          const SizedBox(height: 12),

          // contact info
          if (detail.supportPhone.isNotEmpty || detail.supportEmail.isNotEmpty)
            Wrap(
              spacing: 16,
              children: [
                if (detail.supportPhone.isNotEmpty)
                  _contactChip(
                    Icons.phone_outlined,
                    detail.supportPhone,
                    theme,
                  ),
                if (detail.supportEmail.isNotEmpty)
                  _contactChip(
                    Icons.email_outlined,
                    detail.supportEmail,
                    theme,
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildQuickInfo(ThemeData theme, RestaurantDetail detail) {
    return Row(
      children: [
        _infoTile(Icons.star, '${detail.rating}', 'Rating', theme),
        _divider(),
        _infoTile(
          Icons.delivery_dining,
          '${detail.deliveryTime} min',
          'Delivery',
          theme,
        ),
        _divider(),
        _infoTile(
          Icons.location_on,
          '${detail.distance.toStringAsFixed(1)} km',
          'Distance',
          theme,
        ),
        _divider(),
        _infoTile(
          Icons.monetization_on,
          '${detail.minimumOrderValue.toStringAsFixed(0)} KD',
          'Min Order',
          theme,
        ),
      ],
    );
  }

  Widget _infoTile(IconData icon, String value, String label, ThemeData theme) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(width: 1, height: 36, color: Colors.grey.shade300);
  }

  Widget _contactChip(IconData icon, String text, ThemeData theme) {
    return Chip(
      avatar: Icon(icon, size: 18),
      label: Text(
        text,
        style: theme.textTheme.bodySmall,
      ),
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildWorkingHours(BuildContext context) {
    final detail = _detail!;
    if (detail.workingDays.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        child: ExpansionTile(
          title: Text(
            'Working Hours',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          leading: const Icon(Icons.access_time),
          children: detail.workingDays.map((day) {
            // format the time string nicely (remove seconds)
            final start = day.startTime.substring(0, 5);
            final end = day.endTime.substring(0, 5);

            return ListTile(
              dense: true,
              title: Text(day.day),
              trailing: Text(
                '$start - $end',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCategoryTabs(BuildContext context) {
    final detail = _detail!;
    if (detail.itemCategories.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Menu',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          // horizontal scrollable category tabs
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: detail.itemCategories.length,
              itemBuilder: (ctx, i) {
                final cat = detail.itemCategories[i];
                final isSelected = i == _selectedCategoryIndex;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(cat.name),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategoryIndex = i;
                      });
                    },
                    selectedColor: theme.colorScheme.primaryContainer,
                    showCheckmark: false,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuGrid(BuildContext context, bool isWide) {
    final detail = _detail!;
    if (detail.itemList.isEmpty) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Center(child: Text('No menu items available')),
        ),
      );
    }

    // filter items by selected category
    List<MenuItem> filteredItems = detail.itemList;
    if (detail.itemCategories.isNotEmpty) {
      final selectedCat = detail.itemCategories[_selectedCategoryIndex];
      filteredItems = detail.itemList
          .where((item) => item.categoryName == selectedCat.name)
          .toList();
    }

    if (filteredItems.isEmpty) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Center(child: Text('No items in this category')),
        ),
      );
    }

    final crossAxisCount = isWide ? 3 : 2;

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.68,
        ),
        delegate: SliverChildBuilderDelegate(
              (ctx, index) => _buildMenuItemCard(ctx, filteredItems[index]),
          childCount: filteredItems.length,
        ),
      ),
    );
  }

  Widget _buildMenuItemCard(BuildContext context, MenuItem item) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        onTap: () => _showMenuItemDetails(context, item),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // item image
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  item.defaultImage.isNotEmpty
                      ? Image.network(
                    item.defaultImage,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, stack) => Container(
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.fastfood),
                    ),
                  )
                      : Container(
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.fastfood),
                  ),
                  // availability overlay
                  if (!item.isAvailable)
                    Container(
                      color: Colors.black45,
                      child: const Center(
                        child: Text(
                          'Unavailable',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // item info
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.shortDescription,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 11,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  // price row
                  Row(
                    children: [
                      Text(
                        '${item.finalPrice.toStringAsFixed(0)} KD',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      if (item.regularPrice > item.finalPrice) ...[
                        const SizedBox(width: 6),
                        Text(
                          item.regularPrice.toStringAsFixed(0),
                          style: theme.textTheme.bodySmall?.copyWith(
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  // nutrition info
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      _nutriBadge('${item.calories} cal', Colors.green, theme),
                      if (item.proteins != '0') _nutriBadge('${item.proteins}g P', Colors.blue, theme),
                      if (item.carbs != '0') _nutriBadge('${item.carbs}g C', Colors.orange, theme),
                      if (item.fats != '0') _nutriBadge('${item.fats}g F', Colors.red, theme),
                      Tooltip(
                        message: '${item.preparationTime} min prep time',
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.schedule,
                                size: 12,
                                color: theme.colorScheme.onSurfaceVariant),
                            const SizedBox(width: 2),
                            Text(
                              '${item.preparationTime}m',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _nutriBadge(String text, Color color, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  void _showMenuItemDetails(BuildContext context, MenuItem item) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.85,
          maxChildSize: 0.85,
          builder: (ctx, scrollController) {
            return Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: SafeArea(
                  top: false,
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Header with drag handle and close icon
                        Stack(
                          children: [
                            Align(
                              alignment: Alignment.center,
                              child: Container(
                                margin: const EdgeInsets.only(top: 16, bottom: 16),
                                width: 40,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                            Positioned(
                              right: 8,
                              top: 2,
                              child: IconButton(
                                icon: const Icon(Icons.close, color: Colors.grey),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ),
                          ],
                        ),
                        // Image
                        SizedBox(
                          height: 250,
                          child: item.images.isNotEmpty
                              ? PageView.builder(
                            itemCount: item.images.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Image.network(
                                  item.images[index],
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) => _buildFallbackImage(),
                                ),
                              );
                            },
                          )
                              : (item.defaultImage.isNotEmpty
                              ? Image.network(
                            item.defaultImage,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => _buildFallbackImage(),
                          )
                              : _buildFallbackImage()),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      item.name,
                                      style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${item.finalPrice.toStringAsFixed(1)} KD',
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      color: theme.colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'About',
                                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                item.description.isNotEmpty ? item.description : item.shortDescription,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'Nutritional Value',
                                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  _macroCircle(item.calories, 'Cal', Colors.green, theme),
                                  _macroCircle('${item.proteins}g', 'Protein', Colors.blue, theme),
                                  _macroCircle('${item.carbs}g', 'Carbs', Colors.orange, theme),
                                  _macroCircle('${item.fats}g', 'Fats', Colors.red, theme),
                                ],
                              ),
                              const SizedBox(height: 32),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ));
          },
        );
      },
    );
  }

  Widget _buildFallbackImage() {
    return Container(
      color: Colors.grey.shade200,
      child: const Center(child: Icon(Icons.fastfood, size: 48, color: Colors.grey)),
    );
  }

  Widget _macroCircle(String value, String label, Color color, ThemeData theme) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color.withValues(alpha: 0.3), width: 3),
          ),
          child: Center(
            child: Text(
              value,
              style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 13),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
