import 'package:unityspace/models/model_interfaces.dart';
import 'package:unityspace/service/data_exceptions.dart';
import 'package:unityspace/utils/helpers.dart' as helpers;

class UserResponse {
  final int id;
  final int globalId;
  final String name;
  final String email;
  final String? avatar;
  final String? phoneNumber;
  final String? telegramLink;
  final String? githubLink;
  final String? birthDate;
  final String? jobTitle;
  final bool isAdmin;

  const UserResponse({
    required this.id,
    required this.globalId,
    required this.name,
    required this.email,
    required this.avatar,
    required this.phoneNumber,
    required this.telegramLink,
    required this.githubLink,
    required this.birthDate,
    required this.jobTitle,
    required this.isAdmin,
  });

  factory UserResponse.fromJson(Map<String, dynamic> map) {
    try {
      return UserResponse(
        id: map['id'] as int,
        globalId: map['globalId'] as int,
        name: map['name'] as String,
        email: map['email'] as String,
        avatar: map['avatar'] as String?,
        phoneNumber: map['phoneNumber'] as String?,
        telegramLink: map['telegramLink'] as String?,
        githubLink: map['githubLink'] as String?,
        birthDate: map['birthDate'] as String?,
        jobTitle: map['jobTitle'] as String?,
        isAdmin: map['isAdmin'] as bool,
      );
    } catch (e, stack) {
      throw JsonParsingException('Error parsing Model', e, stack);
    }
  }
}

class User {
  final int id;
  final int globalId;
  final String name;
  final String email;
  final String? avatarLink;
  final String? phoneNumber;
  final String? telegramLink;
  final String? githubLink;
  final DateTime? birthDate;
  final String? jobTitle;
  final bool isAdmin;

  const User({
    required this.id,
    required this.globalId,
    required this.name,
    required this.email,
    required this.avatarLink,
    required this.phoneNumber,
    required this.telegramLink,
    required this.githubLink,
    required this.birthDate,
    required this.jobTitle,
    required this.isAdmin,
  });

  factory User.fromResponse(final UserResponse data) {
    return User(
      id: data.id,
      globalId: data.globalId,
      name: data.name,
      email: data.email,
      avatarLink: helpers.makeAvatarUrl(data.avatar),
      phoneNumber: helpers.getNullStringIfEmpty(data.phoneNumber),
      telegramLink: helpers.getNullStringIfEmpty(data.telegramLink),
      githubLink: helpers.getNullStringIfEmpty(data.githubLink),
      birthDate:
          data.birthDate != null ? DateTime.parse(data.birthDate!) : null,
      jobTitle: helpers.getNullStringIfEmpty(data.jobTitle),
      isAdmin: data.isAdmin,
    );
  }

  @override
  String toString() {
    return 'User{id: $id, globalId: $globalId, name: $name, email: $email, avatarLink: $avatarLink, phoneNumber: $phoneNumber, telegramLink: $telegramLink, githubLink: $githubLink, birthDate: $birthDate, jobTitle: $jobTitle, isAdmin: $isAdmin}';
  }

  User copyWith({
    int? id,
    int? globalId,
    String? name,
    String? email,
    String? avatarLink,
    String? phoneNumber,
    String? telegramLink,
    String? githubLink,
    DateTime? birthDate,
    String? jobTitle,
    bool? isAdmin,
  }) {
    return User(
      id: id ?? this.id,
      globalId: globalId ?? this.globalId,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarLink: avatarLink ?? this.avatarLink,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      telegramLink: telegramLink ?? this.telegramLink,
      githubLink: githubLink ?? this.githubLink,
      birthDate: birthDate ?? this.birthDate,
      jobTitle: jobTitle ?? this.jobTitle,
      isAdmin: isAdmin ?? this.isAdmin,
    );
  }
}

class OrganizationResponse {
  final int id;
  final int ownerId;
  final String createdAt;
  final String updatedAt;
  final int availableUsersCount;
  final String? licenseEndDate;
  final String? trialEndDate;
  final List<OrganizationMemberResponse> members;
  final int uniqueSpaceUsersCount;

  OrganizationResponse({
    required this.id,
    required this.ownerId,
    required this.createdAt,
    required this.updatedAt,
    required this.availableUsersCount,
    required this.licenseEndDate,
    required this.trialEndDate,
    required this.members,
    required this.uniqueSpaceUsersCount,
  });

  factory OrganizationResponse.fromJson(Map<String, dynamic> map) {
    try {
      final membersList = map['members'] as List<dynamic>;
      return OrganizationResponse(
        id: map['id'] as int,
        ownerId: map['ownerId'] as int,
        createdAt: map['createdAt'] as String,
        updatedAt: map['updatedAt'] as String,
        availableUsersCount: map['availableUsersCount'] as int,
        licenseEndDate: map['licenseEndDate'] as String?,
        trialEndDate: map['trialEndDate'] as String?,
        members: membersList
            .map((member) => OrganizationMemberResponse.fromJson(member))
            .toList(),
        uniqueSpaceUsersCount: map['uniqueSpaceUsersCount'] as int,
      );
    } catch (e, stack) {
      throw JsonParsingException('Error parsing Model', e, stack);
    }
  }
}

class OrganizationMemberResponse {
  final String? avatar;
  final String email;
  final String name;
  final int organizationId;
  final int id;
  final List<UserAchievementsResponse> userAchievements;
  final String? phoneNumber;
  final String? telegramLink;
  final String? githubLink;
  final String? birthDate;
  final String? jobTitle;
  final String lastActivityDate;
  final bool isAdmin;

  OrganizationMemberResponse({
    required this.avatar,
    required this.email,
    required this.name,
    required this.organizationId,
    required this.id,
    required this.userAchievements,
    required this.phoneNumber,
    required this.telegramLink,
    required this.githubLink,
    required this.birthDate,
    required this.jobTitle,
    required this.lastActivityDate,
    required this.isAdmin,
  });

  factory OrganizationMemberResponse.fromJson(Map<String, dynamic> map) {
    try {
      final userAchievementsList = map['userAchievements'] as List<dynamic>;
      return OrganizationMemberResponse(
        avatar: map['avatar'] as String?,
        email: map['email'] as String,
        name: map['name'] as String,
        organizationId: map['organizationId'] as int,
        id: map['id'] as int,
        userAchievements: userAchievementsList
            .map((member) => UserAchievementsResponse.fromJson(member))
            .toList(),
        phoneNumber: map['phoneNumber'] as String?,
        telegramLink: map['telegramLink'] as String?,
        githubLink: map['githubLink'] as String?,
        birthDate: map['birthDate'] as String?,
        jobTitle: map['jobTitle'] as String?,
        lastActivityDate: map['lastActivityDate'] as String,
        isAdmin: map['isAdmin'] as bool,
      );
    } catch (e, stack) {
      throw JsonParsingException('Error parsing Model', e, stack);
    }
  }
}

class UserAchievementsResponse {
  final int userId;
  final String achievementType;
  final String dateReceived;

  UserAchievementsResponse({
    required this.userId,
    required this.achievementType,
    required this.dateReceived,
  });

  factory UserAchievementsResponse.fromJson(Map<String, dynamic> map) {
    try {
      return UserAchievementsResponse(
        userId: map['userId'] as int,
        achievementType: map['achievementType'] as String,
        dateReceived: map['dateReceived'] as String,
      );
    } catch (e, stack) {
      throw JsonParsingException('Error parsing Model', e, stack);
    }
  }
}

class Organization {
  final int id;
  final int ownerId;
  final int availableUsersCount;
  final DateTime? licenseEndDate;
  final DateTime? trialEndDate;
  final List<OrganizationMember> members;
  final int uniqueSpaceUsersCount;

  Organization({
    required this.id,
    required this.ownerId,
    required this.availableUsersCount,
    required this.licenseEndDate,
    required this.trialEndDate,
    required this.members,
    required this.uniqueSpaceUsersCount,
  });

  factory Organization.fromResponse(final OrganizationResponse data) {
    return Organization(
      id: data.id,
      ownerId: data.ownerId,
      availableUsersCount: data.availableUsersCount,
      licenseEndDate: data.licenseEndDate != null
          ? DateTime.parse(data.licenseEndDate!)
          : null,
      trialEndDate:
          data.trialEndDate != null ? DateTime.parse(data.trialEndDate!) : null,
      members: data.members
          .map((memberData) => OrganizationMember.fromResponse(memberData))
          .toList(),
      uniqueSpaceUsersCount: data.uniqueSpaceUsersCount,
    );
  }

  @override
  String toString() {
    return 'Organization{id: $id, ownerId: $ownerId, availableUsersCount: $availableUsersCount, licenseEndDate: $licenseEndDate, trialEndDate: $trialEndDate, members: $members, uniqueSpaceUsersCount: $uniqueSpaceUsersCount}';
  }
}

class OrganizationMember implements Identifiable {
  @override
  final int id;
  final String? avatarLink;
  final String email;
  final String name;
  final String? phoneNumber;
  final String? telegramLink;
  final String? githubLink;
  final DateTime? birthDate;
  final String? jobTitle;
  final bool isAdmin;

  OrganizationMember({
    required this.id,
    required this.avatarLink,
    required this.email,
    required this.name,
    required this.phoneNumber,
    required this.telegramLink,
    required this.githubLink,
    required this.birthDate,
    required this.jobTitle,
    required this.isAdmin,
  });

  factory OrganizationMember.fromResponse(
    final OrganizationMemberResponse data,
  ) {
    return OrganizationMember(
      id: data.id,
      email: data.email,
      name: data.name,
      phoneNumber: helpers.getNullStringIfEmpty(data.phoneNumber),
      telegramLink: helpers.getNullStringIfEmpty(data.telegramLink),
      githubLink: helpers.getNullStringIfEmpty(data.githubLink),
      jobTitle: helpers.getNullStringIfEmpty(data.jobTitle),
      avatarLink: helpers.makeAvatarUrl(data.avatar),
      birthDate:
          data.birthDate != null ? DateTime.parse(data.birthDate!) : null,
      isAdmin: data.isAdmin,
    );
  }

  factory OrganizationMember.fromUser(final User data) {
    return OrganizationMember(
      id: data.id,
      avatarLink: data.avatarLink,
      email: data.email,
      name: data.name,
      phoneNumber: data.phoneNumber,
      telegramLink: data.telegramLink,
      githubLink: data.githubLink,
      birthDate: data.birthDate,
      jobTitle: data.jobTitle,
      isAdmin: data.isAdmin,
    );
  }

  @override
  String toString() {
    return 'OrganizationMember{id: $id, avatarLink: $avatarLink, email: $email, name: $name, phoneNumber: $phoneNumber, telegramLink: $telegramLink, githubLink: $githubLink, birthDate: $birthDate jobTitle: $jobTitle}';
  }

  OrganizationMember copyWith({
    int? id,
    String? avatarLink,
    String? email,
    String? name,
    String? phoneNumber,
    String? telegramLink,
    String? githubLink,
    DateTime? birthDate,
    String? jobTitle,
    bool? isAdmin,
  }) {
    return OrganizationMember(
      id: id ?? this.id,
      avatarLink: avatarLink ?? this.avatarLink,
      email: email ?? this.email,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      telegramLink: telegramLink ?? this.telegramLink,
      githubLink: githubLink ?? this.githubLink,
      birthDate: birthDate ?? this.birthDate,
      jobTitle: jobTitle ?? this.jobTitle,
      isAdmin: isAdmin ?? this.isAdmin,
    );
  }
}
