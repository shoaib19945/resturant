import 'package:flutter/material.dart';
import '../models/restaurant.dart';


class RestaurantCard extends StatelessWidget {
  final Restaurant restaurant;
  final VoidCallback onTap;

  const RestaurantCard({
    super.key,
    required this.restaurant,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;

    return Semantics(
      label: '${restaurant.name} restaurant card',
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 2,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // restaurant cover image
              _buildImage(screenWidth),
              // info section
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildNameRow(theme),
                    const SizedBox(height: 6),
                    _buildInfoChips(theme),
                    if (restaurant.categoryNames.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      _buildCategories(theme),
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

  Widget _buildImage(double screenWidth) {
    return Stack(
      children: [
        Hero(
          tag: 'restaurant_img_${restaurant.id}',
          child: SizedBox(
            width: double.infinity,
            height: screenWidth * 0.45,
            child: restaurant.image.isNotEmpty
                ? Image.network(
                    restaurant.image,
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
        ),
        // open / closed badge
        Positioned(
          top: 12,
          left: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: restaurant.isOpen ? Colors.green : Colors.red.shade400,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              restaurant.isOpen ? 'Open' : 'Closed',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        // verified badge
        if (restaurant.livelongVerified)
          Positioned(
            top: 12,
            right: 12,
            child: Tooltip(
              message: 'Verified restaurant',
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.verified,
                  color: Colors.blue,
                  size: 18,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildNameRow(ThemeData theme) {
    return Row(
      children: [
        // small logo
        if (restaurant.logo.isNotEmpty)
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              restaurant.logo,
              width: 36,
              height: 36,
              fit: BoxFit.cover,
              errorBuilder: (ctx, err, stack) => const SizedBox(width: 36),
            ),
          ),
        if (restaurant.logo.isNotEmpty) const SizedBox(width: 10),
        Expanded(
          child: Text(
            restaurant.name,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        // rating
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.amber.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.star, size: 16, color: Colors.amber.shade700),
              const SizedBox(width: 3),
              Text(
                restaurant.rating.toStringAsFixed(1),
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.amber.shade800,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoChips(ThemeData theme) {
    return Wrap(
      spacing: 12,
      runSpacing: 4,
      children: [
        _iconText(
          Icons.delivery_dining,
          '${restaurant.deliveryTime} min',
          theme,
        ),
        _iconText(
          Icons.location_on_outlined,
          '${restaurant.distance.toStringAsFixed(1)} km',
          theme,
        ),
        _iconText(
          Icons.monetization_on_outlined,
          'Min ${restaurant.minimumOrderValue.toStringAsFixed(0)} KD',
          theme,
        ),
        if (restaurant.isBusy)
          _iconText(Icons.schedule, 'Busy', theme, color: Colors.orange),
      ],
    );
  }

  Widget _iconText(IconData icon, String text, ThemeData theme,
      {Color? color}) {
    final c = color ?? theme.colorScheme.onSurfaceVariant;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: c),
        const SizedBox(width: 3),
        Text(
          text,
          style: theme.textTheme.bodySmall?.copyWith(color: c),
        ),
      ],
    );
  }

  Widget _buildCategories(ThemeData theme) {
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: restaurant.categoryNames.map((cat) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            cat,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
        );
      }).toList(),
    );
  }
}
