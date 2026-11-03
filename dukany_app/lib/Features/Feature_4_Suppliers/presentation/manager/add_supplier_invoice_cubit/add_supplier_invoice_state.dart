part of 'add_supplier_invoice_cubit.dart';

enum AddSupplierInvoiceStatus { loading, choosingImage, scanning, ready, saving, saved, failure }

class AddSupplierInvoiceState extends Equatable {
  const AddSupplierInvoiceState({
    this.status = AddSupplierInvoiceStatus.loading,
    this.supplier,
    this.imagePath,
    this.scanResult = InvoiceScanResultModel.empty,
    this.remainingAfterSave,
    this.errorMessage,
  });

  final AddSupplierInvoiceStatus status;
  final SupplierModel? supplier;

  /// Temporary photo path (copied permanently only on save).
  final String? imagePath;
  final InvoiceScanResultModel scanResult;
  final double? remainingAfterSave;
  final String? errorMessage;

  /// True once the owner has a photo or chose to type the amount only.
  bool get isFillingAmount =>
      status == AddSupplierInvoiceStatus.ready ||
      status == AddSupplierInvoiceStatus.saving ||
      (status == AddSupplierInvoiceStatus.failure && supplier != null);

  AddSupplierInvoiceState copyWith({
    AddSupplierInvoiceStatus? status,
    SupplierModel? supplier,
    String? imagePath,
    bool clearImage = false,
    InvoiceScanResultModel? scanResult,
    double? remainingAfterSave,
    String? errorMessage,
  }) => AddSupplierInvoiceState(
    status: status ?? this.status,
    supplier: supplier ?? this.supplier,
    imagePath: clearImage ? null : (imagePath ?? this.imagePath),
    scanResult: scanResult ?? this.scanResult,
    remainingAfterSave: remainingAfterSave ?? this.remainingAfterSave,
    errorMessage: errorMessage,
  );

  @override
  List<Object?> get props => [status, supplier, imagePath, scanResult, remainingAfterSave, errorMessage];
}
