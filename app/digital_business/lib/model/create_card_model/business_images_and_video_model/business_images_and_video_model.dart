class BusinessImagesAndVideoModel {
  final bool status;
  final String message;
  final List<String> data;

  BusinessImagesAndVideoModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory BusinessImagesAndVideoModel.fromJson(Map<String, dynamic> json) {
    return BusinessImagesAndVideoModel(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: List<String>.from(json['data'] ?? []),
    );
  }
}
