class TextDB {
  final int id;
  final String name;
  final String date;
  final String text;

  TextDB ({
    required this.id,
    required this.name,
    required this.date,
    required this.text
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'date' : date,
      'text' : text
    };
  }

  @override
  String toString() {
    return 'TextDB{id: $id, name: $name, date: $date, text: $text}';
  }
}