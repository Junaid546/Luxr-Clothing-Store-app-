// ignore_for_file: public_member_api_docs, sort_constructors_first, always_put_required_named_parameters_first, invalid_annotation_target, sort_unnamed_constructors_first, lines_longer_than_80_chars, document_ignores
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_model.freezed.dart';

@freezed
class NotificationModel with _$NotificationModel {
  const NotificationModel._();

  const factory NotificationModel({
    required String notificationId,
    required String userId,
    required String title,
    required String body,
    required String type,
    required Map<String, dynamic> data,
    required bool isRead,
    required DateTime createdAt,
  }) = _NotificationModel;

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>? ?? const <String, dynamic>{};
    return NotificationModel(
      notificationId: doc.id,
      userId:         d['userId'] as String? ?? '',
      title:          d['title']  as String? ?? '',
      body:           d['body']   as String? ?? '',
      type:           d['type']   as String? ?? 'system',
      data:           d['data']   as Map<String, dynamic>? ?? {},
      isRead:         d['isRead'] as bool? ?? false,
      createdAt:      (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'notificationId': notificationId,
    'userId':         userId,
    'title':          title,
    'body':           body,
    'type':           type,
    'data':           data,
    'isRead':         isRead,
    // createdAt is usually handled outside on document creation
  };
}



