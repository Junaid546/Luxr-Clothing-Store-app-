// ignore_for_file: public_member_api_docs, lines_longer_than_80_chars, document_ignores, always_put_required_named_parameters_first, cascade_invocations, avoid_catches_without_on_clauses, use_if_null_to_convert_nulls_to_bools, omit_local_variable_types, directives_ordering
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:style_cart/core/errors/exceptions.dart';
import 'package:style_cart/core/errors/failures.dart';

abstract class FirestoreBaseRepository {
  final FirebaseFirestore firestore;
  const FirestoreBaseRepository(this.firestore);

  // â”€â”€ Safe Firestore call wrapper â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  // Wraps every Firestore call in try/catch
  // Maps FirebaseException â†’ ServerFailure
  // Maps generic Exception â†’ ServerFailure
  Future<Either<Failure, T>> safeFirestoreCall<T>(
    Future<T> Function() call,
  ) async {
    try {
      final result = await call();
      return Right(result);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(
        e.message ?? 'Firestore operation failed',
      ));
    } on PermissionException {
      return const Left(PermissionFailure());
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on StockException catch (e) {
      return Left(StockFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  // â”€â”€ Stream wrapper â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Stream<Either<Failure, T>> safeFirestoreStream<T>(
    Stream<T> Function() streamBuilder,
  ) {
    return streamBuilder().handleError(
      (error) => Left(
        ServerFailure(error.toString()),
      ),
    ).map((data) => Right<Failure, T>(data));
  }
}


