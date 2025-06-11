import 'package:flutter/material.dart';
import '../../widgets/common/page_indicator_widget.dart';
import 'leaderboard_page.dart';
import 'home_page.dart';
import 'my_collection_page.dart';

class MainContainer extends StatefulWidget {
  const MainContainer({super.key});

  @override
  State<MainContainer> createState() => _MainContainerState();
}

class _MainContainerState extends State<MainContainer> {
  // Initialize PageController to show HomePage (index 1) by default
  final PageController _pageController = PageController(initialPage: 1);
  // Set current page index to reflect HomePage as the default
  int _currentPageIndex = 1;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _currentPageIndex = index;
            });
          },
          children: const [
            LeaderboardPage(),
            HomePage(),
            MyCollectionPage(),
          ],
        ),
        // Page indicator at the bottom of the screen
        Positioned(
          bottom: 10,
          left: 0,
          right: 0,
          child: PageIndicator(
            totalPages: 3,
            currentPage: _currentPageIndex,
            onPageTapped: (index) {
              _pageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
          ),
        ),
      ],
    );
  }
}
