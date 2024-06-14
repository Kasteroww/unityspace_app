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
import 'package:unityspace/screens/widgets/skeleton/skeleton_card.dart';
import 'package:unityspace/screens/widgets/user_avatar_widget.dart';
import 'package:unityspace/store/groups_store.dart';
import 'package:unityspace/store/spaces_store.dart';
import 'package:unityspace/store/user_store.dart';
import 'package:unityspace/utils/localization_helper.dart';
import 'package:unityspace/utils/logger_plugin.dart';
import 'package:wstore/wstore.dart';

class AppNavigationDrawerStore extends WStore {
  WStoreStatus status = WStoreStatus.init;
  DrawerErrors error = DrawerErrors.none;
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
              name: 'Все пространства',
              spaces: noGroupSpaces,
              isOpen: true,
            );
          }
        },
        watch: () => [_allSpacesSortedByOrder],
        keyName: 'allSpacesGroup',
      );

  List<GroupWithSpaces> get _spacesGroups => computed(
        getValue: () {
          {
            if (groups.list.isNotEmpty) {
              final groupTree = groups.list
                  .map<GroupWithSpaces>((group) => _formGroup(group))
                  .toList();

              groupTree.sort((a, b) => a.groupOrder.compareTo(b.groupOrder));

              return groupTree;
            } else {
              return [allSpacesGroup];
            }
          }
        },
        watch: () => [_allSpacesSortedByOrder],
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
        watch: () => [_spacesGroups, isOwnerOrAdmin],
        keyName: 'spacesGroupsByUserPrivilidges',
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
            return 0;
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

  Future<void> loadData() async {
    if (status == WStoreStatus.loading) return;
    setStore(() {
      status = WStoreStatus.loading;
      error = DrawerErrors.none;
    });
    try {
      await GroupsStore().getGroups();
      setStore(() {
        status = WStoreStatus.loaded;
      });
    } catch (e, stack) {
      logger.e('on AppNavigationDrawer'
          'AppNavigationDrawer loadData error=$e\nstack=$stack');
      setStore(() {
        status = WStoreStatus.error;
        error = DrawerErrors.groupsLoadingError;
      });
    }
  }

  @override
  AppNavigationDrawer get widget => super.widget as AppNavigationDrawer;
}

class AppNavigationDrawer extends WStoreWidget<AppNavigationDrawerStore> {
  const AppNavigationDrawer({
    super.key,
  });

  @override
  AppNavigationDrawerStore createWStore() =>
      AppNavigationDrawerStore()..loadData();

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
              NavigatorMenuItem(
                iconAssetName: AppIcons.navigatorMain,
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
              NavigatorMenuItem(
                iconAssetName: AppIcons.navigatorNotifications,
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
                child: WStoreStatusBuilder<AppNavigationDrawerStore>(
                  watch: (store) => store.status,
                  builderLoading: (context) {
                    return const DrawerSpaceSkeletonCard();
                  },
                  builderError: (context) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 48),
                      child: Text(
                        switch (store.error) {
                          DrawerErrors.none => '',
                          DrawerErrors.groupsLoadingError =>
                            'error loading groups',
                          DrawerErrors.drawerError => 'drawer error',
                        },
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: const Color(0xFF111012).withOpacity(0.8),
                          fontSize: 20,
                          height: 1.2,
                        ),
                      ),
                    );
                  },
                  builder: (_, __) {
                    return const SizedBox.shrink();
                  },
                  builderLoaded: (context) {
                    return WStoreBuilder<AppNavigationDrawerStore>(
                      store: store,
                      watch: (store) => [
                        store.spacesGroupsByUserPrivileges,
                        store.isOrganizationOwner,
                      ],
                      builder: (context, store) {
                        return SingleChildScrollView(
                          child: Column(
                            children: [
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
                                      if (store.allSortedSpaces.isEmpty)
                                        NavigatorMenuEmptySpacesHint(
                                          isOrganizationOwner:
                                              store.isOrganizationOwner,
                                        ),
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
                                      Navigator.of(context)
                                          .pushReplacementNamed(
                                        '/space',
                                        arguments: spaceId,
                                      );
                                    }
                                    if (store.redirectTo == 'goto_pay') {
                                      store.setRedirectTo(null);
                                      Navigator.of(context).pop();
                                      Navigator.of(context)
                                          .pushReplacementNamed(
                                        '/account',
                                        arguments: {'page': 'tariff'},
                                      );
                                    }
                                    if (store.redirectTo == 'start_trial') {
                                      store.setRedirectTo(null);
                                      Navigator.of(context).pop();
                                      Navigator.of(context)
                                          .pushReplacementNamed(
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
                                        final spaceId =
                                            await showAddSpaceDialog(
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
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
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
            ],
          ),
        ),
      ),
    );
  }
}

class SpaceGroup extends StatelessWidget {
  const SpaceGroup({
    required this.group,
    required this.currentRoute,
    required this.currentArguments,
    super.key,
  });

  final GroupWithSpaces group;
  final String? currentRoute;
  final Object? currentArguments;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        NavigatorMenuListTitle(
          title: group.name,
        ),
        ...group.spaces.map(
          (space) => NavigatorMenuItem(
            iconAssetName: AppIcons.navigatorSpace,
            title: space.name,
            selected: currentRoute == '/space' && currentArguments == space.id,
            favorite: space.favorite,
            onTap: () {
              Navigator.of(context).pop();
              if (currentRoute != '/space' || currentArguments != space.id) {
                Navigator.of(context).pushReplacementNamed(
                  '/space',
                  arguments: {
                    'space': space,
                  },
                );
              }
            },
          ),
        ),
      ],
    );
  }
}

class NavigatorMenuEmptySpacesHint extends StatelessWidget {
  final bool isOrganizationOwner;

  const NavigatorMenuEmptySpacesHint({
    required this.isOrganizationOwner,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final localization = LocalizationHelper.getLocalizations(context);
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF111012),
        border: Border.all(
          color: const Color(0xFF0C5B35),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      child: Text(
        isOrganizationOwner ? localization.owner_text : localization.empt_text,
        style: TextStyle(
          color: Colors.white.withOpacity(0.95),
          height: 1.5,
          fontSize: 16,
        ),
      ),
    );
  }
}

class AddSpaceButtonWidget extends StatelessWidget {
  final VoidCallback onTap;

  const AddSpaceButtonWidget({
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final localization = LocalizationHelper.getLocalizations(context);
    return MaterialButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      minWidth: double.infinity,
      height: 40,
      elevation: 2,
      color: const Color(0xFF141314),
      onPressed: onTap,
      child: Row(
        children: [
          SvgPicture.asset(
            AppIcons.navigatorPlus,
            width: 32,
            height: 32,
            fit: BoxFit.scaleDown,
            theme: SvgTheme(
              currentColor: Colors.white.withOpacity(0.5),
            ),
          ),
          const SizedBox(width: 4),
          Text(
            localization.add_space,
            style: const TextStyle(
              color: Color(0xE6FFFFFF),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

class NavigatorMenuListTitle extends StatelessWidget {
  final String title;

  const NavigatorMenuListTitle({
    required this.title,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 40,
      child: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: Colors.white.withOpacity(0.5),
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
      ),
    );
  }
}

class NavigatorMenuItem extends StatelessWidget {
  final String title;
  final bool selected;
  final bool favorite;
  final String iconAssetName;
  final VoidCallback onTap;

  const NavigatorMenuItem({
    required this.title,
    required this.selected,
    required this.iconAssetName,
    required this.onTap,
    required this.favorite,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10),
      horizontalTitleGap: 8,
      selected: selected,
      selectedTileColor: const Color(0xFF0D362D),
      leading: SvgPicture.asset(
        iconAssetName,
        width: 32,
        height: 32,
        fit: BoxFit.scaleDown,
        theme: SvgTheme(
          currentColor: selected ? Colors.white : const Color(0xFF908F90),
        ),
      ),
      trailing: favorite
          ? SvgPicture.asset(
              AppIcons.navigatorFavorite,
              width: 12,
              height: 12,
              fit: BoxFit.scaleDown,
            )
          : null,
      title: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: selected ? Colors.white : const Color(0xE6FFFFFF),
          fontSize: 18,
        ),
      ),
    );
  }
}

class NavigatorMenuCurrentUser extends StatelessWidget {
  final String name;
  final bool selected;
  final bool license;
  final int currentUserId;
  final VoidCallback onTap;

  const NavigatorMenuCurrentUser({
    required this.name,
    required this.selected,
    required this.onTap,
    required this.license,
    required this.currentUserId,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10),
      horizontalTitleGap: 8,
      selected: selected,
      selectedTileColor: const Color(0xFF0D362D),
      leading: UserAvatarWidget(
        id: currentUserId,
        width: 32,
        height: 32,
        fontSize: 14,
      ),
      trailing: license
          ? SvgPicture.asset(
              AppIcons.navigatorLicense,
              width: 24,
              height: 24,
              fit: BoxFit.scaleDown,
            )
          : null,
      title: Text(
        name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: selected ? Colors.white : const Color(0xE6FFFFFF),
          fontSize: 18,
        ),
      ),
    );
  }
}

class DrawerSpaceSkeletonCard extends StatelessWidget {
  const DrawerSpaceSkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        height: 50,
        decoration: const BoxDecoration(
          color: ColorConstants.grey01,
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        child: const Padding(
          padding: EdgeInsets.all(8),
          child: Center(
            child: SkeletonBox(
              height: 10,
              color: ColorConstants.grey03,
            ),
          ),
        ),
      ),
    );
  }
}
