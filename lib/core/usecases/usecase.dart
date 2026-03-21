import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import 'package:style_cart/core/errors/failures.dart';

abstract interface class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

class NoParams extends Equatable {
  @override
  List<Object?> get props => [];
}
