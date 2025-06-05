import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/artwork_provider.dart';
import '../../services/home/home_scroll_service.dart';
import '../../widgets/home/home_header_widget.dart';
import '../../widgets/home/recently_collected_section.dart';
import '../../widgets/home/still_to_collect_section.dart';
import '../../utils/home_options_helper.dart';
import '../../utils/constants.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();
  late HomeScrollService _scrollService;

  @override
  void initState() {
    super.initState();
    _scrollService = HomeScrollService(_scrollController);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final artworkProvider = Provider.of<ArtworkProvider>(context, listen: false);
      
      if (authProvider.user != null) {
        artworkProvider.loadStillToCollectArtworks(
          userId: authProvider.user!.id,
          refresh: true,
        );
      }
      
      _scrollService.initializeScrollListener(context);
    });
  }

  @override
  void dispose() {
    _scrollService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, AppColors.homeBackgroundEnd],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HomeHeaderWidget(
                scrollController: _scrollController,
                onOptionsPressed: () => HomeOptionsHelper.showOptionsMenu(context),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: EdgeInsets.zero,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 0),
                      RecentlyCollectedSection(),
                      const SizedBox(height: 5),
                      const StillToCollectSection(),
                      const SizedBox(height: 1),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
