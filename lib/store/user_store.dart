import 'dart:typed_data';

import 'package:unityspace/models/achievement_models.dart';
import 'package:unityspace/models/user_models.dart';
import 'package:unityspace/service/user_service.dart' as api;
import 'package:unityspace/store/auth_store.dart';
import 'package:wstore/wstore.dart';

class OrganizationMembers with GStoreChangeObjectMixin {
  final Map<int, OrganizationMember> _membersMap = {};
  final Map<String, OrganizationMember> _membersByEmailMap = {};

  OrganizationMembers();

  void add(OrganizationMember member) {
    _setMember(member);
    incrementObjectChangeCount();
  }

  void addAll(Iterable<OrganizationMember> all) {
    if (all.isNotEmpty) {
      for (final member in all) {
        _setMember(member);
      }
      incrementObjectChangeCount();
    }
  }

  void remove(int memberId) {
    _removeMember(memberId);
    incrementObjectChangeCount();
  }

  void clear() {
    if (_membersMap.isNotEmpty) {
      _membersMap.clear();
      _membersByEmailMap.clear();
      incrementObjectChangeCount();
    }
  }

  void _setMember(OrganizationMember member) {
    _removeMember(member.id);
    _membersMap[member.id] = member;
    _membersByEmailMap[member.email] = member;
  }

  void _removeMember(int id) {
    final member = _membersMap.remove(id);
    if (member != null) {
      _membersByEmailMap.remove(member.email);
    }
  }

  OrganizationMember? operator [](int id) => _membersMap[id];

  OrganizationMember? getByEmail(String email) => _membersByEmailMap[email];

  Iterable<OrganizationMember> get list => _membersMap.values;

  int get length => _membersMap.length;
}

class UserStore extends GStore {
  static UserStore? _instance;

  factory UserStore() => _instance ??= UserStore._();

  UserStore._();

  User? user;
  int? organizationId;
  int? organizationOwnerId;
  int? organizationAvailableUsersCount;
  DateTime? organizationLicenseEndDate;
  DateTime? organizationTrialEndDate;
  int? organizationUniqueSpaceUsersCount;
  OrganizationMembers organizationMembers = OrganizationMembers();
  List<AchievementResponse>? achievements;

  bool get hasLicense {
    final license = organizationLicenseEndDate;
    if (license == null) return false;
    return license.isAfter(DateTime.now());
  }

  bool get hasTrial {
    final trial = organizationTrialEndDate;
    if (trial == null) return false;
    return trial.isAfter(DateTime.now());
  }

  bool get isOrganizationOwner => computed(
        watch: () => [user, organizationOwnerId],
        getValue: () {
          if (user == null || organizationOwnerId == null) return false;
          return organizationOwnerId == user?.id;
        },
        keyName: 'isOrganizationOwner',
      );

  bool get isAdmin => computed(
    watch: () => [user],
    getValue: () {
      if (user == null) return false;
      return user!.isAdmin;
    },
    keyName: 'isAdmin',
  );

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
      organizationId = organization.id;
      organizationOwnerId = organization.ownerId;
      organizationAvailableUsersCount = organization.availableUsersCount;
      organizationLicenseEndDate = organization.licenseEndDate;
      organizationTrialEndDate = organization.trialEndDate;
      organizationUniqueSpaceUsersCount = organization.uniqueSpaceUsersCount;
      organizationMembers.clear();
      organizationMembers.addAll(organization.members);
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
    final member = organizationMembers[userId];
    if (member != null) {
      final updatedMember = member.copyWith(email: newEmail);
      setStore(() {
        organizationMembers.add(updatedMember);
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
      organizationMembers.add(OrganizationMember.fromUser(user));
    });
  }

  Future<void> getAchievements() async {
    final userAchievements = await api.getAchievements();
    setStore(() {
      achievements = userAchievements;
    });
  }

  Future<void> setIsAdmin(int memberId, bool isAdmin) async {
    final response = await api.setIsAdmin(memberId, isAdmin);
    final changedUser = User.fromResponse(response);
    setIsAdminLocally(changedUser.id, changedUser.isAdmin);
  }

  void setIsAdminLocally(int memberId, bool isAdmin) {
    final member = organizationMembers[memberId];
    if (member == null || member.isAdmin == isAdmin) return;
    setStore(() {
      organizationMembers.add(member.copyWith(isAdmin: isAdmin));
    });
  }

  void setUniqueSpaceUsersCountLocally(int newValue) {
    setStore(() {
      organizationUniqueSpaceUsersCount = newValue;
    });
  }

  @override
  void clear() {
    super.clear();
    setStore(() {
      user = null;
      organizationId = null;
      organizationOwnerId = null;
      organizationAvailableUsersCount = null;
      organizationLicenseEndDate = null;
      organizationTrialEndDate = null;
      organizationUniqueSpaceUsersCount = null;
      organizationMembers.clear();
      achievements = null;
    });
  }
}
