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

  SpaceColumn? getColumnById(int columnId) => _columnsMap[columnId];

  Iterable<Space> get list => _spacesMap.values;

  int get length => _spacesMap.length;
}

class SpacesStore extends GStore {
  static SpacesStore? _instance;

  factory SpacesStore() => _instance ??= SpacesStore._();

  SpacesStore._();

  Spaces spaces = Spaces();

  Future<void> getSpacesData() async {
    final spacesData = await api.getSpacesData();
    final loadedSpaces = spacesData.map(Space.fromResponse);
    setStore(() {
      spaces.clear();
      spaces.addAll(loadedSpaces);
    });
  }

  Future<int?> removeUserFromSpaces(final int memberId) async {
    final listToRemove = <(int, int)>[];
    for (final space in spaces.list) {
      if (space.members.any((member) => member.id == memberId)) {
        listToRemove.add((space.id, memberId));
      }
    }
    if (listToRemove.isEmpty) return null;
    int uniqueSpaceUsersCountResult = 0;
    for (final (spaceId, memberId) in listToRemove) {
      final response = await api.removeUserFromSpace(spaceId, memberId);
      uniqueSpaceUsersCountResult = response.uniqueSpaceUsersCount;
      _removeUserFromSpaceLocally(spaceId: spaceId, memberId: memberId);
    }
    return uniqueSpaceUsersCountResult;
  }

  Future<int?> removeUserFromSpace(
    final int memberId,
    final int spaceId,
  ) async {
    final response = await api.removeUserFromSpace(spaceId, memberId);
    _removeUserFromSpaceLocally(spaceId: spaceId, memberId: memberId);
    return response.uniqueSpaceUsersCount;
  }

  Future<void> setSpaceMemberRole(
    final int memberId,
    final int spaceId,
    final int role,
  ) async {
    final response = await api.setSpaceMemberRole(
      spaceId: spaceId,
      memberId: memberId,
      role: role,
    );
    _setSpaceMemberRoleLocally(
      response.spaceId,
      response.memberId,
      response.role,
    );
  }

  void _setSpaceMemberRoleLocally(int spaceId, int memberId, int role) {
    final space = spaces[spaceId];
    if (space == null) return;
    final members = space.members;
    final memberIndex = members.indexWhere((member) => member.id == memberId);
    members[memberIndex] = members[memberIndex].copyWith(role: role);
    setStore(() {
      spaces.add(space.copyWith(members: members));
    });
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

  Future<int> removeInviteFromSpace(
    final int spaceId,
    final int inviteId,
  ) async {
    final response =
        await api.removeInviteFromSpace(spaceId: spaceId, inviteId: inviteId);
    _removeInviteFromSpaceLocally(spaceId, inviteId);
    return response.uniqueSpaceUsersCount;
  }

  void _removeInviteFromSpaceLocally(final int spaceId, final int inviteId) {
    final space = spaces[spaceId];
    if (space == null) return;
    final newInvites =
        space.invites.where((invite) => invite.id != inviteId).toList();
    setStore(() {
      spaces.add(space.copyWith(invites: newInvites));
    });
  }

  Future<SpaceColumn> createSpaceColumn({
    required int spaceId,
    required String name,
    required double order,
  }) async {
    final space = spaces[spaceId];
    final response =
        await api.createSpaceColumn(spaceId: spaceId, name: name, order: order);
    final newColumn = SpaceColumn.fromResponse(response);
    _updateSpaceColumnsLocally(space: space, newColumn: newColumn);
    return newColumn;
  }

  void _updateSpaceColumnsLocally({
    required Space? space,
    required SpaceColumn newColumn,
  }) {
    final spaceColumns = space?.columns ?? [];
    if (!spaceColumns.contains(newColumn)) {
      if (space != null) {
        setStore(() {
          spaces.add(space.copyWith(columns: [...spaceColumns, newColumn]));
        });
      }
    }
  }

  Future<void> setSpaceIviteLinkActive({
    required int spaceId,
    required bool isActive,
  }) async {
    final responce =
        await api.setSpaceIviteLinkActive(spaceId: spaceId, isActive: isActive);
    _updateSpaceIviteLinkActiveLocally(
      spaceId: spaceId,
      isActive: responce.active,
      token: responce.token,
    );
  }

  void _updateSpaceIviteLinkActiveLocally({
    required int spaceId,
    required bool isActive,
    required String token,
  }) {
    final space = spaces[spaceId];
    if (space == null) return;
    setStore(() {
      spaces.add(
        space.copyWith(
          shareLink: SpaceShareLink(active: isActive, token: token),
        ),
      );
    });
  }

  void empty() {
    setStore(() {
      spaces.clear();
    });
  }
}
