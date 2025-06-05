import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import '../../utils/constants.dart';

class LandingModelViewer extends StatefulWidget {
  final String modelPath;
  final bool isTableModel;
  final double height;

  const LandingModelViewer({
    super.key,
    required this.modelPath,
    required this.isTableModel,
    required this.height,
  });

  @override
  State<LandingModelViewer> createState() => _LandingModelViewerState();
}

class _LandingModelViewerState extends State<LandingModelViewer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    // Create animations
    _fadeAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.7, curve: Curves.easeInOut),
    ));

    _scaleAnimation =
        Tween<double>(begin: 0.95, end: 1.0).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    // Start animation after a short delay to ensure the model is loaded
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _animationController.forward();
      }
    });
  }

  @override
  void didUpdateWidget(LandingModelViewer oldWidget) {
    super.didUpdateWidget(oldWidget);

    // If model path changed, trigger animation again
    if (oldWidget.modelPath != widget.modelPath) {
      _animationController.reset();
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          _animationController.forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors
                    .gradientMiddle, // Corresponds to the background gradient
                AppColors.gradientEnd,
              ],
            ),
          ),
          child: ModelViewer(
            src: widget.modelPath,
            alt: "3D Artwork",
            ar: false,
            autoRotate: false,
            autoRotateDelay: 0,
            cameraControls: true,
            disableZoom: true,
            // Custom camera angle for the table (last model)
            cameraOrbit: widget.isTableModel
                ? "90deg 75deg 150%" // Rotation to see the table face
                : "0deg 75deg 150%", // Standard angle for other models
            minCameraOrbit: "auto 0deg 150%",
            maxCameraOrbit: "auto auto 150%",
            backgroundColor: Colors.transparent,
            shadowIntensity: 0,
            loading: Loading.eager,
            relatedCss: '''
              model-viewer {
                --progress-bar-height: 0px;
                --progress-bar-color: transparent;
                --progress-mask: transparent;
                --poster-color: transparent;
              }
            ''',
          ),
        ),
      ),
    );
  }
}
