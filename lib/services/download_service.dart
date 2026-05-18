import 'dart:typed_data';
import 'package:networking_game/services/download_service_stub.dart'
    if (dart.library.html) 'package:networking_game/services/download_service_web.dart';

class DownloadService {
  static void downloadBytes(Uint8List bytes, String fileName) {
    downloadBytesImpl(bytes, fileName);
  }
}
