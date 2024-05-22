import 'dart:io';

import 'package:flutter/material.dart';
import 'package:unityspace/src/theme/theme.dart';
import 'package:window_manager/window_manager.dart';
import 'package:wstore/wstore.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:unityspace/screens/account_screen/account_screen.dart';
import 'package:unityspace/screens/confirm_screen/confirm_screen.dart';
import 'package:unityspace/screens/home_screen/home_screen.dart';
import 'package:unityspace/screens/loading_screen/loading_screen.dart';
import 'package:unityspace/screens/login_by_email_screen/login_by_email_screen.dart';
import 'package:unityspace/screens/login_screen/login_screen.dart';
import 'package:unityspace/screens/notifications_screen/notifications_screen.dart';
import 'package:unityspace/screens/register_screen/register_screen.dart';
import 'package:unityspace/screens/restore_password_screen/restore_password_screen.dart';
import 'package:unityspace/screens/space_screen/space_screen.dart';
import 'package:unityspace/store/auth_store.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthStore().loadUserTokens();
  await initializeDateFormatting('ru_RU', null);

  if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
    await windowManager.ensureInitialized();
    WindowOptions windowOptions =
        const WindowOptions(minimumSize: Size(600, 400));
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  runApp(
    MyApp(
      isAuthenticated: AuthStore().isAuthenticated,
    ),
  );
}

class MyAppStore extends WStore {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  bool get isAuthenticated => computedFromStore(
        store: AuthStore(),
        getValue: (store) => store.isAuthenticated,
        keyName: 'isAuthenticated',
      );

  @override
  MyApp get widget => super.widget as MyApp;
}

class MyApp extends WStoreWidget<MyAppStore> {
  final bool isAuthenticated;

  const MyApp({
    super.key,
    required this.isAuthenticated,
  });

  @override
  MyAppStore createWStore() => MyAppStore();

  @override
  Widget build(BuildContext context, MyAppStore store) {
    return WStoreBoolListener(
      store: store,
      watch: (store) => store.isAuthenticated,
      onTrue: (context) {
        store.navigatorKey.currentState?.pushNamedAndRemoveUntil(
          '/loading',
          (route) => false,
        );
      },
      onFalse: (context) {
        store.navigatorKey.currentState?.pushNamedAndRemoveUntil(
          '/login',
          (route) => false,
        );
      },
      child: MaterialApp(
        navigatorKey: store.navigatorKey,
        title: 'UnitySpace',
        locale: const Locale('ru'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: themeData,
        themeMode: ThemeMode.light,
        initialRoute: isAuthenticated ? '/loading' : '/login',
        routes: {
          '/login': (context) => const LoginScreen(),
          '/email': (context) => const LoginByEmailScreen(),
          '/home': (context) => const HomeScreen(),
          '/loading': (context) => const LoadingScreen(),
          '/restore': (context) => const RestorePasswordScreen(),
          '/register': (context) => const RegisterScreen(),
          '/confirm': (context) => ConfirmScreen(
                email:
                    ModalRoute.of(context)?.settings.arguments as String? ?? '',
              ),
          '/space': (context) => SpaceScreen(
                spaceId:
                    ModalRoute.of(context)?.settings.arguments as int? ?? 0,
              ),
          '/notifications': (context) => const NotificationsScreen(),
          '/account': (context) {
            final arguments = ModalRoute.of(context)?.settings.arguments
                as Map<String, String>?;
            return AccountScreen(
              tab: arguments?['page'] ?? '',
              action: arguments?['action'] ?? '',
            );
          },
        },
      ),
    );
  }
}
