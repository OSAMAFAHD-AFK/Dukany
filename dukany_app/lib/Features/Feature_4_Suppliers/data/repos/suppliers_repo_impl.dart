import 'dart:developer';

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/functions/id_generator.dart';
import '../../../../core/utils/functions/phone_normalizer.dart';
import '../data_sources/invoice_image_data_source.dart';
import '../data_sources/invoice_text_recognition_data_source.dart';
import '../data_sources/suppliers_local_data_source.dart';
import '../models/invoice_scan_result_model.dart';
import '../models/supplier_entry_model.dart';
import '../models/supplier_model.dart';
import 'suppliers_repo.dart';

class SuppliersRepoImpl implements SuppliersRepo {
  SuppliersRepoImpl(this._localDataSource, this._imageDataSource, this._textRecognitionDataSource);

  final SuppliersLocalDataSource _localDataSource;
  final InvoiceImageDataSource _imageDataSource;
  final InvoiceTextRecognitionDataSource _textRecognitionDataSource;

  @override
  Stream<void> get changes => _localDataSource.changes;

  @override
  Future<Either<Failure, List<SupplierModel>>> getSuppliers({String query = ''}) =>
      _guard(() => _localDataSource.getSuppliers(query: query));

  @override
  Future<Either<Failure, SupplierModel>> getSupplier(String supplierId) async {
    final result = await _guard(() => _localDataSource.getSupplierById(supplierId));
    return result.flatMap(
      (supplier) => supplier == null ? const Left(LocalDatabaseFailure('المورد غير موجود')) : Right(supplier),
    );
  }

  @override
  Future<Either<Failure, SupplierModel>> addSupplier({required String name, String? phone}) async {
    final validation = _validateSupplier(name, phone);
    if (validation != null) return Left(validation);
    final now = DateTime.now();
    final supplier = SupplierModel(
      id: generateId(),
      name: name.trim(),
      phone: _cleanPhone(phone),
      createdAt: now,
      updatedAt: now,
    );
    return _guard(() async {
      await _localDataSource.insertSupplier(supplier);
      return supplier;
    });
  }

  @override
  Future<Either<Failure, SupplierModel>> updateSupplier(
    SupplierModel supplier, {
    required String name,
    String? phone,
  }) async {
    final validation = _validateSupplier(name, phone);
    if (validation != null) return Left(validation);
    final cleanedPhone = _cleanPhone(phone);
    final updated = supplier.copyWith(
      name: name.trim(),
      phone: cleanedPhone,
      clearPhone: cleanedPhone == null,
      updatedAt: DateTime.now(),
    );
    return _guard(() async {
      await _localDataSource.updateSupplier(updated);
      return updated;
    });
  }

  @override
  Future<Either<Failure, List<SupplierEntryModel>>> getEntries(String supplierId) =>
      _guard(() => _localDataSource.getEntries(supplierId));

  @override
  Future<Either<Failure, String?>> pickInvoiceImage({required bool fromCamera}) async {
    try {
      return Right(await _imageDataSource.pickImage(fromCamera: fromCamera));
    } catch (_) {
      return const Left(ValidationFailure('تعذّر فتح الكاميرا، تأكد من إعطاء الصلاحية'));
    }
  }

  @override
  Future<Either<Failure, InvoiceScanResultModel>> scanInvoiceTotal(String imagePath) async {
    try {
      return Right(await _textRecognitionDataSource.recognizeTotal(imagePath));
    } catch (_) {
      // OCR is a helper only — the owner can always type the total.
      return const Right(InvoiceScanResultModel.empty);
    }
  }

  @override
  Future<Either<Failure, double>> addInvoice({
    required SupplierModel supplier,
    required double amount,
    String? temporaryImagePath,
    String? note,
  }) async {
    if (amount <= 0) return const Left(ValidationFailure('اكتب إجمالي الفاتورة'));
    final entryId = generateId();
    return _guard(() async {
      final localImagePath = temporaryImagePath == null
          ? null
          : await _imageDataSource.keepImage(temporaryPath: temporaryImagePath, entryId: entryId);
      return _localDataSource.insertEntry(
        _newEntry(
          id: entryId,
          supplier: supplier,
          kind: SupplierEntryKind.invoice,
          amount: amount,
          note: note,
          localImagePath: localImagePath,
        ),
      );
    });
  }

  @override
  Future<Either<Failure, double>> addPayment({
    required SupplierModel supplier,
    required double amount,
    String? note,
  }) async {
    if (amount <= 0) return const Left(ValidationFailure('اكتب مبلغ الدفعة'));
    return _guard(
      () => _localDataSource.insertEntry(
        _newEntry(id: generateId(), supplier: supplier, kind: SupplierEntryKind.payment, amount: amount, note: note),
      ),
    );
  }

  @override
  Future<Either<Failure, Unit>> deleteEntry(SupplierEntryModel entry) => _guard(() async {
    await _localDataSource.softDeleteEntry(entry.id);
    return unit;
  });

  @override
  Future<Either<Failure, String>> getRemoteImageUrl(SupplierEntryModel entry) async {
    final remotePath = entry.remoteImagePath;
    if (remotePath == null) return const Left(ValidationFailure('لا توجد صورة لهذه الفاتورة'));
    try {
      return Right(await _imageDataSource.createSignedUrl(remotePath));
    } catch (_) {
      return const Left(NoInternetFailure('الصورة محفوظة في السحابة، اتصل بالإنترنت لعرضها'));
    }
  }

  SupplierEntryModel _newEntry({
    required String id,
    required SupplierModel supplier,
    required SupplierEntryKind kind,
    required double amount,
    String? note,
    String? localImagePath,
  }) {
    final now = DateTime.now();
    final trimmedNote = note?.trim();
    return SupplierEntryModel(
      id: id,
      supplierId: supplier.id,
      kind: kind,
      amount: amount,
      note: trimmedNote == null || trimmedNote.isEmpty ? null : trimmedNote,
      localImagePath: localImagePath,
      createdAt: now,
      updatedAt: now,
    );
  }

  ValidationFailure? _validateSupplier(String name, String? phone) {
    if (name.trim().isEmpty) return const ValidationFailure('اكتب اسم المورد أو الشركة');
    if (phone != null && phone.trim().isNotEmpty && normalizeYemeniPhone(phone) == null) {
      return const ValidationFailure('رقم الجوال غير صحيح');
    }
    return null;
  }

  String? _cleanPhone(String? phone) => phone == null || phone.trim().isEmpty ? null : normalizeYemeniPhone(phone);

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() action) async {
    try {
      return Right(await action());
    } catch (error, stackTrace) {
      log('local database error', name: 'SuppliersRepo', error: error, stackTrace: stackTrace);
      return const Left(LocalDatabaseFailure());
    }
  }
}
