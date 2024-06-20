import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:unityspace/resources/l10n/app_localizations.dart';
import 'package:unityspace/resources/theme/theme.dart';
import 'package:unityspace/screens/account_screen/account_screen.dart';
import 'package:unityspace/screens/administration_screen/administration_screen.dart';
import 'package:unityspace/screens/confirm_screen/confirm_screen.dart';
import 'package:unityspace/screens/home_screen/home_screen.dart';
import 'package:unityspace/screens/loading_screen/loading_screen.dart';
import 'package:unityspace/screens/login_by_email_screen/login_by_email_screen.dart';
import 'package:unityspace/screens/login_screen/login_screen.dart';
import 'package:unityspace/screens/notifications_screen/notifications_screen.dart';
import 'package:unityspace/screens/register_screen/register_screen.dart';
import 'package:unityspace/screens/restore_password_screen/restore_password_screen.dart';
import 'package:unityspace/screens/space_screen/pages/project_content/project_content.dart';
import 'package:unityspace/screens/space_screen/space_screen.dart';
import 'package:unityspace/screens/widgets/app_dialog/error_dialogs.dart';
import 'package:unityspace/service/exceptions/http_exceptions.dart';
import 'package:unityspace/store/auth_store.dart';
import 'package:unityspace/utils/socket_plugin.dart';
import 'package:window_manager/window_manager.dart';
import 'package:wstore/wstore.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await AuthStore().loadUserTokens();
  await initializeDateFormatting(
    'ru_RU',
  );

  if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
    await windowManager.ensureInitialized();
    const WindowOptions windowOptions =
        WindowOptions(minimumSize: Size(600, 400));
    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    if (details.exception is UserBlocked403HttpException) {
      show403ErrorDialog(context: navigatorKey.currentContext!);
    }
  };

  runApp(
    MyApp(
      isAuthenticated: AuthStore().isAuthenticated,
    ),
  );
  if (AuthStore().isAuthenticated) {
    SocketPlugin().socket.connect();
  }
}

class MyAppStore extends WStore {
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
    required this.isAuthenticated,
    super.key,
  });

  @override
  MyAppStore createWStore() => MyAppStore();

  @override
  Widget build(BuildContext context, MyAppStore store) {
    return WStoreBoolListener(
      store: store,
      watch: (store) => store.isAuthenticated,
      onTrue: (context) {
        navigatorKey.currentState?.pushNamedAndRemoveUntil(
          '/loading',
          (route) => false,
        );
      },
      onFalse: (context) {
        navigatorKey.currentState?.pushNamedAndRemoveUntil(
          '/login',
          (route) => false,
        );
      },
      child: MaterialApp(
        navigatorKey: navigatorKey,
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
                space: (ModalRoute.of(context)!.settings.arguments!
                    as Map)['space'],
              ),
          '/project': (context) => ProjectContent(
                projectId: (ModalRoute.of(context)!.settings.arguments!
                    as Map)['projectId'],
              ),
          '/notifications': (context) => const NotificationsScreen(),
          '/administration': (context) => const AdministrationScreen(),
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
