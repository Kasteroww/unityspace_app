import 'dart:async';

import 'package:collection/collection.dart';
import 'package:unityspace/models/spaces_models.dart';
import 'package:unityspace/screens/space_screen/pages/project_content/utils/helpers/role.dart';
import 'package:unityspace/service/spaces_service.dart' as api;
import 'package:unityspace/store/user_store.dart';
import 'package:unityspace/utils/helpers.dart';
import 'package:wstore/wstore.dart';

class SpacesStore extends GStore {
  static SpacesStore? _instance;

  factory SpacesStore() => _instance ??= SpacesStore._();

  SpacesStore._();

  List<Space> spaces = [];
  int masterSpaceId = -1;

  Map<int, Space?> get spacesMap => computed(
        watch: () => [spaces],
        keyName: 'spacesMap',
        getValue: () {
          return createMapById(spaces);
        },
      );

  Map<int, Map<int, SpaceMember?>> get spacesMapUser => computed(
        watch: () => [spaces],
        keyName: 'spacesMapUser',
        getValue: () {
          if (spaces.isEmpty) return {};

          return spaces.fold<Map<int, Map<int, SpaceMember?>>>({},
              (acc, space) {
            acc[space.id] =
                space.members.fold<Map<int, SpaceMember?>>({}, (userAcc, user) {
              userAcc[user.id] = user;
              return userAcc;
            });
            return acc;
          });
        },
      );

  Map<int, SpaceColumn?> get columnsMap {
    if (spaces == []) return {};
    return {
      for (final column in spaces.expand((space) => space.columns))
        column.id: column,
    };
  }

  Future<void> getSpacesData() async {
    final spacesData = await api.getSpacesData();
    final spaces = spacesData.map(Space.fromResponse).toList();
    setStore(() {
      this.spaces = spaces;
    });
  }

  Future<int> removeUserFromSpace(final int memberId) async {
    int uniqueSpaceUsersCountResult = 0;
    for (final space in spacesMapUser.entries) {
      if (space.value.values.any((member) => member?.id == memberId)) {
        final response = await api.removeUserFromSpace(space.key, memberId);
        uniqueSpaceUsersCountResult = response.uniqueSpaceUsersCount;
        _removeUserFromSpaceLocally(spaceId: space.key, memberId: memberId);
      }
    }
    return uniqueSpaceUsersCountResult;
  }

  void _removeUserFromSpaceLocally({
    required int spaceId,
    required int memberId,
  }) {
    if (spaces.isNotEmpty) {
      final spaceIndex = spaces.indexWhere((space) => space.id == spaceId);
      if (spaceIndex != -1) {
        setStore(() {
          spaces[spaceIndex] = spaces[spaceIndex].copyWith(
            members: spaces[spaceIndex]
                .members
                .where((member) => member.id != memberId)
                .toList(),
          );
        });
      }
    }
  }

  Future<int> createSpace(final String title) async {
    final maxOrder = this.spaces.fold<double>(
          0,
          (max, space) => max > space.order ? max : space.order,
        );
    final newOrder = maxOrder + 1;
    final spaceData = await api.createSpaces(
      title,
      newOrder,
    );
    final newSpace = Space.fromResponse(spaceData);
    final spaces = [...this.spaces, newSpace];
    setStore(() {
      this.spaces = spaces;
    });
    return newSpace.id;
  }

  void changeSpaceMemberEmailLocally({
    required int userId,
    required String newEmail,
  }) {
    if (spaces.isNotEmpty) {
      for (final space in spaces) {
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
  }

  UserRoles? getCurrentUserRoleAtSpace({required int? spaceId}) {
    {
      if (spaceId == null) return null;
      final userId = UserStore().user?.id;
      if (userId == null) return null;
      if (UserStore().isOrganizationOwner || UserStore().isAdmin) {
        return UserRoles.member;
      }
      final role = spacesMapUser[spaceId]?[userId]?.role;
      if (role != null) {
        return getUserRole(role);
      }
    }
    return UserRoles.reader;
  }

  @override
  void clear() {
    super.clear();
    setStore(() {
      spaces = [];
    });
  }
}
