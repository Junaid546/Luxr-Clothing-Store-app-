import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:style_cart/core/constants/firestore_constants.dart';
import 'package:style_cart/core/providers/repository_providers.dart';

part 'batch_reader.g.dart';

// ── Optimized Firestore Batch Reader ──────────────────
// Reads multiple Firestore documents in a single
// batched network call using whereIn queries.
// MUCH faster than N individual document reads.
// Firestore whereIn limit = 30 per query.

class FirestoreBatchReader {
  final FirebaseFirestore _firestore;

  const FirestoreBatchReader(this._firestore);

  // ── Batch read products by ID ──────────────────────
  Future<Map<String, Map<String, dynamic>>> readProducts(List<String> productIds) async {
    if (productIds.isEmpty) return {};

    final results = <String, Map<String, dynamic>>{};
    // Split into chunks of 30 (Firestore whereIn limit)
    final chunks = _chunk(productIds, 30);

    await Future.wait(chunks.map((chunk) async {
      final snap = await _firestore
          .collection(FirestoreConstants.products)
          .where(FieldPath.documentId, whereIn: chunk)
          .get(const GetOptions(source: Source.serverAndCache));
      for (final doc in snap.docs) {
        results[doc.id] = doc.data();
      }
    }));

    return results;
  }

  // ── Batch read orders by ID ────────────────────────
  Future<Map<String, Map<String, dynamic>>> readOrders(List<String> orderIds) async {
    if (orderIds.isEmpty) return {};

    final results = <String, Map<String, dynamic>>{};
    final chunks = _chunk(orderIds, 30);

    await Future.wait(chunks.map((chunk) async {
      final snap = await _firestore
          .collection(FirestoreConstants.orders)
          .where(FieldPath.documentId, whereIn: chunk)
          .get();
      for (final doc in snap.docs) {
        results[doc.id] = doc.data();
      }
    }));

    return results;
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
