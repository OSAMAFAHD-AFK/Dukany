import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class Failure extends Equatable {
  const Failure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'حدث خطأ في الاتصال، حاول مرة أخرى']);

  factory ServerFailure.fromException(Object error) {
    if (error is AuthException) {
      return const ServerFailure('البريد أو كلمة المرور غير صحيحة');
    }
    if (error is FunctionException) {
      final details = error.details;
      final code = details is Map ? details['error'] : null;
      final detail = details is Map ? details['detail'] : null;
      return ServerFailure(switch (code) {
        'phone_taken' => 'رقم الجوال مستخدم لبقالة أخرى',
        'invalid_input' => 'تأكد من البيانات: الاسم، رقم جوال صحيح، كلمة مرور 6 أحرف على الأقل',
        'forbidden' => 'هذا الحساب ليس في جدول المشرفين',
        'unauthorized' => 'انتهت الجلسة، سجّل الخروج ثم ادخل من جديد',
        'admin_check_failed' => 'تعذّر على الخادم قراءة جدول المشرفين (راجع Logs الدالة)',
        'shop_not_found' => 'البقالة غير موجودة',
        _ => 'تعذّر تنفيذ العملية على الخادم [${code ?? error.status}] ${detail ?? ''}'.trim(),
      });
    }
    if (error is PostgrestException) {
      return error.code == '42501'
          ? const ServerFailure('ليس لديك صلاحية لهذا الإجراء')
          : const ServerFailure('رفض الخادم الطلب');
    }
    return const ServerFailure();
  }
}
