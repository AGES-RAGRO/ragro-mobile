// Payload de POST /reviews — alinhado ao CreateReviewRequest do backend.
class CreateReviewRequest {
  const CreateReviewRequest({
    required this.orderId,
    required this.rating,
    required this.comment,
  });

  final String orderId;
  final int rating;
  final String comment;

  Map<String, dynamic> toJson() => {
    'orderId': orderId,
    'rating': rating,
    'comment': comment,
  };
}
