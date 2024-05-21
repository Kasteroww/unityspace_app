import 'package:unityspace/models/i_base_model.dart';
import 'package:unityspace/utils/helpers.dart' as helpers;

class SpaceResponse {
  final int id;
  final String createdAt;
  final String name;
  final String order;
  final int creatorId;
  final List<SpaceMemberResponse> members;
  final List<SpaceColumnResponse> columns;
  final List<SpaceColumnResponse> reglamentColumns;
  final List<SpaceInviteResponse> invites;
  final int? backgroundId;
  final int favorite;
  final int archiveColumnId;
  final int archiveReglamentColumnId;
  final SpaceShareLinkResponse shareLink;

  const SpaceResponse({
    required this.id,
    required this.createdAt,
    required this.name,
    required this.order,
    required this.creatorId,
    required this.members,
    required this.columns,
    required this.reglamentColumns,
    required this.invites,
    required this.backgroundId,
    required this.favorite,
    required this.archiveColumnId,
    required this.archiveReglamentColumnId,
    required this.shareLink,
  });

  factory SpaceResponse.fromJson(Map<String, dynamic> map) {
    final membersList = map['members'] as List<dynamic>;
    final invitesList = map['invites'] as List<dynamic>;
    final columnsList = map['columns'] as List<dynamic>;
    final reglamentColumnsList = map['reglamentColumns'] as List<dynamic>;
    final shareLinkData = map['shareLink'] as Map<String, dynamic>;
    return SpaceResponse(
      id: map['id'] as int,
      createdAt: map['createdAt'] as String,
      name: map['name'] as String,
      order: map['order'] as String,
      creatorId: map['creatorId'] as int,
      members: membersList
          .map((member) => SpaceMemberResponse.fromJson(member))
          .toList(),
      columns: columnsList
          .map((column) => SpaceColumnResponse.fromJson(column))
          .toList(),
      reglamentColumns: reglamentColumnsList
          .map((column) => SpaceColumnResponse.fromJson(column))
          .toList(),
      invites: invitesList
          .map((invite) => SpaceInviteResponse.fromJson(invite))
          .toList(),
      backgroundId: map['backgroundId'] as int?,
      favorite: map['favorite'] as int,
      archiveColumnId: map['archiveColumnId'] as int,
      archiveReglamentColumnId: map['archiveReglamentColumnId'] as int,
      shareLink: SpaceShareLinkResponse.fromJson(shareLinkData),
    );
  }
}

class SpaceShareLinkResponse {
  final String token;
  final bool active;

  const SpaceShareLinkResponse({
    required this.token,
    required this.active,
  });

  factory SpaceShareLinkResponse.fromJson(Map<String, dynamic> map) {
    return SpaceShareLinkResponse(
      token: map['token'] as String,
      active: map['active'] as bool,
    );
  }
}

class SpaceInviteResponse {
  final int id;
  final String email;

  const SpaceInviteResponse({
    required this.id,
    required this.email,
  });

  factory SpaceInviteResponse.fromJson(Map<String, dynamic> map) {
    return SpaceInviteResponse(
      id: map['id'] as int,
      email: map['email'] as String,
    );
  }
}

class SpaceColumnResponse {
  final int id;
  final String name;
  final int order;
  final int spaceId;

  const SpaceColumnResponse({
    required this.id,
    required this.name,
    required this.order,
    required this.spaceId,
  });

  factory SpaceColumnResponse.fromJson(Map<String, dynamic> map) {
    return SpaceColumnResponse(
      id: map['id'] as int,
      name: map['name'] as String,
      order: map['order'] as int,
      spaceId: map['spaceId'] as int,
    );
  }
}

class SpaceMemberResponse {
  final int id;
  final String email;
  final String name;
  final String? avatar;

  const SpaceMemberResponse({
    required this.id,
    required this.email,
    required this.name,
    required this.avatar,
  });

  factory SpaceMemberResponse.fromJson(Map<String, dynamic> map) {
    return SpaceMemberResponse(
      id: map['id'] as int,
      email: map['email'] as String,
      name: map['name'] as String,
      avatar: map['avatar'] as String?,
    );
  }
}

class Space implements BaseModel {
  @override
  final int id;
  final String name;
  final double order;
  final List<SpaceMember> members;
  final List<SpaceColumn> columns;
  final List<SpaceColumn> reglamentColumns;
  final List<SpaceInvite> invites;
  final int backgroundId;
  final bool favorite;
  final int archiveColumnId;
  final int archiveReglamentColumnId;
  final String shareLinkToken;
  final bool shareLinkActive;

  const Space({
    required this.id,
    required this.name,
    required this.order,
    required this.members,
    required this.columns,
    required this.reglamentColumns,
    required this.invites,
    required this.backgroundId,
    required this.favorite,
    required this.archiveColumnId,
    required this.archiveReglamentColumnId,
    required this.shareLinkToken,
    required this.shareLinkActive,
  });

  factory Space.fromResponse(final SpaceResponse data) {
    return Space(
      id: data.id,
      name: data.name,
      order: helpers.makeOrderFromInt(int.parse(data.order)),
      members: data.members.map(SpaceMember.fromResponse).toList(),
      columns: data.columns.map(SpaceColumn.fromResponse).toList(),
      reglamentColumns:
          data.reglamentColumns.map(SpaceColumn.fromResponse).toList(),
      invites: data.invites.map(SpaceInvite.fromResponse).toList(),
      backgroundId: data.backgroundId ?? 0,
      favorite: data.favorite != 0,
      archiveColumnId: data.archiveColumnId,
      archiveReglamentColumnId: data.archiveReglamentColumnId,
      shareLinkToken: data.shareLink.token,
      shareLinkActive: data.shareLink.active,
    );
  }

  @override
  String toString() {
    return 'Space{id: $id, name: $name, order: $order, members: $members, columns: $columns, reglamentColumns: $reglamentColumns, invites: $invites, backgroundId: $backgroundId, favorite: $favorite, archiveColumnId: $archiveColumnId, archiveReglamentColumnId: $archiveReglamentColumnId, shareLinkToken: $shareLinkToken, shareLinkActive: $shareLinkActive}';
  }
}

class SpaceInvite {
  final int id;
  final String email;

  const SpaceInvite({
    required this.id,
    required this.email,
  });

  factory SpaceInvite.fromResponse(final SpaceInviteResponse data) {
    return SpaceInvite(
      id: data.id,
      email: data.email,
    );
  }

  @override
  String toString() {
    return 'SpaceInvite{id: $id, email: $email}';
  }
}

class SpaceColumn {
  final int id;
  final String name;
  final double order;
  final int spaceId;

  const SpaceColumn({
    required this.id,
    required this.name,
    required this.order,
    required this.spaceId,
  });

  factory SpaceColumn.fromResponse(final SpaceColumnResponse data) {
    return SpaceColumn(
      id: data.id,
      name: data.name,
      order: helpers.makeOrderFromInt(data.order),
      spaceId: data.spaceId,
    );
  }

  @override
  String toString() {
    return 'SpaceColumn{id: $id, name: $name, order: $order, spaceId: $spaceId}';
  }
}

class SpaceMember {
  final int id;
  final String email;
  final String name;
  final String? avatarLink;

  const SpaceMember({
    required this.id,
    required this.email,
    required this.name,
    required this.avatarLink,
  });

  factory SpaceMember.fromResponse(final SpaceMemberResponse data) {
    return SpaceMember(
      id: data.id,
      email: data.email,
      name: data.name,
      avatarLink: helpers.makeAvatarUrl(data.avatar),
    );
  }

  @override
  String toString() {
    return 'SpaceMember{id: $id, email: $email, name: $name, avatarLink: $avatarLink}';
  }

  SpaceMember copyWith({
    int? id,
    String? email,
    String? name,
    String? avatarLink,
  }) {
    return SpaceMember(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      avatarLink: avatarLink ?? this.avatarLink,
    );
  }
}
