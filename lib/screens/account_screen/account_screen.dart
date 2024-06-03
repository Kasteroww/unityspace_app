import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:unityspace/resources/constants.dart';
import 'package:unityspace/screens/account_screen/pages/account_page/account_page.dart';
import 'package:unityspace/screens/account_screen/pages/achievements_page.dart';
import 'package:unityspace/screens/account_screen/pages/actions_page/actions_page.dart';
import 'package:unityspace/screens/account_screen/pages/members_page.dart';
import 'package:unityspace/screens/account_screen/pages/settings_page.dart';
import 'package:unityspace/screens/account_screen/pages/tariff_page.dart';
import 'package:unityspace/screens/app_navigation_drawer.dart';
import 'package:unityspace/screens/widgets/common/appbar.dart';
import 'package:unityspace/screens/widgets/common/paddings.dart';
import 'package:unityspace/screens/widgets/tabs_list/tab_button.dart';
import 'package:unityspace/screens/widgets/tabs_list/tabs_list_row.dart';
import 'package:unityspace/store/auth_store.dart';
import 'package:unityspace/store/user_store.dart';
import 'package:unityspace/utils/localization_helper.dart';
import 'package:unityspace/utils/logger_plugin.dart';
import 'package:wstore/wstore.dart';

class AccountScreenStore extends WStore {
  AccountScreenTab selectedTab = AccountScreenTab.account;
  WStoreStatus statusExiting = WStoreStatus.init;
  String exitingError = '';

  bool get isOrganizationOwner => computedFromStore(
        store: UserStore(),
        getValue: (store) => store.isOrganizationOwner,
        keyName: 'isOrganizationOwner',
      );

  List<AccountScreenTab> get currentUserTabs => computed(
        getValue: () {
          if (isOrganizationOwner) return AccountScreenTab.values;
          return AccountScreenTab.values
              .where((tab) => tab.adminOnly == false)
              .toList();
        },
        watch: () => [isOrganizationOwner],
        keyName: 'currentUserTabs',
      );

  void selectTab(final AccountScreenTab tab) {
    setStore(() {
      selectedTab = tab;
    });
  }

  void init(final String tab) {
    final tabName = tab.isEmpty ? AccountScreenTab.account.name : tab;
    selectTab(AccountScreenTab.values.byName(tabName));
  }

  void signOut(String logoutError) {
    if (statusExiting == WStoreStatus.loading) return;
    //
    setStore(() {
      statusExiting = WStoreStatus.loading;
      exitingError = '';
    });
    subscribe(
      future: AuthStore().signOut(),
      subscriptionId: 1,
      onData: (_) {
        setStore(() {
          statusExiting = WStoreStatus.loaded;
        });
      },
      onError: (error, stack) {
        logger.d('AccountScreenStore.signOut error: $error stack: $stack');
        setStore(() {
          statusExiting = WStoreStatus.error;
          exitingError = logoutError;
        });
      },
    );
  }

  @override
  AccountScreen get widget => super.widget as AccountScreen;
}

enum AccountScreenTab {
  account(title: 'Аккаунт', adminOnly: false),
  achievements(title: 'Достижения', adminOnly: false),
  actions(title: 'Мои действия', adminOnly: false),
  settings(title: 'Настройки', adminOnly: false),
  members(title: 'Участники организации', adminOnly: true),
  tariff(
    title: 'Оплата и тарифы',
    iconAsset: ConstantIcons.tabLicense,
    adminOnly: true,
  );

  const AccountScreenTab({
    required this.title,
    required this.adminOnly,
    this.iconAsset,
  });

  final String title;
  final String? iconAsset;
  final bool adminOnly;
}

class AccountScreen extends WStoreWidget<AccountScreenStore> {
  final String tab;
  final String action;

  const AccountScreen({
    required this.tab,
    required this.action,
    super.key,
  });

  @override
  AccountScreenStore createWStore() => AccountScreenStore()..init(tab);

  @override
  Widget build(BuildContext context, AccountScreenStore store) {
    final localization = LocalizationHelper.getLocalizations(context);
    return Scaffold(
      drawer: const AppNavigationDrawer(),
      appBar: CustomAppBar(
        titleText: localization.my_profile,
        actions: [
          WStoreStatusBuilder(
            store: store,
            watch: (store) => store.statusExiting,
            builder: (context, status) {
              final loading = status == WStoreStatus.loading;
              return SignOutIconButton(
                onPressed: () => store.signOut(localization.logout_error),
                loading: loading,
              );
            },
            onStatusError: (context) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(store.exitingError),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PaddingTop(28),
          WStoreBuilder(
            store: store,
            watch: (store) => [store.selectedTab, store.currentUserTabs],
            builder: (context, store) => TabsListRow(
              children: [
                ...store.currentUserTabs.map(
                  (tab) => TabButton(
                    iconAsset: tab.iconAsset,
                    title: tab.title,
                    onPressed: () {
                      store.selectTab(tab);
                    },
                    selected: tab == store.selectedTab,
                  ),
                ),
              ],
            ),
          ),
          const PaddingTop(12),
          Expanded(
            child: WStoreValueBuilder(
              store: store,
              watch: (store) => store.selectedTab,
              builder: (context, selectedTab) {
                return switch (selectedTab) {
                  AccountScreenTab.account => const AccountPage(),
                  AccountScreenTab.achievements => const AchievementsPage(),
                  AccountScreenTab.actions => const ActionsPage(),
                  AccountScreenTab.settings => const SettingsPage(),
                  AccountScreenTab.members => const MembersPage(),
                  AccountScreenTab.tariff => const TariffPage(),
                };
              },
            ),
          ),
        ],
      ),
    );
  }
}

class SignOutIconButton extends StatelessWidget {
  final bool loading;
  final VoidCallback onPressed;

  const SignOutIconButton({
    required this.onPressed,
    required this.loading,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final localization = LocalizationHelper.getLocalizations(context);
    final currentColor = IconTheme.of(context).color ?? const Color(0xFF111012);
    return IconButton(
      padding: EdgeInsets.all(loading ? 4 : 2),
      icon: loading
          ? SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: currentColor,
              ),
            )
          : SvgPicture.asset(
              ConstantIcons.signOut,
              width: 20,
              height: 20,
              theme: SvgTheme(currentColor: currentColor),
            ),
      tooltip: localization.logout_from_account,
      onPressed: loading ? null : onPressed,
    );
  }
}
