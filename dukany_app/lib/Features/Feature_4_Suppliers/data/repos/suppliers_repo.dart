import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../models/invoice_scan_result_model.dart';
import '../models/supplier_entry_model.dart';
import '../models/supplier_model.dart';

abstract class SuppliersRepo {
  Stream<void> get changes;

  Future<Either<Failure, List<SupplierModel>>> getSuppliers({String query = ''});

  Future<Either<Failure, SupplierModel>> getSupplier(String supplierId);

  Future<Either<Failure, SupplierModel>> addSupplier({required String name, String? phone});

  Future<Either<Failure, SupplierModel>> updateSupplier(SupplierModel supplier, {required String name, String? phone});

  Future<Either<Failure, List<SupplierEntryModel>>> getEntries(String supplierId);

  /// Right(null) means the owner cancelled the camera/gallery.
  Future<Either<Failure, String?>> pickInvoiceImage({required bool fromCamera});

  Future<Either<Failure, InvoiceScanResultModel>> scanInvoiceTotal(String imagePath);

  /// Returns what is still owed to the supplier after saving.
  Future<Either<Failure, double>> addInvoice({
    required SupplierModel supplier,
    required double amount,
    String? temporaryImagePath,
    String? note,
  });

  Future<Either<Failure, double>> addPayment({required SupplierModel supplier, required double amount, String? note});

  Future<Either<Failure, Unit>> deleteEntry(SupplierEntryModel entry);

  /// Short-lived link for a photo stored only in Supabase.
  Future<Either<Failure, String>> getRemoteImageUrl(SupplierEntryModel entry);
}
