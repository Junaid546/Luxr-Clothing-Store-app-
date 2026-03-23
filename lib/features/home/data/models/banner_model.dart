// ignore_for_file: public_member_api_docs, sort_constructors_first, always_put_required_named_parameters_first, invalid_annotation_target, sort_unnamed_constructors_first, lines_longer_than_80_chars, document_ignores
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'banner_model.freezed.dart';

@freezed
class BannerModel with _$BannerModel {
  const BannerModel._();

  const factory BannerModel({
    required String bannerId,
    required String title,
    String? subtitle,
    required String imageUrl,
    required String actionLabel,
    required String actionRoute,
    required int sortOrder,
    required bool isActive,
    DateTime? startDate,
    DateTime? endDate,
    required DateTime createdAt,
  }) = _BannerModel;

  factory BannerModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>? ?? const <String, dynamic>{};
    return BannerModel(
      bannerId:    doc.id,
      title:       d['title']       as String? ?? '',
      subtitle:    d['subtitle']    as String?,
      imageUrl:    d['imageUrl']    as String? ?? '',
      actionLabel: d['actionLabel'] as String? ?? '',
      actionRoute: d['actionRoute'] as String? ?? '',
      sortOrder:   (d['sortOrder']  as num?)?.toInt() ?? 0,
      isActive:    d['isActive']    as bool? ?? true,
      startDate:   (d['startDate']  as Timestamp?)?.toDate(),
      endDate:     (d['endDate']    as Timestamp?)?.toDate(),
      createdAt:   (d['createdAt']  as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'bannerId':    bannerId,
    'title':       title,
    'subtitle':    subtitle,
    'imageUrl':    imageUrl,
    'actionLabel': actionLabel,
    'actionRoute': actionRoute,
    'sortOrder':   sortOrder,
    'isActive':    isActive,
    'startDate':   startDate != null ? Timestamp.fromDate(startDate!) : null,
    'endDate':     endDate != null ? Timestamp.fromDate(endDate!) : null,
    // createdAt is usually handled outside or created once.
  };
}



