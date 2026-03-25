import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:style_cart/core/errors/failures.dart';
import 'package:style_cart/core/usecases/usecase.dart';
import 'package:style_cart/features/orders/domain/repositories/order_repository.dart';

class RequestReturnParams extends Equatable {
  final String orderId;
  final String userId;
  final String reason;

  const RequestReturnParams({
    required this.orderId,
    required this.userId,
    required this.reason,
  });

  @override
  List<Object> get props => [orderId, userId, reason];
}

class RequestReturnUseCase
    implements UseCase<void, RequestReturnParams> {
  final OrderRepository _repo;
  const RequestReturnUseCase(this._repo);

  @override
  Future<Either<Failure, void>> call(
    RequestReturnParams params,
  ) {
    if (params.reason.trim().length < 10) {
      return Future.value(
        const Left(ValidationFailure(
          'Please provide a reason (min 10 characters)',
        )),
      );
    }
    return _repo.requestReturn(
      orderId: params.orderId,
      userId:  params.userId,
      reason:  params.reason,
    );
  }
}
