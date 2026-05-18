import 'package:networking_game/core/constants/app_constants.dart';

class QrService {
  /// Generates a short QR string: TTL_GAME: followed by userId
  String generateQrData(String userId) {
    return '${AppConstants.qrPrefix}$userId';
  }

  /// Parses the QR string and returns the userId, or null if invalid.
  String? parseQrData(String data) {
    if (!data.startsWith(AppConstants.qrPrefix)) return null;
    final userId = data.substring(AppConstants.qrPrefix.length);
    if (userId.isEmpty) return null;
    return userId;
  }

  bool validateQrData(String data) {
    return parseQrData(data) != null;
  }
}
