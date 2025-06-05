import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import '../../utils/constants.dart';

class WhiteHeaderContainer extends StatefulWidget {
  final String title;
  final String subtitle;
  final double height;
  final Widget? bottomWidget;
  final double spaceBetweenTitleSubtitle;
  final double topPadding;

  const WhiteHeaderContainer({
    super.key,
    required this.title,
    required this.subtitle,
    required this.height,
    this.bottomWidget,
    this.spaceBetweenTitleSubtitle = 16.0,
    this.topPadding = 20.0,
  });
  
  @override
  State<WhiteHeaderContainer> createState() => _WhiteHeaderContainerState();
}

class _WhiteHeaderContainerState extends State<WhiteHeaderContainer> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    
    // Create animations
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut)
    );
    
    _slideAnimation = Tween<Offset>(begin: const Offset(0.0, 0.05), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut)
    );
    
    // Start animation immediately for first display
    _animationController.forward();
  }
  
  @override
  void didUpdateWidget(WhiteHeaderContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // If title or subtitle changed, trigger animation
    if (oldWidget.title != widget.title || oldWidget.subtitle != widget.subtitle) {
      // Reset and start animation
      _animationController.reset();
      _animationController.forward();
    }
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              // Explicit container for the image size
              width: MediaQuery.of(context).size.width,
              height: widget.height + 85,
              child: Image.asset(
                'assets/images/Union.png',
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
            ),
          ),
          // Content on top of the image
          SizedBox(
            height: widget.height,
            width: double.infinity,
            child: SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),
                  // Animated title
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                    ),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: AutoSizeText(
                          widget.title,
                          style: Theme.of(context).textTheme.headlineMedium,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          minFontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: widget.spaceBetweenTitleSubtitle),
                  // Animated subtitle
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 39.0,
                    ),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: AutoSizeText(
                          widget.subtitle,
                          style: AppTextStyles.subtitleStyle,
                          textAlign: TextAlign.center,
                          maxLines: 4,
                          minFontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(flex: 3),
                  if (widget.bottomWidget != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: widget.bottomWidget!,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
