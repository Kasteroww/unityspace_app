import 'package:flutter/material.dart';
import 'package:unityspace/models/model_interfaces.dart';
import 'package:unityspace/service/exceptions/data_exceptions.dart';
import 'package:unityspace/utils/date_time_converter.dart';
import 'package:unityspace/utils/extensions/color_extension.dart';
import 'package:unityspace/utils/helpers.dart' as helpers;
import 'package:unityspace/utils/helpers.dart';

class SpaceResponse {
  final int id;
  final String name;
  final int creatorId;
  final List<SpaceMemberResponse> members;
  final List<SpaceColumnResponse> columns;
  final List<SpaceColumnResponse> reglamentColumns;
  final List<SpaceInviteResponse> invites;
  final SpaceShareLinkResponse shareLink;
  final String order;
  final int favorite;
  final int archiveColumnId;
  final int archiveReglamentColumnId;
  final int? backgroundId;
  final String? customBackground;
  final int icon;
  final String? iconColor;
  final bool isArchived;
  final int? groupId;
  final String? dateArchived;
  final String? repositoryLink;
  final String createdAt;

  const SpaceResponse({
    required this.id,
    required this.name,
    required this.creatorId,
    required this.members,
    required this.columns,
    required this.reglamentColumns,
    required this.invites,
    required this.shareLink,
    required this.order,
    required this.favorite,
    required this.archiveColumnId,
    required this.archiveReglamentColumnId,
    required this.backgroundId,
    required this.customBackground,
    required this.icon,
    required this.iconColor,
    required this.isArchived,
    required this.groupId,
    required this.dateArchived,
    required this.repositoryLink,
    required this.createdAt,
  });

  factory SpaceResponse.fromJson(Map<String, dynamic> map) {
    try {
      final membersList = map['members'] as List<dynamic>;
      final invitesList = map['invites'] as List<dynamic>;
      final columnsList = map['columns'] as List<dynamic>;
      final reglamentColumnsList = map['reglamentColumns'] as List<dynamic>;
      final shareLinkData = map['shareLink'] as Map<String, dynamic>;
      return SpaceResponse(
        id: map['id'] as int,
        name: map['name'] as String,
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
        shareLink: SpaceShareLinkResponse.fromJson(shareLinkData),
        order: map['order'] as String,
        favorite: map['favorite'] as int,
        archiveColumnId: map['archiveColumnId'] as int,
        archiveReglamentColumnId: map['archiveReglamentColumnId'] as int,
        backgroundId: map['backgroundId'] as int?,
        customBackground: map['customBackground'] as String?,
        icon: map['icon'] as int,
        iconColor: map['iconColor'] as String?,
        isArchived: map['isArchived'] as bool,
        groupId: map['groupId'] as int?,
        dateArchived: map['dateArchived'] as String?,
        repositoryLink: map['repositoryLink'] as String?,
        createdAt: map['createdAt'] as String,
      );
    } catch (e, stack) {
      throw JsonParsingException('Error parsing Model', e, stack);
    }
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
    try {
      return SpaceShareLinkResponse(
        token: map['token'] as String,
        active: map['active'] as bool,
      );
    } catch (e, stack) {
      throw JsonParsingException('Error parsing Model', e, stack);
    }
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
    try {
      return SpaceInviteResponse(
        id: map['id'] as int,
        email: map['email'] as String,
      );
    } catch (e, stack) {
      throw JsonParsingException('Error parsing Model', e, stack);
    }
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
    try {
      return SpaceColumnResponse(
        id: map['id'] as int,
        name: map['name'] as String,
        order: map['order'] as int,
        spaceId: map['spaceId'] as int,
      );
    } catch (e, stack) {
      throw JsonParsingException('Error parsing Model', e, stack);
    }
  }
}

class SpaceMemberResponse {
  final int id;
  final String email;
  final String name;
  final String? avatar;
  final int role;

  const SpaceMemberResponse({
    required this.id,
    required this.email,
    required this.name,
    required this.avatar,
    required this.role,
  });

  factory SpaceMemberResponse.fromJson(Map<String, dynamic> map) {
    try {
      return SpaceMemberResponse(
        id: map['id'] as int,
        email: map['email'] as String,
        name: map['name'] as String,
        avatar: map['avatar'] as String?,
        role: map['role'] as int,
      );
    } catch (e, stack) {
      throw JsonParsingException('Error parsing Model', e, stack);
    }
  }
}

class Space implements Identifiable, Nameable {
  @override
  final int id;
  @override
  final String name;
  final int creatorId;
  final List<SpaceMember> members;
  final List<SpaceColumn> columns;
  final List<SpaceColumn> reglamentColumns;
  final List<SpaceInvite> invites;
  final SpaceShareLink shareLink;
  final double order;
  final bool favorite;
  final int archiveColumnId;
  final int archiveReglamentColumnId;
  final int backgroundId;
  final String? customBackground;
  final int icon;
  final Color? iconColor;
  final bool isArchived;
  final int? groupId;
  final DateTime? dateArchived;
  final String? repositoryLink;

  Space({
    required this.id,
    required this.name,
    required this.creatorId,
    required this.members,
    required this.columns,
    required this.reglamentColumns,
    required this.invites,
    required this.shareLink,
    required this.order,
    required this.favorite,
    required this.archiveColumnId,
    required this.archiveReglamentColumnId,
    required this.backgroundId,
    required this.customBackground,
    required this.icon,
    required this.iconColor,
    required this.isArchived,
    required this.groupId,
    required this.dateArchived,
    required this.repositoryLink,
  });

  factory Space.fromResponse(final SpaceResponse data) {
    // Пока поставим дефолтный как белый
    String hexString = data.iconColor ?? 'FFFFFF';
    if (hexString.isEmpty) {
      hexString = 'FFFFFF';
    }
    return Space(
      id: data.id,
      name: data.name,
      creatorId: data.creatorId,
      members: data.members.map(SpaceMember.fromResponse).toList(),
      columns: data.columns.map(SpaceColumn.fromResponse).toList(),
      reglamentColumns:
          data.reglamentColumns.map(SpaceColumn.fromResponse).toList(),
      invites: data.invites.map(SpaceInvite.fromResponse).toList(),
      shareLink: SpaceShareLink.fromResponse(data.shareLink),
      order: helpers.convertFromOrderResponse(int.parse(data.order)),
      favorite: data.favorite != 0,
      archiveColumnId: data.archiveColumnId,
      archiveReglamentColumnId: data.archiveReglamentColumnId,
      backgroundId: data.backgroundId ?? 0,
      customBackground: data.customBackground != null
          ? mapFileUidToFileLink('${data.customBackground}')
          : null,
      icon: data.icon,
      iconColor: HexColor.fromHex(hexString),
      isArchived: data.isArchived,
      groupId: data.groupId,
      dateArchived: data.dateArchived != null
          ? DateTimeConverter.stringToLocalDateTime(data.dateArchived!)
          : null,
      repositoryLink: data.repositoryLink,
    );
  }

  @override
  String toString() {
    return 'Space('
        'id: $id, '
        'name: $name, '
        'creatorId: $creatorId, '
        'members: $members, '
        'columns: $columns, '
        'reglamentColumns: $reglamentColumns, '
        'invites: $invites, '
        'shareLink: $shareLink, '
        'order: $order, '
        'favorite: $favorite, '
        'archiveColumnId: $archiveColumnId, '
        'archiveReglamentColumnId: $archiveReglamentColumnId, '
        'backgroundId: $backgroundId, '
        'customBackground: $customBackground, '
        'icon: $icon, '
        'iconColor: $iconColor, '
        'isArchived: $isArchived, '
        'groupId: $groupId, '
        'dateArchived: $dateArchived, '
        'repositoryLink: $repositoryLink'
        ')';
  }

  Space copyWith({
    int? id,
    String? name,
    int? creatorId,
    List<SpaceMember>? members,
    List<SpaceColumn>? columns,
    List<SpaceColumn>? reglamentColumns,
    List<SpaceInvite>? invites,
    SpaceShareLink? shareLink,
    double? order,
    bool? favorite,
    int? archiveColumnId,
    int? archiveReglamentColumnId,
    int? backgroundId,
    String? customBackground,
    int? icon,
    Color? iconColor,
    bool? isArchived,
    int? groupId,
    DateTime? dateArchived,
    String? repositoryLink,
  }) {
    return Space(
      id: id ?? this.id,
      name: name ?? this.name,
      creatorId: creatorId ?? this.creatorId,
      members: members ?? this.members,
      columns: columns ?? this.columns,
      reglamentColumns: reglamentColumns ?? this.reglamentColumns,
      invites: invites ?? this.invites,
      shareLink: shareLink ?? this.shareLink,
      order: order ?? this.order,
      favorite: favorite ?? this.favorite,
      archiveColumnId: archiveColumnId ?? this.archiveColumnId,
      archiveReglamentColumnId:
          archiveReglamentColumnId ?? this.archiveReglamentColumnId,
      backgroundId: backgroundId ?? this.backgroundId,
      customBackground: customBackground ?? this.customBackground,
      icon: icon ?? this.icon,
      iconColor: iconColor ?? this.iconColor,
      isArchived: isArchived ?? this.isArchived,
      groupId: groupId ?? this.groupId,
      dateArchived: dateArchived ?? this.dateArchived,
      repositoryLink: repositoryLink ?? this.repositoryLink,
    );
  }
}

class SpaceShareLink {
  final bool active;
  final String token;

  SpaceShareLink({required this.active, required this.token});

  factory SpaceShareLink.fromResponse(final SpaceShareLinkResponse data) {
    return SpaceShareLink(active: data.active, token: data.token);
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

class SpaceColumn implements Identifiable, Nameable {
  @override
  final int id;
  @override
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
      order: helpers.convertFromOrderResponse(data.order),
      spaceId: data.spaceId,
    );
  }

  @override
  String toString() {
    return 'SpaceColumn{id: $id, name: $name, order: $order, spaceId: $spaceId}';
  }
}

class SpaceMember implements Nameable {
  final int id;
  final String email;
  @override
  final String name;
  final String? avatarLink;
  final int role;

  const SpaceMember({
    required this.id,
    required this.email,
    required this.name,
    required this.avatarLink,
    required this.role,
  });

  factory SpaceMember.fromResponse(final SpaceMemberResponse data) {
    return SpaceMember(
      id: data.id,
      email: data.email,
      name: data.name,
      avatarLink: helpers.makeAvatarUrl(data.avatar),
      role: data.role,
    );
  }

  SpaceMember copyWith({
    int? id,
    String? email,
    String? name,
    String? avatarLink,
    int? role,
  }) {
    return SpaceMember(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      avatarLink: avatarLink ?? this.avatarLink,
      role: role ?? this.role,
    );
  }
}

class RemoveMemberFromSpaceResponse {
  final int uniqueSpaceUsersCount;
  final String status;
  final String message;

  const RemoveMemberFromSpaceResponse({
    required this.uniqueSpaceUsersCount,
    required this.status,
    required this.message,
  });

  factory RemoveMemberFromSpaceResponse.fromJson(Map<String, dynamic> map) {
    try {
      return RemoveMemberFromSpaceResponse(
        uniqueSpaceUsersCount: map['uniqueSpaceUsersCount'] as int,
        status: map['status'] as String,
        message: map['message'] as String,
      );
    } catch (e, stack) {
      throw JsonParsingException(
        'Error parsing RemoveMemberFromSpaceResponse Model',
        e,
        stack,
      );
    }
  }
}

class SetSpaceInviteLinkActiveResponse {
  int id;
  String token;
  bool active;

  SetSpaceInviteLinkActiveResponse({
    required this.id,
    required this.token,
    required this.active,
  });

  factory SetSpaceInviteLinkActiveResponse.fromJson(Map<String, dynamic> map) {
    try {
      return SetSpaceInviteLinkActiveResponse(
        id: map['id'] as int,
        token: map['token'] as String,
        active: map['active'] as bool,
      );
    } catch (e, stack) {
      throw JsonParsingException(
        'Error parsing SetSpaceIviteLinkActiveResponse Model',
        e,
        stack,
      );
    }
  }
}

class SetSpaceMemberRoleResponse {
  int memberId;
  int spaceId;
  int role;
  int favorite;

  SetSpaceMemberRoleResponse({
    required this.memberId,
    required this.spaceId,
    required this.role,
    required this.favorite,
  });

  factory SetSpaceMemberRoleResponse.fromJson(Map<String, dynamic> map) {
    return SetSpaceMemberRoleResponse(
      memberId: map['userId'] as int,
      spaceId: map['spaceId'] as int,
      role: map['role'] as int,
      favorite: map['favorite'] as int,
    );
  }
}
