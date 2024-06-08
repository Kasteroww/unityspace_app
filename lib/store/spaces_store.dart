import 'dart:async';

import 'package:collection/collection.dart';
import 'package:unityspace/models/spaces_models.dart';
import 'package:unityspace/screens/space_screen/pages/project_content/utils/helpers/role.dart';
import 'package:unityspace/service/spaces_service.dart' as api;
import 'package:unityspace/store/user_store.dart';
import 'package:wstore/wstore.dart';

class Spaces with GStoreChangeObjectMixin {
  final Map<int, Space> _spacesMap = {};
  final Map<int, SpaceColumn> _columnsMap = {};

  Spaces();

  void add(Space space) {
    _setSpace(space);
    incrementObjectChangeCount();
  }

  void addAll(Iterable<Space> all) {
    if (all.isNotEmpty) {
      for (final space in all) {
        _setSpace(space);
      }
      incrementObjectChangeCount();
    }
  }

  void remove(int spaceId) {
    _removeSpace(spaceId);
    incrementObjectChangeCount();
  }

  void clear() {
    if (_spacesMap.isNotEmpty) {
      _spacesMap.clear();
      _columnsMap.clear();
      incrementObjectChangeCount();
    }
  }

  double getNextOrder() {
    if (_spacesMap.isEmpty) return 1;
    final maxOrder = _spacesMap.values.fold<double>(
      0,
      (max, space) => max > space.order ? max : space.order,
    );
    return maxOrder + 1;
  }

  void _setSpace(Space space) {
    _removeSpace(space.id);
    _spacesMap[space.id] = space;
    for (final column in space.columns) {
      _columnsMap[column.id] = column;
    }
  }

  void _removeSpace(int id) {
    final oldSpace = _spacesMap.remove(id);
    if (oldSpace != null) {
      for (final column in oldSpace.columns) {
        _columnsMap.remove(column.id);
      }
    }
  }

  Space? operator [](int id) => _spacesMap[id];

  Iterable<Space> get list => _spacesMap.values;

  int get length => _spacesMap.length;

  Map<int, SpaceColumn> get columnsMap => _columnsMap;
}

class SpacesStore extends GStore {
  static SpacesStore? _instance;

  factory SpacesStore() => _instance ??= SpacesStore._();

  SpacesStore._();

  Spaces spaces = Spaces();
  int masterSpaceId = -1;

  Future<void> getSpacesData() async {
    final spacesData = await api.getSpacesData();
    final loadedSpaces = spacesData.map(Space.fromResponse);
    setStore(() {
      spaces.clear();
      spaces.addAll(loadedSpaces);
    });
  }

  Future<void> removeUserFromSpace(final int memberId) async {
    final listToRemove = <(int, int)>[];
    for (final space in spaces.list) {
      if (space.members.any((member) => member.id == memberId)) {
        listToRemove.add((space.id, memberId));
      }
    }
    if (listToRemove.isEmpty) return;
    int uniqueSpaceUsersCountResult = 0;
    for (final (spaceId, memberId) in listToRemove) {
      final response = await api.removeUserFromSpace(spaceId, memberId);
      uniqueSpaceUsersCountResult = response.uniqueSpaceUsersCount;
      _removeUserFromSpaceLocally(spaceId: spaceId, memberId: memberId);
    }
    UserStore().setUniqueSpaceUsersCountLocally(uniqueSpaceUsersCountResult);
  }

  void _removeUserFromSpaceLocally({
    required int spaceId,
    required int memberId,
  }) {
    final space = spaces[spaceId];
    if (space == null) return;
    if (space.members.every((member) => member.id != memberId)) return;
    final newMembers = space.members
        .where(
          (member) => member.id != memberId,
        )
        .toList();
    setStore(() {
      spaces.add(space.copyWith(members: newMembers));
    });
  }

  Future<int> createSpace(final String title) async {
    final newOrder = spaces.getNextOrder();
    final spaceData = await api.createSpaces(
      title,
      newOrder,
    );
    final newSpace = Space.fromResponse(spaceData);
    setStore(() {
      spaces.add(newSpace);
    });
    return newSpace.id;
  }

  void changeSpaceMemberEmailLocally({
    required int userId,
    required String newEmail,
  }) {
    for (final space in spaces.list) {
      final member = space.members.firstWhereOrNull((m) => m.id == userId);
      if (member != null) {
        final SpaceMember updatedMember = member.copyWith(email: newEmail);
        final memberIndex = space.members.indexOf(member);
        setStore(() {
          space.members[memberIndex] = updatedMember;
        });
      }
    }
  }

  UserRoles? getCurrentUserRoleAtSpace({required int? spaceId}) {
    if (spaceId == null) return null;
    final userId = UserStore().user?.id;
    if (userId == null) return null;
    if (UserStore().isOrganizationOwner || UserStore().isAdmin) {
      return UserRoles.member;
    }
    final space = spaces[spaceId];
    if (space == null) return null;
    final member = space.members.firstWhereOrNull(
      (member) => member.id == userId,
    );
    if (member == null) return null;
    return getUserRole(member.role);
  }

  @override
  void clear() {
    super.clear();
    setStore(() {
      spaces.clear();
    });
  }
}
