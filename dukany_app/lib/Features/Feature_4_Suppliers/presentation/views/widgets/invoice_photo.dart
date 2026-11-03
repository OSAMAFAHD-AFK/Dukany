import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../../core/utils/style.dart';
import '../../../../../core/utils/theme.dart';
import '../../../data/models/supplier_entry_model.dart';
import 'supplier_entry_details_sheet.dart';

/// Shows the saved invoice photo: from the phone when available, else a
/// short-lived link from Supabase Storage. Tap to open full screen.
class InvoicePhoto extends StatefulWidget {
  const InvoicePhoto({super.key, required this.entry, required this.loadRemoteUrl});

  final SupplierEntryModel entry;
  final RemoteImageUrlLoader loadRemoteUrl;

  @override
  State<InvoicePhoto> createState() => _InvoicePhotoState();
}

class _InvoicePhotoState extends State<InvoicePhoto> {
  ImageProvider? _image;
  String? _error;

  @override
  void initState() {
    super.initState();
    _resolveImage();
  }

  Future<void> _resolveImage() async {
    final localPath = widget.entry.localImagePath;
    if (localPath != null && File(localPath).existsSync()) {
      setState(() => _image = FileImage(File(localPath)));
      return;
    }
    final remote = await widget.loadRemoteUrl(widget.entry);
    if (!mounted) return;
    setState(() {
      _image = remote.url == null ? null : NetworkImage(remote.url!);
      _error = remote.error;
    });
  }

  void _openFullScreen() {
    final image = _image;
    if (image == null) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(backgroundColor: Colors.black, foregroundColor: Colors.white),
          body: Center(
            child: InteractiveViewer(maxScale: 5, child: Image(image: image)),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final image = _image;
    return GestureDetector(
      onTap: _openFullScreen,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.medium),
        child: Container(
          height: 260,
          width: double.infinity,
          color: AppColors.fieldFill,
          alignment: Alignment.center,
          child: image != null
              ? Image(image: image, fit: BoxFit.cover, width: double.infinity, height: 260)
              : _error != null
              ? Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(_error!, style: AppTextStyles.caption, textAlign: TextAlign.center),
                )
              : const CircularProgressIndicator(strokeWidth: 2.4),
        ),
      ),
    );
  }
}
