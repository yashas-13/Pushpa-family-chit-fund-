import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/chit_models.dart';

class ChitRepository {
  ChitRepository(this._client);

  final SupabaseClient _client;

  Future<List<Chit>> listChits() async {
    final rows = await _client.from('chits').select().order('created_at');
    return rows.map((row) => Chit.fromMap(row)).toList(growable: false);
  }

  Future<Chit?> getChit(String id) async {
    final row = await _client.from('chits').select().eq('id', id).maybeSingle();
    return row == null ? null : Chit.fromMap(row);
  }

  Future<List<ChitMonth>> listMonths(String chitId) async {
    final rows = await _client.from('chit_months').select().eq('chit_id', chitId).order('month_number');
    return rows.map((row) => ChitMonth.fromMap(row)).toList(growable: false);
  }

  Future<List<PaymentObligation>> myObligations() async {
    final rows = await _client.from('payment_obligations').select().order('created_at', ascending: false);
    return rows.map((row) => PaymentObligation.fromMap(row)).toList(growable: false);
  }

  Future<void> submitPayment({
    required String obligationId,
    required String idempotencyKey,
    required int amountPaise,
    String? transactionReference,
    String? proofPath,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) throw StateError('Authentication required');

    await _client.from('payment_submissions').insert({
      'obligation_id': obligationId,
      'idempotency_key': idempotencyKey,
      'transaction_reference': transactionReference,
      'proof_path': proofPath,
      'amount_paise': amountPaise,
      'submitted_by': user.id,
    });
  }
}
