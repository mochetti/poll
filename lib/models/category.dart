import 'poll.dart';

class Category {
  String name = 'name is empty';
  String id;
  List<String> tags;
  List<Poll> polls = [];
  Category({String name, String id}) {
    this.id = id;
    this.name = name;
  }

  void addPoll(String pollId) {
    polls.add(new Poll(id: pollId));
  }
}
