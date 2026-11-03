import 'dart:developer';

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/functions/id_generator.dart';
import '../../../../core/utils/functions/phone_normalizer.dart';
import '../../../../core/utils/functions/whatsapp_launcher.dart';
import '../../../../core/utils/shop_session_storage.dart';
import '../data_sources/customer_message_builder.dart';
import '../data_sources/customers_local_data_source.dart';
import '../models/customer_entry_model.dart';
import '../models/customer_model.dart';
import '../models/entry_item_model.dart';
import '../models/saved_entry_result_model.dart';
import 'customers_repo.dart';

class CustomersRepoImpl implements CustomersRepo {
  CustomersRepoImpl(this._localDataSource, this._shopSessionStorage);

  final CustomersLocalDataSource _localDataSource;
  final ShopSessionStorage _shopSessionStorage;

  @override
  Stream<void> get changes => _localDataSource.changes;

  @override
  Future<Either<Failure, List<CustomerModel>>> getCustomers({String query = ''}) =>
      _guard(() => _localDataSource.getCustomers(query: query));

  @override
  Future<Either<Failure, CustomerModel>> getCustomer(String customerId) async {
    final result = await _guard(() => _localDataSource.getCustomerById(customerId));
    return result.flatMap(
      (customer) => customer == null ? const Left(LocalDatabaseFailure('الزبون غير موجود')) : Right(customer),
    );
  }

  @override
  Future<Either<Failure, CustomerModel>> addCustomer({required String name, String? phone}) async {
    final validation = _validateCustomer(name, phone);
    if (validation != null) return Left(validation);
    final now = DateTime.now();
    final customer = CustomerModel(
      id: generateId(),
      name: name.trim(),
      phone: _cleanPhone(phone),
      createdAt: now,
      updatedAt: now,
    );
    return _guard(() async {
      await _localDataSource.insertCustomer(customer);
      return customer;
    });
  }

  @override
  Future<Either<Failure, CustomerModel>> updateCustomer(
    CustomerModel customer, {
    required String name,
    String? phone,
  }) async {
    final validation = _validateCustomer(name, phone);
    if (validation != null) return Left(validation);
    final cleanedPhone = _cleanPhone(phone);
    final updated = customer.copyWith(
      name: name.trim(),
      phone: cleanedPhone,
      clearPhone: cleanedPhone == null,
      updatedAt: DateTime.now(),
    );
    return _guard(() async {
      await _localDataSource.updateCustomer(updated);
      return updated;
    });
  }

  @override
  Future<Either<Failure, List<CustomerEntryModel>>> getEntries(String customerId) =>
      _guard(() => _localDataSource.getEntries(customerId));

  @override
  Future<Either<Failure, SavedEntryResultModel>> addDebt({
    required CustomerModel customer,
    required List<EntryItemModel> items,
    String? note,
  }) async {
    final validItems = items.where((item) => item.name.trim().isNotEmpty && item.price > 0).toList();
    if (validItems.isEmpty) return const Left(ValidationFailure('أضف صنفاً واحداً على الأقل مع سعره'));
    final total = validItems.fold<double>(0, (sum, item) => sum + item.price);
    return _saveEntry(customer: customer, kind: CustomerEntryKind.debt, items: validItems, amount: total, note: note);
  }

  @override
  Future<Either<Failure, SavedEntryResultModel>> addPayment({
    required CustomerModel customer,
    required double amount,
    String? note,
  }) async {
    if (amount <= 0) return const Left(ValidationFailure('اكتب مبلغ التسديد'));
    return _saveEntry(customer: customer, kind: CustomerEntryKind.payment, items: const [], amount: amount, note: note);
  }

  Future<Either<Failure, SavedEntryResultModel>> _saveEntry({
    required CustomerModel customer,
    required CustomerEntryKind kind,
    required List<EntryItemModel> items,
    required double amount,
    String? note,
  }) {
    final now = DateTime.now();
    final entry = CustomerEntryModel(
      id: generateId(),
      customerId: customer.id,
      kind: kind,
      items: items,
      amount: amount,
      note: note?.trim().isEmpty == true ? null : note?.trim(),
      createdAt: now,
      updatedAt: now,
    );
    final messageId = customer.hasPhone ? generateId() : null;
    String? messageBody;

    return _guard(() async {
      final newBalance = await _localDataSource.insertEntryWithMessage(
        entry,
        buildMessage: messageId == null
            ? null
            : (balance) {
                messageBody = CustomerMessageBuilder.build(
                  customerName: customer.name,
                  shopName: _shopSessionStorage.shopName,
                  entry: entry,
                  newBalance: balance,
                );
                return {
                  'id': messageId,
                  'entry_id': entry.id,
                  'recipient_name': customer.name,
                  'phone': customer.phone,
                  'body': messageBody,
                  'created_at': now.toIso8601String(),
                  'is_sent': 0,
                };
              },
      );
      return SavedEntryResultModel(
        entry: entry,
        newBalance: newBalance,
        queuedMessageId: messageId,
        messagePhone: customer.phone,
        messageBody: messageBody,
      );
    });
  }

  @override
  Future<Either<Failure, Unit>> deleteEntry(CustomerEntryModel entry) => _guard(() async {
    await _localDataSource.softDeleteEntry(entry.id);
    return unit;
  });

  @override
  Future<Either<Failure, Unit>> sendQueuedMessageNow(SavedEntryResultModel result) async {
    if (!result.hasQueuedMessage) return const Left(ValidationFailure('لا يوجد رقم جوال لهذا الزبون'));
    final opened = await openWhatsAppChat(phone: result.messagePhone!, message: result.messageBody!);
    if (!opened) return const Left(ValidationFailure('تعذّر فتح واتساب، تأكد أنه مثبت على الجوال'));
    return _guard(() async {
      await _localDataSource.markMessageSent(result.queuedMessageId!);
      return unit;
    });
  }

  @override
  Future<Either<Failure, List<String>>> getFrequentItemNames() => _guard(() => _localDataSource.getFrequentItemNames());

  ValidationFailure? _validateCustomer(String name, String? phone) {
    if (name.trim().isEmpty) return const ValidationFailure('اكتب اسم الزبون');
    if (phone != null && phone.trim().isNotEmpty && normalizeYemeniPhone(phone) == null) {
      return const ValidationFailure('رقم الجوال غير صحيح، مثال: 777123456');
    }
    return null;
  }

  String? _cleanPhone(String? phone) => phone == null || phone.trim().isEmpty ? null : normalizeYemeniPhone(phone);

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() action) async {
    try {
      return Right(await action());
    } catch (error, stackTrace) {
      log('local database error', name: 'CustomersRepo', error: error, stackTrace: stackTrace);
      return const Left(LocalDatabaseFailure());
    }
  }
}
