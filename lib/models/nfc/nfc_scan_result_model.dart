class NfcScanResultModel {
  final String? artworkId;
  final String? artworkTitle;
  final String? artworkArtist;
  final String? pointsEarned;
  final Map<String, dynamic>? artworkData;
  final String message;
  final NfcScanStatus status;

  const NfcScanResultModel({
    this.artworkId,
    this.artworkTitle,
    this.artworkArtist,
    this.pointsEarned,
    this.artworkData,
    required this.message,
    required this.status,
  });

  factory NfcScanResultModel.fromApiResponse(
      Map<String, dynamic> response, String message) {
    final artworkData = response['artwork'] as Map<String, dynamic>?;

    return NfcScanResultModel(
      artworkId: response['artworkId']?.toString(),
      artworkTitle: artworkData?['title']?.toString(),
      artworkArtist: artworkData?['artist']?.toString(),
      pointsEarned: response['pointsEarned']?.toString(),
      artworkData: response,
      message: message,
      status: _getStatusFromResponse(response),
    );
  }

  factory NfcScanResultModel.error(String message,
      {bool isAlreadyCollected = false}) {
    return NfcScanResultModel(
      message: message,
      status: isAlreadyCollected
          ? NfcScanStatus.alreadyCollected
          : NfcScanStatus.error,
    );
  }

  static NfcScanStatus _getStatusFromResponse(Map<String, dynamic> response) {
    final status = response['status']?.toString();
    switch (status) {
      case 'Success':
        return NfcScanStatus.success;
      case 'AlreadyCollected':
        return NfcScanStatus.alreadyCollected;
      default:
        return NfcScanStatus.error;
    }
  }
}

enum NfcScanStatus { scanning, success, error, notSupported, alreadyCollected, canceled }
