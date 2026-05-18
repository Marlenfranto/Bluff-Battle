import 'dart:typed_data';

void downloadBytesImpl(Uint8List bytes, String fileName) {
  // No-op on non-web platforms.
  // For mobile, use path_provider + share_plus to save/share files.
}
