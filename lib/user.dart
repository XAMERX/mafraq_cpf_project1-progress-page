class User {
  int id;
  String name;
  String email;
  String password;
  int steps;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    this.steps = 0,
  });
}
