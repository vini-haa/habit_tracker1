class Habit {
  final int id;
  final String name;
  final String? description;
  final String countMethod;
  final String completionMethod;
  final int? targetQuantity;
  final int? targetDaysPerWeek;
  final String createdAt; // Ou DateTime, se você for parsear a data

  Habit({
    required this.id,
    required this.name,
    this.description,
    required this.countMethod,
    required this.completionMethod,
    this.targetQuantity,
    this.targetDaysPerWeek,
    required this.createdAt,
  });

  // Construtor de fábrica para criar uma instância de Habit a partir de um mapa JSON
  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      countMethod: json['count_method'],
      completionMethod: json['completion_method'],
      targetQuantity: json['target_quantity'],
      targetDaysPerWeek: json['target_days_per_week'],
      createdAt: json['created_at'],
    );
  }
}
