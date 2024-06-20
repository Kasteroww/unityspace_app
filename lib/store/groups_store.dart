import 'package:unityspace/models/groups_models.dart';
import 'package:unityspace/service/groups_service.dart' as api;
import 'package:unityspace/store/store_exceptions.dart';
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
    groups.sort((a, b) => a.order.compareTo(b.order));
    for (int i = 1; i < groups.length; i++) {
      if (groups[i].order == groups[i - 1].order) {
        groups[i] = groups[i].copyWith(order: groups[i].order + 1);
      }
    }

    setStore(() {
      this.groups.clear();
      this.groups.addAll(groups);
    });
  }

  Future<void> updateGroupName({
    required int id,
    required String newName,
  }) async {
    final UpdateGroupName result = UpdateGroupName.fromResponse(
      await api.updateGroupName(
        id: id,
        newName: newName,
      ),
    );

    if (result.id == id && groups[id] != null) {
      final updatedGroup = groups[result.id]!.copyWith(name: result.name);
      setStore(() {
        groups.add(updatedGroup);
      });
    } else {
      throw UpdatingNonexistentEntityStoreException(
        message: 'The group with ID $result.id does not exist in the store.',
        data: {
          'request id': id,
          'response id': result.id,
        },
      );
    }
  }

  Future<void> updateGroupOpen({required int id, required bool isOpen}) async {
    final result = UpdateGroupOpen.fromResponse(
      await api.updateGroupOpen(id: id, isOpen: isOpen),
    );
    if (result.id == id && groups[id] != null) {
      final updatedGroup = groups[result.id]!.copyWith(isOpen: result.isOpen);
      setStore(() {
        groups.add(updatedGroup);
      });
    } else {
      throw UpdatingNonexistentEntityStoreException(
        message: 'The group with ID $result.id does not exist in the store.',
        data: {
          'request id': id,
          'response id': result.id,
        },
      );
    }
  }

  void empty() {
    setStore(() {
      groups.clear();
    });
  }
}
