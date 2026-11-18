import 'dart:convert';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

/// Picks a profile picture and shrinks it to a small JPEG stored in the profile itself
/// (the free Spark plan has no Cloud Storage). Firestore rules allow up to 200,000 characters.
class PhotoService {
  static const maxDataUrlLength = 200000;

  final ImagePicker _picker = ImagePicker();

  /// A `data:image/jpeg;base64,...` picture, or null if the user cancelled.
  Future<String?> pickProfilePhoto() async {
    final file = await _picker.pickImage(source: ImageSource.gallery, maxWidth: 1024, maxHeight: 1024);
    if (file == null) return null;
    return toDataUrl(await file.readAsBytes());
  }

  /// Square-crops to 256 px and lowers JPEG quality until the result fits.
  static String toDataUrl(Uint8List bytes) {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) throw const FormatException('That file is not a picture SeatTap can read.');
    final square = img.copyResizeCropSquare(decoded, size: 256);
    for (final quality in [85, 70, 55, 40]) {
      final url = 'data:image/jpeg;base64,${base64Encode(img.encodeJpg(square, quality: quality))}';
      if (url.length <= maxDataUrlLength) return url;
    }
    throw const FormatException('That picture is too large. Try another one.');
  }
}
