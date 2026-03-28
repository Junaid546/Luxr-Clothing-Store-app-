// ignore_for_file: public_member_api_docs, document_ignores

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stylecart/core/providers/firebase_providers.dart';
import 'package:stylecart/features/products/data/repositories/image_repository_impl.dart';
import 'package:stylecart/features/products/data/repositories/product_repository_impl.dart';
import 'package:stylecart/features/products/domain/repositories/image_repository.dart';
import 'package:stylecart/features/products/domain/repositories/product_repository.dart';
import 'package:stylecart/features/products/domain/usecases/create_product_usecase.dart';
import 'package:stylecart/features/products/domain/usecases/get_low_stock_products_usecase.dart';
import 'package:stylecart/features/products/domain/usecases/get_product_by_id_usecase.dart';
import 'package:stylecart/features/products/domain/usecases/get_products_usecase.dart';
import 'package:stylecart/features/products/domain/usecases/release_stock_usecase.dart';
import 'package:stylecart/features/products/domain/usecases/reserve_stock_usecase.dart';
import 'package:stylecart/features/products/domain/usecases/search_products_usecase.dart';
import 'package:stylecart/features/products/domain/usecases/update_inventory_usecase.dart';
import 'package:stylecart/features/products/domain/usecases/update_product_usecase.dart';

part 'product_data_providers.g.dart';

@riverpod
ImageRepository imageRepository(ImageRepositoryRef ref) =>
    ImageRepositoryImpl(ref.watch(firebaseStorageProvider));

@riverpod
ProductRepository productRepository(
  ProductRepositoryRef ref,
) =>
    ProductRepositoryImpl(
      ref.watch(firestoreProvider),
      ref.watch(imageRepositoryProvider),
    );

// ── Use case providers ────────────────────────────────
@riverpod
GetProductsUseCase getProductsUseCase(
  GetProductsUseCaseRef ref,
) =>
    GetProductsUseCase(ref.watch(productRepositoryProvider));

@riverpod
GetProductByIdUseCase getProductByIdUseCase(
  GetProductByIdUseCaseRef ref,
) =>
    GetProductByIdUseCase(ref.watch(productRepositoryProvider));

@riverpod
SearchProductsUseCase searchProductsUseCase(
  SearchProductsUseCaseRef ref,
) =>
    SearchProductsUseCase(ref.watch(productRepositoryProvider));

@riverpod
CreateProductUseCase createProductUseCase(
  CreateProductUseCaseRef ref,
) =>
    CreateProductUseCase(ref.watch(productRepositoryProvider));

@riverpod
UpdateProductUseCase updateProductUseCase(
  UpdateProductUseCaseRef ref,
) =>
    UpdateProductUseCase(ref.watch(productRepositoryProvider));

@riverpod
UpdateInventoryUseCase updateInventoryUseCase(
  UpdateInventoryUseCaseRef ref,
) =>
    UpdateInventoryUseCase(ref.watch(productRepositoryProvider));

@riverpod
GetLowStockProductsUseCase getLowStockProductsUseCase(
  GetLowStockProductsUseCaseRef ref,
) =>
    GetLowStockProductsUseCase(ref.watch(productRepositoryProvider));

@riverpod
ReserveMultipleStockUseCase reserveMultipleStockUseCase(
  ReserveMultipleStockUseCaseRef ref,
) =>
    ReserveMultipleStockUseCase(ref.watch(productRepositoryProvider));

@riverpod
ReleaseMultipleStockUseCase releaseMultipleStockUseCase(
  ReleaseMultipleStockUseCaseRef ref,
) =>
    ReleaseMultipleStockUseCase(ref.watch(productRepositoryProvider));
