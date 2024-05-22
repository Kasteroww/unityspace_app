import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:unityspace/models/spaces_models.dart';
import 'package:unityspace/models/user_models.dart';
import 'package:unityspace/screens/dialogs/add_space_limit_dialog.dart';
import 'package:unityspace/screens/dialogs/add_space_dialog.dart';
import 'package:unityspace/screens/widgets/user_avatar_widget.dart';
import 'package:unityspace/store/spaces_store.dart';
import 'package:unityspace/store/user_store.dart';
import 'package:unityspace/utils/constants.dart';
import 'package:wstore/wstore.dart';
import 'package:unityspace/utils/localization_helper.dart';

class AppNavigationDrawerStore extends WStore {
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

  List<Space>? get spaces => computedFromStore(
        store: SpacesStore(),
        getValue: (store) => store.spaces,
        keyName: 'spaces',
      );

  bool get isAddingSpaceExceededLimit => computed(
        getValue: () {
          if (hasLicense || hasTrial) return false;
          final spacesLength = spaces?.length ?? 0;
          return spacesLength >= 3;
        },
        watch: () => [spaces, hasLicense, hasTrial],
        keyName: 'isAddingSpaceExceededLimit',
      );

  List<Space> get allSortedSpaces => computed(
        getValue: () {
          final spaces = (this.spaces ?? []).toList();
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

  bool get trialNeverStarted => computedFromStore(
        store: UserStore(),
        getValue: (store) => store.trialNeverStarted,
        keyName: 'trialNeverStarted',
      );

  int get currentUserId => computed<int>(
        getValue: () => currentUser?.id ?? 0,
        watch: () => [currentUser],
        keyName: 'currentUserId',
      );

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
              NavigatorMenuItem(
                iconAssetName: ConstantIcons.navigatorMain,
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
                iconAssetName: ConstantIcons.navigatorNotifications,
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
              const SizedBox(height: 16),
              Expanded(
                child: WStoreBuilder(
                  store: store,
                  watch: (store) => [
                    store.allSortedSpaces,
                    store.isOrganizationOwner,
                  ],
                  builder: (context, store) {
                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          NavigatorMenuListTitle(
                              title: localization.all_spaces),
                          if (store.allSortedSpaces.isEmpty)
                            NavigatorMenuEmptySpacesHint(
                              isOrganizationOwner: store.isOrganizationOwner,
                            ),
                          ...store.allSortedSpaces.map(
                            (space) => NavigatorMenuItem(
                              iconAssetName: ConstantIcons.navigatorSpace,
                              title: space.name,
                              selected: currentRoute == '/space' &&
                                  currentArguments == space.id,
                              favorite: space.favorite,
                              onTap: () {
                                Navigator.of(context).pop();
                                if (currentRoute != '/space' ||
                                    currentArguments != space.id) {
                                  Navigator.of(context).pushReplacementNamed(
                                    '/space',
                                    arguments: {
                                      'spaceId': space.id,
                                      'listColumns': space.columns
                                    },
                                  );
                                }
                              },
                            ),
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
                                      showTrialButton: store.trialNeverStarted,
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

class NavigatorMenuEmptySpacesHint extends StatelessWidget {
  final bool isOrganizationOwner;

  const NavigatorMenuEmptySpacesHint({
    super.key,
    required this.isOrganizationOwner,
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
    super.key,
    required this.onTap,
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
            ConstantIcons.navigatorPlus,
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
    super.key,
    required this.title,
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
    super.key,
    required this.title,
    required this.selected,
    required this.iconAssetName,
    required this.onTap,
    required this.favorite,
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
              ConstantIcons.navigatorFavorite,
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
    super.key,
    required this.name,
    required this.selected,
    required this.onTap,
    required this.license,
    required this.currentUserId,
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
              ConstantIcons.navigatorLicense,
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
