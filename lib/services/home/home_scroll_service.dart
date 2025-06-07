import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/artwork_provider.dart';
import '../../providers/auth_provider.dart';

class HomeScrollService {
  final ScrollController scrollController;
  bool _isLoadingMore = false;
  DateTime? _lastRequestTime;

  HomeScrollService(this.scrollController);

  void initializeScrollListener(BuildContext context) {
    scrollController.addListener(() => _onScroll(context));
  }

  void dispose() {
    scrollController.removeListener(() {});
    scrollController.dispose();
  }

  void _onScroll(BuildContext context) {
    if (!scrollController.hasClients) return;

    final artworkProvider = Provider.of<ArtworkProvider>(context, listen: false);
    final now = DateTime.now();
    
    if (_lastRequestTime != null &&
        now.difference(_lastRequestTime!).inMilliseconds < 500) {
      return;
    }

    if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent * 0.8 &&
        !_isLoadingMore &&
        artworkProvider.hasMoreToLoad) {
      _isLoadingMore = true;
      _lastRequestTime = now;

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.user != null) {
        artworkProvider
            .loadStillToCollectArtworks(
          userId: authProvider.user!.id,
          refresh: false,
        )
            .then((_) {
          _isLoadingMore = false;
        });
      } else {
        _isLoadingMore = false;
      }
    }
  }

  void scrollToTop() {
    scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }
}