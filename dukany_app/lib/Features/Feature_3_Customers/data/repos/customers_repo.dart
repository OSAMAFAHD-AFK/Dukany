import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../models/customer_entry_model.dart';
import '../models/customer_model.dart';
import '../models/entry_item_model.dart';
import '../models/saved_entry_result_model.dart';

abstract class CustomersRepo {
  /// Emits whenever local data changes, so lists refresh themselves.
  Stream<void> get changes;

  Future<Either<Failure, List<CustomerModel>>> getCustomers({String query = ''});

  Future<Either<Failure, CustomerModel>> getCustomer(String customerId);

  Future<Either<Failure, CustomerModel>> addCustomer({required String name, String? phone});

  Future<Either<Failure, CustomerModel>> updateCustomer(CustomerModel customer, {required String name, String? phone});

  Future<Either<Failure, List<CustomerEntryModel>>> getEntries(String customerId);

  Future<Either<Failure, SavedEntryResultModel>> addDebt({
    required CustomerModel customer,
    required List<EntryItemModel> items,
    String? note,
  });

  Future<Either<Failure, SavedEntryResultModel>> addPayment({
    required CustomerModel customer,
    required double amount,
    String? note,
  });

  Future<Either<Failure, Unit>> deleteEntry(CustomerEntryModel entry);

  /// Opens WhatsApp with the queued message right away and marks it sent,
  /// so it is not sent a second time by the sync button.
  Future<Either<Failure, Unit>> sendQueuedMessageNow(SavedEntryResultModel result);

  Future<Either<Failure, List<String>>> getFrequentItemNames();
}
