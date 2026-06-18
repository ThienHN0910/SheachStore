class CategoryRequest {
  const CategoryRequest({required this.name, required this.slug});

  final String name;
  final String slug;

  Map<String, dynamic> toJson() {
    return {'name': name, 'slug': slug};
  }
}

class CategoryResponse {
  const CategoryResponse({
    required this.id,
    required this.name,
    required this.slug,
  });

  final int id;
  final String name;
  final String slug;

  factory CategoryResponse.fromJson(Map<String, dynamic> json) {
    return CategoryResponse(
      id: json['id'] as int,
      name: json['name'] as String,
      slug: json['slug'] as String,
    );
  }
}

class AuthorRequest {
  const AuthorRequest({required this.name, this.bio});

  final String name;
  final String? bio;

  Map<String, dynamic> toJson() {
    return {'name': name, 'bio': bio};
  }
}

class AuthorResponse {
  const AuthorResponse({required this.id, required this.name, this.bio});

  final int id;
  final String name;
  final String? bio;

  factory AuthorResponse.fromJson(Map<String, dynamic> json) {
    return AuthorResponse(
      id: json['id'] as int,
      name: json['name'] as String,
      bio: json['bio'] as String?,
    );
  }
}

class BookRequest {
  const BookRequest({
    required this.title,
    required this.authorId,
    required this.categoryId,
    required this.price,
    required this.stock,
    this.coverUrl,
    this.description,
  });

  final String title;
  final int authorId;
  final int categoryId;
  final double price;
  final int stock;
  final String? coverUrl;
  final String? description;

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'authorId': authorId,
      'categoryId': categoryId,
      'price': price,
      'stock': stock,
      'coverUrl': coverUrl,
      'description': description,
    };
  }
}

class BookResponse {
  const BookResponse({
    required this.id,
    required this.title,
    required this.authorId,
    required this.categoryId,
    required this.price,
    required this.stock,
    this.authorName,
    this.categoryName,
    this.coverUrl,
    this.description,
  });

  final int id;
  final String title;
  final int authorId;
  final String? authorName;
  final int categoryId;
  final String? categoryName;
  final double price;
  final int stock;
  final String? coverUrl;
  final String? description;

  factory BookResponse.fromJson(Map<String, dynamic> json) {
    return BookResponse(
      id: json['id'] as int,
      title: json['title'] as String,
      authorId: json['authorId'] as int,
      authorName: json['authorName'] as String?,
      categoryId: json['categoryId'] as int,
      categoryName: json['categoryName'] as String?,
      price: (json['price'] as num).toDouble(),
      stock: json['stock'] as int,
      coverUrl: json['coverUrl'] as String?,
      description: json['description'] as String?,
    );
  }
}
