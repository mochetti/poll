class Poll {
  String name;
  String createdBy;
  String first;
  String id;
  Poll(String n, String c, String i) {
    name = n;
    createdBy = c;
    id = i;
  }
  Poll.name(String n) {
    name = n;
  }
}
