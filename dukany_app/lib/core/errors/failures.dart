import 'dart:async';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class Failure extends Equatable {
  const Failure(this.message);

  /// Arabic, user-facing message.
  final String message;

  @override
  List<Object?> get props => [message];
}

class LocalDatabaseFailure extends Failure {
  const LocalDatabaseFailure([super.message = 'تعذّر حفظ البيانات على الجهاز، حاول مرة أخرى']);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

class NoInternetFailure extends Failure {
  const NoInternetFailure([super.message = 'لا يوجد اتصال بالإنترنت، بياناتك محفوظة على الجهاز']);
}

class SubscriptionInactiveFailure extends Failure {
  const SubscriptionInactiveFailure([super.message = 'اشتراك البقالة موقوف أو منتهي، تواصل مع الدعم']);
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'حدث خطأ في الاتصال بالخادم، حاول لاحقاً']);

  factory ServerFailure.fromException(Object error) {
    if (error is SocketException || error is TimeoutException || error is HttpException) {
      return const ServerFailure('لا يوجد اتصال بالإنترنت، حاول لاحقاً');
    }
    if (error is AuthRetryableFetchException) {
      return const ServerFailure('تعذّر الاتصال بالخادم، تأكد من الإنترنت وحاول مرة أخرى');
    }
    if (error is AuthException) {
      final code = error.code ?? '';
      if (code == 'invalid_credentials' || error.statusCode == '400') {
        return const ServerFailure('رقم الجوال أو كلمة المرور غير صحيحة');
      }
      return const ServerFailure('انتهت الجلسة، سجّل الدخول مرة أخرى');
    }
    if (error is PostgrestException) {
      // 42501 = row level security rejected the write (shop not active).
      if (error.code == '42501') {
        return const ServerFailure('لا يمكن رفع البيانات: الاشتراك غير فعّال');
      }
      return const ServerFailure('رفض الخادم البيانات، حاول مرة أخرى');
    }
    if (error is StorageException) {
      return const ServerFailure('تعذّر رفع صورة الفاتورة، حاول مرة أخرى');
    }
    return const ServerFailure();
  }
}
