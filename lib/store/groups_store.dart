import 'package:unityspace/models/groups_models.dart';
import 'package:unityspace/service/groups_service.dart' as api;
import 'package:wstore/wstore.dart';

class Groups with GStoreChangeObjectMixin {
  final Map<int, Group> _groupsMap = {};

  Groups();

  void add(Group group) {
    _setGroup(group);
    incrementObjectChangeCount();
  }

  void addAll(Iterable<Group> all) {
    if (all.isNotEmpty) {
      for (final Group group in all) {
        _setGroup(group);
      }
      incrementObjectChangeCount();
    }
  }

  void remove(int id) {
    _removeGroup(id);
    incrementObjectChangeCount();
  }

  void clear() {
    if (_groupsMap.isNotEmpty) {
      _groupsMap.clear();
      incrementObjectChangeCount();
    }
  }

  double getNextOrder() {
    if (_groupsMap.isEmpty) return 1;
    final maxOrder = _groupsMap.values.fold<double>(
      0,
      (max, group) => max > group.order ? max : group.order,
    );
    return maxOrder + 1;
  }

  void _setGroup(Group group) {
    _removeGroup(group.id);
    _groupsMap[group.id] = group;
  }

  void _removeGroup(int id) {
    _groupsMap.remove(id);
  }

  Group? operator [](int id) => _groupsMap[id];
  Iterable<Group> get list => _groupsMap.values;
  int get length => _groupsMap.length;
}

class GroupsStore extends GStore {
  static GroupsStore? _instance;

  factory GroupsStore() => _instance ??= GroupsStore._();

  GroupsStore._();

  Groups groups = Groups();

  Future<void> getGroups() async {
    final List<GroupResponse> groupsResponse = await api.getGroups();
    final List<Group> groups =
        groupsResponse.map((response) => Group.fromResponse(response)).toList();
    setStore(() {
      this.groups.clear();
      this.groups.addAll(groups);
    });
  }
}