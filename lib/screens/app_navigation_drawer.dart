import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:unityspace/models/groups_models.dart';
import 'package:unityspace/models/spaces_models.dart';
import 'package:unityspace/models/user_models.dart';
import 'package:unityspace/resources/app_icons.dart';
import 'package:unityspace/resources/errors.dart';
import 'package:unityspace/resources/theme/theme.dart';
import 'package:unityspace/screens/dialogs/add_space_dialog.dart';
import 'package:unityspace/screens/dialogs/add_space_limit_dialog.dart';
import 'package:unityspace/screens/drawer_widgets/add_space_button.dart';
import 'package:unityspace/screens/drawer_widgets/animated_notification_circle.dart';
import 'package:unityspace/screens/drawer_widgets/current_user.dart';
import 'package:unityspace/screens/drawer_widgets/empty_spaces_hint.dart';
import 'package:unityspace/screens/drawer_widgets/navigation_menu_item.dart';
import 'package:unityspace/screens/drawer_widgets/space_group.dart';
import 'package:unityspace/store/groups_store.dart';
import 'package:unityspace/store/notifications_store.dart';
import 'package:unityspace/store/spaces_store.dart';
import 'package:unityspace/store/user_store.dart';
import 'package:unityspace/utils/localization_helper.dart';
import 'package:wstore/wstore.dart';

class AppNavigationDrawerStore extends WStore {
  WStoreStatus status = WStoreStatus.init;
  DrawerErrors error = DrawerErrors.none;
  ToggleSpacesGroupIsOpenErrors toggleIsOpenError =
      ToggleSpacesGroupIsOpenErrors.none;
  bool spaceCreating = false;
  int? newSpaceId;
  String? redirectTo;

  void setSpaceId(final int? id) {
    setStore(() {
      newSpaceId = id;
    });
  }

  void setRedirectTo(final String? redirect) {
    setStore(() {
      redirectTo = redirect;
    });
  }

  User? get currentUser => computedFromStore(
        store: UserStore(),
        getValue: (store) => store.user,
        keyName: 'currentUser',
      );

  Spaces get spaces => computedFromStore(
        store: SpacesStore(),
        getValue: (store) => store.spaces,
        keyName: 'spaces',
      );

  bool get isAddingSpaceExceededLimit => computed(
        getValue: () {
          if (hasLicense || hasTrial) return false;
          return spaces.length >= 3;
        },
        watch: () => [spaces, hasLicense, hasTrial],
        keyName: 'isAddingSpaceExceededLimit',
      );

  List<Space> get allSortedSpaces => computed(
        getValue: () {
          final spaces = this.spaces.list.toList();
          spaces.sort((a, b) {
            if (a.favorite == b.favorite) {
              return (a.order - b.order).sign.toInt();
            }
            if (a.favorite && !b.favorite) {
              return -1;
            }
            return 1;
          });
          return spaces;
        },
        watch: () => [spaces],
        keyName: 'allSortedSpaces',
      );

  String get currentUserName => computed<String>(
        getValue: () {
          final name = currentUser?.name ?? '';
          if (name.isNotEmpty) return name;
          final email = currentUser?.email ?? '';
          if (email.isNotEmpty) return email;
          return '?';
        },
        watch: () => [currentUser],
        keyName: 'currentUserName',
      );

  bool get hasLicense => computedFromStream<bool>(
        stream: Stream.periodic(
          const Duration(seconds: 1),
          (_) => UserStore().hasLicense,
        ),
        initialData: UserStore().hasLicense,
        keyName: 'hasLicense',
      );

  bool get hasTrial => computedFromStream<bool>(
        stream: Stream.periodic(
          const Duration(seconds: 1),
          (_) => UserStore().hasTrial,
        ),
        initialData: UserStore().hasTrial,
        keyName: 'hasTrial',
      );

  bool get isOrganizationOwner => computedFromStore(
        store: UserStore(),
        getValue: (store) => store.isOrganizationOwner,
        keyName: 'isOrganizationOwner',
      );

  bool get isAdmin => computedFromStore(
        store: UserStore(),
        getValue: (store) => store.isAdmin,
        keyName: 'isAdmin',
      );

  bool get trialNeverStarted => computedFromStore(
        store: UserStore(),
        getValue: (store) => store.organizationTrialEndDate == null,
        keyName: 'trialNeverStarted',
      );

  int get currentUserId => computed<int>(
        getValue: () => currentUser?.id ?? 0,
        watch: () => [currentUser],
        keyName: 'currentUserId',
      );

  bool get isOwnerOrAdmin => computedFromStore(
        store: UserStore(),
        getValue: (store) => store.isOwnerOrAdmin,
        keyName: 'isOwnerOrAdmin',
      );

  Groups get groups => computedFromStore(
        store: GroupsStore(),
        getValue: (store) => store.groups,
        keyName: 'groups',
      );

  Notifications get notifications => computedFromStore(
        store: NotificationsStore(),
        getValue: (store) => store.notifications,
        keyName: 'notifications',
      );

  bool get haveUnreadNotifications => computed(
        getValue: () =>
            notifications.iterable
                .firstWhereOrNull((notify) => notify.unread)
                ?.unread ??
            false,
        keyName: 'haveUnreadNotifications',
        watch: () => [notifications],
      );

  /// создает группу, в которой находятся все неархивированные пространства
  GroupWithSpaces get allSpacesGroup => computed(
        getValue: () {
          {
            final noGroupSpaces = _allSpacesSortedByOrder.where((space) {
              if (space.isArchived) return false;
              return space.groupId == null || groups[space.groupId!] == null;
            }).toList();

            return GroupWithSpaces(
              groupId: null,
              groupOrder: -1,
              name: 'All Spaces',
              spaces: noGroupSpaces,
              isOpen: true,
            );
          }
        },
        watch: () => [_allSpacesSortedByOrder],
        keyName: 'allSpacesGroup',
      );

  GroupWithSpaces get favoriteSpacesGroup => computed(
        getValue: () {
          final favoriteSpaces = _allSpacesSortedByOrder
              .where((space) => !space.isArchived && space.favorite)
              .toList();
          return GroupWithSpaces(
            groupId: null,
            groupOrder: -2,
            name: 'Favorite',
            spaces: favoriteSpaces,
            isOpen: true,
          );
        },
        watch: () => _allSpacesSortedByOrder,
        keyName: 'favoriteSpacesGroup',
      );

  List<GroupWithSpaces> get _spacesGroups => computed(
        getValue: () {
          {
            if (groups.list.isNotEmpty) {
              final groupTree = groups.list
                  .map<GroupWithSpaces>((group) => _formGroup(group))
                  .toList();

              groupTree.sort((a, b) {
                final int orderComparison =
                    a.groupOrder.compareTo(b.groupOrder);
                if (orderComparison != 0) {
                  return orderComparison;
                } else {
                  return a.name.compareTo(b.name);
                }
              });

              return groupTree;
            } else {
              return [];
            }
          }
        },
        watch: () => [_allSpacesSortedByOrder, groups],
        keyName: 'spacesGroups',
      );

  List<GroupWithSpaces> get spacesGroupsByUserPrivileges => computed(
        getValue: () {
          if (isOwnerOrAdmin) {
            return _spacesGroups;
          } else {
            return _spacesGroups
                .where((value) => value.spaces.isNotEmpty)
                .toList();
          }
        },
        watch: () => [
          _spacesGroups,
          isOwnerOrAdmin,
          groups,
        ],
        keyName: 'spacesGroupsByUserPriviledges',
      );

  /// возвращает список всех пространств, отсортированный по полю
  List<Space> get _allSpacesSortedByOrder => computed(
        getValue: () {
          final spaces = this.spaces.list.toList();
          spaces.sort((a, b) {
            final compareByStagesOrder = a.order - b.order;
            if (compareByStagesOrder != 0) {
              return compareByStagesOrder > 0 ? 1 : -1;
            }
            return a.name.compareTo(b.name);
          });
          return spaces;
        },
        watch: () => [spaces],
        keyName: 'allSpacesSortedByOrder',
      );

  GroupWithSpaces _formGroup(Group group) {
    return GroupWithSpaces(
      groupId: group.id,
      spaces: _allSpacesSortedByOrder
          .where(
            (space) => !space.isArchived && space.groupId == group.id,
          )
          .toList(),
      groupOrder: group.order,
      name: group.name,
      isOpen: group.isOpen,
    );
  }

  Future<void> toggleIsOpen({
    required int id,
    required bool isOpen,
    required String name,
  }) async {
    await GroupsStore().updateGroupOpen(id: id, isOpen: !isOpen);
  }

  @override
  AppNavigationDrawer get widget => super.widget as AppNavigationDrawer;
}

class AppNavigationDrawer extends WStoreWidget<AppNavigationDrawerStore> {
  const AppNavigationDrawer({
    super.key,
  });

  @override
  AppNavigationDrawerStore createWStore() => AppNavigationDrawerStore();

  @override
  Widget build(BuildContext context, AppNavigationDrawerStore store) {
    final localization = LocalizationHelper.getLocalizations(context);
    final currentRoute = ModalRoute.of(context)?.settings.name;
    final currentArguments = ModalRoute.of(context)?.settings.arguments;
    return Drawer(
      shape: const RoundedRectangleBorder(),
      backgroundColor: const Color(0xFF212022),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              WStoreBuilder(
                store: store,
                watch: (store) => [
                  store.currentUserName,
                  store.currentUserId,
                  store.hasLicense,
                ],
                builder: (context, store) {
                  return NavigatorMenuCurrentUser(
                    name: store.currentUserName,
                    currentUserId: store.currentUserId,
                    selected: currentRoute == '/account',
                    license: store.hasLicense,
                    onTap: () {
                      Navigator.of(context).pop();
                      if (currentRoute != '/account') {
                        Navigator.of(context).pushReplacementNamed('/account');
                      }
                    },
                  );
                },
              ),
              const SizedBox(
                height: 20,
              ),
              NavigatorMenuItem(
                iconAssetName: AppIcons.drawerHome,
                title: localization.main,
                selected: currentRoute == '/home',
                favorite: false,
                onTap: () {
                  Navigator.of(context).pop();
                  if (currentRoute != '/home') {
                    Navigator.of(context).pushReplacementNamed('/home');
                  }
                },
              ),
              WStoreValueBuilder<AppNavigationDrawerStore, bool>(
                watch: (store) => store.haveUnreadNotifications,
                builder: (BuildContext context, value) {
                  return Stack(
                    children: [
                      NavigatorMenuItem(
                        iconAssetName: AppIcons.drawerNotifications,
                        title: localization.notifications,
                        selected: currentRoute == '/notifications',
                        favorite: false,
                        onTap: () {
                          Navigator.of(context).pop();
                          if (currentRoute != '/notifications') {
                            Navigator.of(context)
                                .pushReplacementNamed('/notifications');
                          }
                        },
                        isShowBadge: store.haveUnreadNotifications,
                        badge: const AnimatedNotificationBadge(),
                      ),
                    ],
                  );
                },
              ),
              NavigatorMenuItem(
                iconAssetName: AppIcons.drawerSearch,
                title: localization.search,
                selected: currentRoute == '/global_search',
                favorite: false,
                onTap: () {
                  Navigator.of(context).pop();
                  if (currentRoute != '/global_search') {
                    Navigator.of(context)
                        .pushReplacementNamed('/global_search');
                  }
                },
              ),
              if (store.isOrganizationOwner || store.isAdmin)
                NavigatorMenuItem(
                  iconAssetName: AppIcons.administration,
                  title: localization.administration,
                  selected: currentRoute == '/administration',
                  favorite: false,
                  onTap: () {
                    Navigator.of(context).pop();
                    if (currentRoute != '/administration') {
                      Navigator.of(context)
                          .pushReplacementNamed('/administration');
                    }
                  },
                ),
              const SizedBox(height: 16),
              Expanded(
                child: WStoreBuilder<AppNavigationDrawerStore>(
                  store: store,
                  watch: (store) => [
                    store.spacesGroupsByUserPrivileges,
                    store.isOrganizationOwner,
                  ],
                  builder: (context, store) {
                    {
                      return SingleChildScrollView(
                        child: Column(
                          children: [
                            if (store.favoriteSpacesGroup.spaces.isNotEmpty)
                              SpaceGroup(
                                group: store.favoriteSpacesGroup,
                                currentRoute: currentRoute,
                                currentArguments: currentArguments,
                              ),
                            SpaceGroup(
                              group: store.allSpacesGroup,
                              currentRoute: currentRoute,
                              currentArguments: currentArguments,
                            ),
                            if (store.allSortedSpaces.isEmpty)
                              NavigatorMenuEmptySpacesHint(
                                isOrganizationOwner: store.isOrganizationOwner,
                              ),
                            if (store.spacesGroupsByUserPrivileges.isNotEmpty)
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const ClampingScrollPhysics(),
                                itemCount:
                                    store.spacesGroupsByUserPrivileges.length,
                                itemBuilder: (context, index) {
                                  final groups =
                                      store.spacesGroupsByUserPrivileges;
                                  return Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SpaceGroup(
                                        group: groups[index],
                                        currentRoute: currentRoute,
                                        currentArguments: currentArguments,
                                      ),
                                    ],
                                  );
                                },
                              ),
                            if (store.isOrganizationOwner)
                              const SizedBox(height: 16),
                            if (store.isOrganizationOwner)
                              WStoreListener(
                                store: store,
                                watch: (store) => [
                                  store.newSpaceId,
                                  store.redirectTo,
                                ],
                                onChange: (context, store) {
                                  if (store.newSpaceId != null) {
                                    final spaceId = store.newSpaceId;
                                    store.setSpaceId(null);
                                    Navigator.of(context).pop();
                                    Navigator.of(context).pushReplacementNamed(
                                      '/space',
                                      arguments: spaceId,
                                    );
                                  }
                                  if (store.redirectTo == 'goto_pay') {
                                    store.setRedirectTo(null);
                                    Navigator.of(context).pop();
                                    Navigator.of(context).pushReplacementNamed(
                                      '/account',
                                      arguments: {'page': 'tariff'},
                                    );
                                  }
                                  if (store.redirectTo == 'start_trial') {
                                    store.setRedirectTo(null);
                                    Navigator.of(context).pop();
                                    Navigator.of(context).pushReplacementNamed(
                                      '/account',
                                      arguments: {
                                        'page': 'tariff',
                                        'action': 'trial',
                                      },
                                    );
                                  }
                                },
                                child: AddSpaceButtonWidget(
                                  onTap: () async {
                                    if (store.spaceCreating) return;
                                    store.spaceCreating = true;
                                    if (store.isAddingSpaceExceededLimit) {
                                      final redirect =
                                          await showAddSpaceLimitDialog(
                                        context,
                                        showTrialButton:
                                            store.trialNeverStarted,
                                      );
                                      store.setRedirectTo(redirect);
                                    } else {
                                      final spaceId = await showAddSpaceDialog(
                                        context,
                                      );
                                      store.setSpaceId(spaceId);
                                    }
                                    store.spaceCreating = false;
                                  },
                                ),
                              ),
                          ],
                        ),
                      );
                    }
                  },
                ),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () {},
                child: Container(
                  width: 335,
                  height: 44,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(12)),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        AppIcons.drawerQuestionMark,
                        width: 20,
                        height: 20,
                        fit: BoxFit.scaleDown,
                        colorFilter: const ColorFilter.mode(
                          ColorConstants.grey09,
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        localization.main_menu_help_button,
                        style: const TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          height: 18.75 / 16,
                          color: ColorConstants.grey09,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
