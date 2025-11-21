class GarmentAnalysis {
  final String id;
  final String itemName;
  final String qualityAssessment;
  final List<String> tags;
  final String classification; // 'Recyclable' or 'Reusable'
  final int score; // 0-100
  final String reasoning;
  final DateTime timestamp;

  GarmentAnalysis({
    required this.id,
    required this.itemName,
    required this.qualityAssessment,
    required this.tags,
    required this.classification,
    required this.score,
    required this.reasoning,
    required this.timestamp,
  });

  factory GarmentAnalysis.fromJson(Map<String, dynamic> json) {
    return GarmentAnalysis(
      id: json['id'] ?? '',
      itemName: json['itemName'] ?? 'Unknown Item',
      qualityAssessment: json['qualityAssessment'] ?? 'No assessment',
      tags: List<String>.from(json['tags'] ?? []),
      classification: json['classification'] ?? 'Recyclable',
      score: json['score'] ?? 0,
      reasoning: json['reasoning'] ?? '',
      timestamp:
          json['timestamp'] != null
              ? DateTime.parse(json['timestamp'])
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'itemName': itemName,
      'qualityAssessment': qualityAssessment,
      'tags': tags,
      'classification': classification,
      'score': score,
      'reasoning': reasoning,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
