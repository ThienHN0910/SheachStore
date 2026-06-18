import '../core/api/api_client.dart';
import '../models/review_models.dart';

class ReviewService {
  ReviewService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<List<ReviewResponse>> getReviewsByBook(int bookId) {
    return _apiClient.get(
      '/api/reviews/book/$bookId',
      (json) => (json as List<dynamic>)
          .map((item) => ReviewResponse.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<ReviewResponse> createReview(ReviewRequest request) {
    return _apiClient.post(
      '/api/reviews',
      request.toJson(),
      (json) => ReviewResponse.fromJson(json as Map<String, dynamic>),
      authorized: true,
    );
  }

  Future<void> updateReview(int id, ReviewRequest request) {
    return _apiClient.put(
      '/api/reviews/$id',
      request.toJson(),
      (_) {},
      authorized: true,
    );
  }

  Future<void> deleteReview(int id) {
    return _apiClient.delete('/api/reviews/$id', authorized: true);
  }
}
