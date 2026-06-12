class Lesson {
  final String dayName;
  final int dayIndex; // 0=Monday .. 4=Friday
  final String? videoTitle;
  final String? videoUrl;
  final String readingTask;
  final String promptText;
  bool isCompleted;

  Lesson({
    required this.dayName,
    required this.dayIndex,
    this.videoTitle,
    this.videoUrl,
    required this.readingTask,
    required this.promptText,
    this.isCompleted = false,
  });

  /// Extract YouTube video ID from URL for thumbnail
  String? get youtubeVideoId {
    if (videoUrl == null) return null;
    final uri = Uri.tryParse(videoUrl!);
    if (uri == null) return null;
    // Handle youtube.com/watch?v=ID format
    if (uri.host.contains('youtube.com')) {
      return uri.queryParameters['v'];
    }
    // Handle youtu.be/ID format
    if (uri.host.contains('youtu.be')) {
      return uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
    }
    return null;
  }

  String? get thumbnailUrl {
    final id = youtubeVideoId;
    if (id == null) return null;
    return 'https://img.youtube.com/vi/$id/hqdefault.jpg';
  }

  bool get hasVideo => videoUrl != null && videoUrl!.isNotEmpty;
}
