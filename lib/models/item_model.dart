class ItemModel {
  final String id;
  final String title;
  final String type;        // 'lost' or 'found'
  final String category;
  final String location;
  final String description;
  final String? imagePath;  // local image file path
  final String postedBy;
  final String email;
  final String date;

  ItemModel({
    required this.id,
    required this.title,
    required this.type,
    required this.category,
    required this.location,
    required this.description,
    this.imagePath,
    required this.postedBy,
    required this.email,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'type': type,
    'category': category,
    'location': location,
    'description': description,
    'imagePath': imagePath,
    'postedBy': postedBy,
    'email': email,
    'date': date,
  };

  factory ItemModel.fromJson(Map<String, dynamic> j) => ItemModel(
    id: j['id'],
    title: j['title'],
    type: j['type'],
    category: j['category'],
    location: j['location'],
    description: j['description'],
    imagePath: j['imagePath'],
    postedBy: j['postedBy'],
    email: j['email'],
    date: j['date'],
  );
}