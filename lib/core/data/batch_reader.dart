import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stylecart/core/constants/firestore_constants.dart';
import 'package:stylecart/core/providers/repository_providers.dart';

part 'batch_reader.g.dart';

class FirestoreBatchReader {
  final FirebaseFirestore _firestore;

  const FirestoreBatchReader(this._firestore);

  // ── Batch read products by ID ──────────────────────
  Future<Map<String, Map<String, dynamic>>> readProducts(
      List<String> productIds) async {
    return batchRead(FirestoreConstants.products, productIds);
  }

  // ── Batch read orders by ID ────────────────────────
  Future<Map<String, Map<String, dynamic>>> readOrders(
      List<String> orderIds) async {
    return batchRead(FirestoreConstants.orders, orderIds);
  }

  // ── Generic batch read ─────────────────────────────
  Future<Map<String, Map<String, dynamic>>> batchRead(
    String collection,
    List<String> ids,
  ) async {
    if (ids.isEmpty) return {};

    final results = <String, Map<String, dynamic>>{};
    final chunks = _chunk(ids, 30);

    await Future.wait(chunks.map((chunk) async {
      final snap = await _firestore
          .collection(collection)
          .where(FieldPath.documentId, whereIn: chunk)
          .get(const GetOptions(source: Source.serverAndCache));
      for (final doc in snap.docs) {
        results[doc.id] = doc.data();
      }
    }));

    return results;
  }

  // ── Chunk list into sub-lists of size n ───────────
  List<List<T>> _chunk<T>(List<T> list, int size) {
    final chunks = <List<T>>[];
    for (int i = 0; i < list.length; i += size) {
      chunks.add(list.sublist(
        i,
        (i + size < list.length) ? i + size : list.length,
      ));
    }
    return chunks;
  }
}

@riverpod
FirestoreBatchReader firestoreBatchReader(FirestoreBatchReaderRef ref) =>
    FirestoreBatchReader(ref.watch(firestoreProvider));
