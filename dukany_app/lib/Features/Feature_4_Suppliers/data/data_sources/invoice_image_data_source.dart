import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../../core/utils/api_service.dart';
import '../../../../core/utils/app_config.dart';

/// Takes the invoice photo, keeps a permanent copy on the device,
/// and gives a temporary link for photos that only exist in Supabase
/// (e.g. after restoring on a new phone).
class InvoiceImageDataSource {
  InvoiceImageDataSource(this._imagePicker, this._apiService);

  final ImagePicker _imagePicker;
  final ApiService _apiService;

  /// Returns a temporary path, or null if the owner cancelled.
  Future<String?> pickImage({required bool fromCamera}) async {
    final file = await _imagePicker.pickImage(
      source: fromCamera ? ImageSource.camera : ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 1600,
    );
    return file?.path;
  }

  /// Copies the photo into the app folder as `<entryId>.jpg`.
  Future<String> keepImage({required String temporaryPath, required String entryId}) async {
    final documents = await getApplicationDocumentsDirectory();
    final directory = Directory(p.join(documents.path, 'invoices'));
    if (!directory.existsSync()) await directory.create(recursive: true);
    final target = p.join(directory.path, '$entryId.jpg');
    await File(temporaryPath).copy(target);
    return target;
  }

  Future<String> createSignedUrl(String remotePath) =>
      _apiService.storage.from(AppConfig.invoicesBucket).createSignedUrl(remotePath, 60 * 10);
}
