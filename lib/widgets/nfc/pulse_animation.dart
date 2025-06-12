import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class PulseAnimation extends StatefulWidget {
  const PulseAnimation({super.key});

  @override
  State<PulseAnimation> createState() => _PulseAnimationState();
}

class _PulseAnimationState extends State<PulseAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation1;
  late Animation<double> _animation2;
  late Animation<double> _animation3;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    // Create three animations with different delays for a dynamic effect
    _animation1 = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 1.0, curve: Curves.easeOut),
      ),
    );

    _animation2 = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    _animation3 = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Outer wave circle
            _buildPulseCircle(_animation3, 1.0, 0.0),
            
            // Middle wave circle
            _buildPulseCircle(_animation2, 0.85, 0.05),
            
            // Inner wave circle
            _buildPulseCircle(_animation1, 0.7, 0.1),
            
            // Center NFC icon
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.circularGradientStart,
                    AppColors.circularGradientEnd
                  ],
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.nfc,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPulseCircle(Animation<double> animation, double maxOpacity, double minOpacity) {
    final double size = 80 + (100 * animation.value);
    
    return Opacity(
      opacity: maxOpacity - (animation.value * (maxOpacity - minOpacity)),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.purpleIndicator,
            width: 2,
          ),
        ),
      ),
    );
  }
}
