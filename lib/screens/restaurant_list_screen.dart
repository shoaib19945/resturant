import 'dart:async';
import 'package:flutter/material.dart';
import '../core/api_client.dart';
import '../core/app_config.dart';
import '../models/restaurant.dart';
import '../widgets/restaurant_card.dart';
import '../widgets/error_fallback.dart';
import 'restaurant_detail_screen.dart';

class RestaurantListScreen extends StatefulWidget {
  const RestaurantListScreen({super.key});

  @override
  State<RestaurantListScreen> createState() => _RestaurantListScreenState();
}

class _RestaurantListScreenState extends State<RestaurantListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _debounceTimer;
  List<Restaurant> _restaurants = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  Object? _error;
  int _currentPage = 1;
  int _totalPages = 1;
  late ApiClient _apiClient;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final config = AppConfig.of(context);
    _apiClient = ApiClient(headers: config.headers);
    // load initial data
    if (_restaurants.isEmpty && _error == null && !_isLoading) {
      _fetchRestaurants(reset: true);
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (value != _query) {
        setState(() => _query = value);
        _fetchRestaurants(reset: true);
      }
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoadingMore && _currentPage <= _totalPages) {
        _fetchRestaurants(reset: false);
      }
    }
  }

  Future<void> _fetchRestaurants({required bool reset}) async {
    if (reset) {
      setState(() {
        _isLoading = true;
        _error = null;
        _currentPage = 1;
        _restaurants.clear();
      });
    } else {
      setState(() => _isLoadingMore = true);
    }

    try {
      final response = await _apiClient.searchRestaurants(
        query: _query,
        page: _currentPage,
      );

      final rawList = response['data']?['restaurants'] as List? ?? [];
      final newItems = rawList
          .whereType<Map<String, dynamic>>()
          .map(Restaurant.fromJson)
          .toList();

      setState(() {
        _restaurants.addAll(newItems);
        _totalPages = response['data']?['totalPages'] ?? _totalPages;
        _isLoading = false;
        _isLoadingMore = false;
        _currentPage++;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
        _error = e;
      });
    }
  }

  void _openDetail(Restaurant restaurant) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => RestaurantDetailScreen(
          restaurant: restaurant
        ),
      ),
    );
  }

  Widget _buildSearchHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Restaurants',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Find your favorite place to eat',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 14),
          // search input
          Semantics(
            label: 'Search restaurants',
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search restaurants...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _onSearchChanged('');
                  },
                )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.5),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_error != null && _restaurants.isEmpty) {
      return ErrorFallbackWidget(
        error: _error!,
        onRetry: () => _fetchRestaurants(reset: true),
      );
    }

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_restaurants.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.restaurant_outlined,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 12),
            Text(
              'No restaurants found',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (_query.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'Try a different search term',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                ),
              ),
            ],
          ],
        ),
      );
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: RefreshIndicator(
        onRefresh: () => _fetchRestaurants(reset: true),
        child: ListView.builder(
          key: ValueKey(_query),
          controller: _scrollController,
          padding: const EdgeInsets.only(top: 8, bottom: 16),
          itemCount: _restaurants.length + (_isLoadingMore ? 1 : 0),
          itemBuilder: (ctx, index) {
            // show loading spinner at bottom for pagination
            if (index == _restaurants.length) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            final restaurant = _restaurants[index];
            return FadeTransition(
              opacity: AlwaysStoppedAnimation(1.0),
              child: RestaurantCard(
                restaurant: restaurant,
                onTap: () => _openDetail(restaurant),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchHeader(theme),
            Expanded(child: _buildBody(theme)),
          ],
        ),
      ),
    );
  }

}
