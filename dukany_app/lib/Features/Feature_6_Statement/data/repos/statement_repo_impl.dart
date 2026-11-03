import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/models/party_type.dart';
import '../../../../core/utils/functions/whatsapp_launcher.dart';
import '../../../../core/utils/shop_session_storage.dart';
import '../data_sources/statement_local_data_source.dart';
import '../data_sources/statement_pdf_generator.dart';
import '../data_sources/statement_text_builder.dart';
import '../models/statement_model.dart';
import '../models/statement_period.dart';
import 'statement_repo.dart';

class StatementRepoImpl implements StatementRepo {
  StatementRepoImpl(this._localDataSource, this._pdfGenerator, this._shopSessionStorage);

  final StatementLocalDataSource _localDataSource;
  final StatementPdfGenerator _pdfGenerator;
  final ShopSessionStorage _shopSessionStorage;

  @override
  Future<Either<Failure, StatementModel>> getStatement({
    required PartyType partyType,
    required String partyId,
    required StatementPeriod period,
  }) async {
    try {
      final party = await _localDataSource.getParty(partyType, partyId);
      if (party == null) return const Left(LocalDatabaseFailure('الحساب غير موجود'));

      final range = period.rangeFrom(DateTime.now());
      final opening = await _localDataSource.getOpeningBalance(partyType, partyId, range.from);
      final rawEntries = await _localDataSource.getEntries(partyType, partyId, from: range.from, to: range.to);

      var running = opening;
      final lines = rawEntries.map((entry) {
        running += entry.debit - entry.credit;
        return StatementLineModel(
          date: entry.date,
          description: entry.description,
          debit: entry.debit,
          credit: entry.credit,
          runningBalance: running,
        );
      }).toList();

      return Right(
        StatementModel(
          partyType: partyType,
          partyName: party.name,
          partyPhone: party.phone,
          shopName: _shopSessionStorage.shopName,
          period: period,
          from: range.from,
          to: range.to,
          openingBalance: opening,
          lines: lines,
        ),
      );
    } catch (error, stackTrace) {
      log('local database error', name: 'StatementRepo', error: error, stackTrace: stackTrace);
      return const Left(LocalDatabaseFailure('تعذّر تجهيز كشف الحساب'));
    }
  }

  @override
  Future<Either<Failure, Unit>> sharePdf(StatementModel statement) async {
    try {
      final file = await _pdfGenerator.generate(statement);
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: 'application/pdf')],
          text: 'كشف حساب ${statement.partyName} — ${statement.shopName}',
        ),
      );
      return const Right(unit);
    } catch (_) {
      return const Left(LocalDatabaseFailure('تعذّر إنشاء ملف PDF'));
    }
  }

  @override
  Future<Either<Failure, Unit>> sendAsWhatsAppText(StatementModel statement) async {
    final phone = statement.partyPhone;
    if (phone == null || phone.isEmpty) {
      return const Left(ValidationFailure('لا يوجد رقم جوال لهذا الحساب، استخدم مشاركة PDF'));
    }
    final opened = await openWhatsAppChat(phone: phone, message: StatementTextBuilder.build(statement));
    return opened ? const Right(unit) : const Left(ValidationFailure('تعذّر فتح واتساب'));
  }
}
