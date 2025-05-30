import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import '../../utils/constants.dart';

class LandingModelViewer extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.gradientMiddle, // Corresponds to the background gradient
            AppColors.gradientEnd,
          ],
        ),
      ),
      child: ModelViewer(
        src: modelPath,
        alt: "3D Artwork",
        ar: false,
        autoRotate: false,
        autoRotateDelay: 0,
        cameraControls: true,
        disableZoom: true,
        // Custom camera angle for the table (last model)
        cameraOrbit: isTableModel
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
    );
  }
}
