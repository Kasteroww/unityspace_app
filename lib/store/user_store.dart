import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:unityspace/models/achievement_models.dart';
import 'package:unityspace/models/user_models.dart';
import 'package:unityspace/service/user_service.dart' as api;
import 'package:unityspace/store/auth_store.dart';
import 'package:unityspace/utils/helpers.dart';
import 'package:wstore/wstore.dart';

class UserStore extends GStore {
  static UserStore? _instance;

  factory UserStore() => _instance ??= UserStore._();

  UserStore._();

  User? user;
  Organization? organization;
  List<AchievementResponse>? achievements;

  bool get hasLicense {
    final license = organization?.licenseEndDate;
    if (license == null) return false;
    return license.isAfter(DateTime.now());
  }

  bool get hasTrial {
    final trial = organization?.trialEndDate;
    if (trial == null) return false;
    return trial.isAfter(DateTime.now());
  }

  bool get trialNeverStarted {
    return organization?.trialEndDate == null;
  }

  bool get isOrganizationOwner {
    if (user == null || organization == null) return false;
    return organization?.ownerId == user?.id;
  }

  bool get isAdmin {
    if (user == null || organization == null) return false;
    return user!.isAdmin;
  }

  Map<int, OrganizationMember> get organizationMembersMap {
    return createMapById(organization?.members);
  }

  OrganizationMember? get organizationOwner {
    return organizationMembersMap[organization?.ownerId];
  }

  Future<void> getUserData() async {
    final userData = await api.getUserData();
    final user = User.fromResponse(userData);
    setStore(() {
      this.user = user;
    });
  }

  Future<void> getOrganizationData() async {
    final organizationData = await api.getOrganizationData();
    final organization = Organization.fromResponse(organizationData);
    setStore(() {
      this.organization = organization;
    });
  }

  Future<void> removeUserAvatar() async {
    final userData = await api.removeUserAvatar();
    final user = User.fromResponse(userData);
    _updateUserAtStore(user);
  }

  Future<void> setUserAvatar(final Uint8List avatarImage) async {
    final userData = await api.setUserAvatar(avatarImage);
    final user = User.fromResponse(userData);
    _updateUserAtStore(user);
  }

  Future<void> setUserName(final String userName) async {
    final userData = await api.setUserName(userName);
    final user = User.fromResponse(userData);
    _updateUserAtStore(user);
  }

  Future<String?> requestEmailVerification({
    required String email,
    required bool isChangeEmail,
  }) async {
    return api.requestEmailVerification(
      email: email,
      isChangeEmail: isChangeEmail,
    );
  }

  Future<void> confirmEmail({
    required String email,
    required String code,
    required int userGlobalId,
    required int userId,
  }) async {
    await api.confirmUserEmail(
      newEmail: email,
      code: code,
    );
  }

  void changeEmailLocally({required String newEmail}) {
    if (user != null) {
      setStore(() {
        user = user!.copyWith(email: newEmail);
      });
    }
  }

  void changeMemberEmailLocally({
    required int userId,
    required String newEmail,
  }) {
    if (organizationMembersMap.isEmpty) return;
    final member =
        organization?.members.firstWhereOrNull((m) => m.id == userId);

    if (member != null) {
      final updatedMember = member.copyWith(email: newEmail);
      setStore(() {
        organizationMembersMap[userId] = updatedMember;
      });
    }
  }

  Future<void> setUserPassword(
    final String oldPassword,
    final String newPassword,
  ) async {
    final tokens = await api.setUserPassword(oldPassword, newPassword);
    await AuthStore().setUserTokens(tokens.accessToken, tokens.refreshToken);
  }

  Future<void> setJobTitle(final String jobTitle) async {
    final userData = await api.setJobTitle(jobTitle);
    final user = User.fromResponse(userData);
    _updateUserAtStore(user);
  }

  Future<void> setPhone(final String phone) async {
    final userData = await api.setPhone(phone);
    final user = User.fromResponse(userData);
    _updateUserAtStore(user);
  }

  Future<void> setUserGitHubLink(final String githubLink) async {
    final userData = await api.setUserGitHubLink(githubLink);
    final user = User.fromResponse(userData);
    _updateUserAtStore(user);
  }

  Future<void> setUserTelegramLink(final String link) async {
    final userData = await api.setUserTelegramLink(link);
    final user = User.fromResponse(userData);
    _updateUserAtStore(user);
  }

  Future<void> setUserBirthday(final DateTime? birthday) async {
    String? birthdayString;
    if (birthday != null) {
      birthdayString = DateTime.utc(
        birthday.year,
        birthday.month,
        birthday.day,
      ).toIso8601String();
    }
    final userData = await api.setUserBirthday(birthdayString);
    final user = User.fromResponse(userData);
    _updateUserAtStore(user);
  }

  void _updateUserAtStore(final User user) {
    setStore(() {
      this.user = user;
      final organizationMembersCount = organization?.members.length ?? 0;
      for (int i = 0; i < organizationMembersCount; i++) {
        final member = organization!.members[i];
        if (member.id == user.id) {
          organization!.members[i] = OrganizationMember.fromUser(user);
          break;
        }
      }
    });
  }

  Future<void> getAchievements() async {
    final userAchievements = await api.getAchievements();

    setStore(() {
      achievements = userAchievements;
    });
  }

  Map<String, OrganizationMember> get organizationMembersByEmailMap {
    if (organization?.members == null || organization!.members.isEmpty) {
      return {};
    }
    final organizationMembers = organization?.members ?? [];
    return organizationMembers.fold<Map<String, OrganizationMember>>({},
        (acc, member) {
      acc[member.email] = member;
      return acc;
    });
  }

  @override
  void clear() {
    super.clear();
    setStore(() {
      user = null;
      organization = null;
    });
  }
}
