class Member {
  final int id;
  final String name;
  final String designation;
  final List<Map<String, Object>> panel;

  final String imageUrl;
  const Member(
      {this.name, this.designation, this.id, this.panel, this.imageUrl});
}
