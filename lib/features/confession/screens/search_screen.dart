import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:confess_nepal/core/theme/app_colors.dart';
import '../providers/confession_provider.dart';
import '../models/confession.dart';
import '../widgets/confession_card.dart';
import 'confession_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String _query = '';
  Timer? _debounce;
  List<Confession> _searchResults = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.isNotEmpty) {
        _performSearch(query);
      } else {
        setState(() {
          _searchResults = [];
          _query = '';
        });
      }
    });
    setState(() => _query = query);
  }

  Future<void> _performSearch(String query) async {
    setState(() => _isLoading = true);
    try {
      final repo = context.read<ConfessionProvider>().confessionRepo;
      final data = await repo.searchConfessions(query);
      final list = (data['confessions'] as List)
          .map((c) => Confession.fromMap(c as Map<String, dynamic>))
          .toList();
      
      if (mounted) {
        setState(() {
          _searchResults = list;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 40,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Container(
          height: 44,
          margin: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark 
                ? AppColors.backgroundSecondary 
                : AppColors.lightElevated,
            borderRadius: BorderRadius.circular(100),
          ),
          child: TextField(
            controller: _searchController,
            focusNode: _focusNode,
            onChanged: _onSearchChanged,
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Search confessions...',
              prefixIcon: const Icon(Icons.search_rounded, size: 18),
              suffixIcon: _query.isNotEmpty 
                  ? GestureDetector(
                      onTap: () {
                        _searchController.clear();
                        _onSearchChanged('');
                      },
                      child: const Icon(Icons.close_rounded, size: 18),
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
      ),
      body: _query.isEmpty
          ? _buildTrendingSuggestions()
          : _isLoading 
              ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
              : _searchResults.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final confession = _searchResults[index];
                        return ConfessionCard(
                          confession: confession,
                          index: index,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ConfessionDetailScreen(confession: confession),
                            ),
                          ),
                        );
                      },
                    ),
    );
  }

  Widget _buildTrendingSuggestions() {
    final suggestions = ['Kathmandu', 'Pokhara', 'Exams', 'Relationships', 'Regret', 'Love'];
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Top Searches', 
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: suggestions.map((tag) => GestureDetector(
              onTap: () {
                _searchController.text = tag;
                _onSearchChanged(tag);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
                ),
                child: Text('#$tag', style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.textSecondary
                    : AppColors.textSecondaryLight,
                fontSize: 13,
                fontWeight: FontWeight.w600)),
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔍', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          const Text('No confessions found',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          const Text('Try searching with different keywords',
              style: TextStyle(fontSize: 13)),
        ],
      ),
    );
  }
}
