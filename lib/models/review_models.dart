class ReviewRequest {
  const ReviewRequest({
    required this.bookId,
    required this.rating,
    this.comment,
  });

  final int bookId;
  final int rating;
  final String? comment;

  Map<String, dynamic> toJson() {
    return {'bookId': bookId, 'rating': rating, 'comment': comment};
  }
}

class ReviewResponse {
  const ReviewResponse({
    required this.id,
    required this.userId,
    required this.bookId,
    required this.rating,
    required this.createdAt,
    this.userFullName,
    this.bookTitle,
    this.comment,
  });

  final int id;
  final String userId;
  final String? userFullName;
  final int bookId;
  final String? bookTitle;
  final int rating;
  final String? comment;
  final DateTime createdAt;

  factory ReviewResponse.fromJson(Map<String, dynamic> json) {
    return ReviewResponse(
      id: json['id'] as int,
      userId: json['userId'] as String,
      userFullName: json['userFullName'] as String?,
      bookId: json['bookId'] as int,
      bookTitle: json['bookTitle'] as String?,
      rating: json['rating'] as int,
      comment: json['comment'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
