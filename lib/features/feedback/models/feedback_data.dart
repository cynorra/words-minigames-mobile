class FeedbackData {
  final String category;
  final String title;
  final String description;
  final String? userEmail;

  const FeedbackData({
    required this.category,
    required this.title,
    required this.description,
    this.userEmail,
  });

  /// Validates the feedback data
  bool get isValid {
    return category.isNotEmpty &&
        title.trim().isNotEmpty &&
        title.trim().length >= 3 &&
        description.trim().isNotEmpty &&
        description.trim().length >= 10;
  }

  /// Returns validation error message if any
  String? get validationError {
    if (category.isEmpty) return 'Please select a category';
    if (title.trim().isEmpty) return 'Please enter a title';
    if (title.trim().length < 3) return 'Title must be at least 3 characters';
    if (description.trim().isEmpty) return 'Please enter a description';
    if (description.trim().length < 10) {
      return 'Description must be at least 10 characters';
    }
    return null;
  }

  /// Creates a copy with updated values
  FeedbackData copyWith({
    String? category,
    String? title,
    String? description,
    String? userEmail,
  }) {
    return FeedbackData(
      category: category ?? this.category,
      title: title ?? this.title,
      description: description ?? this.description,
      userEmail: userEmail ?? this.userEmail,
    );
  }
}
