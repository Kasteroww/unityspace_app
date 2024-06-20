import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:unityspace/resources/app_icons.dart';
import 'package:unityspace/screens/widgets/color_button_widget.dart';
import 'package:unityspace/store/groups_store.dart';
import 'package:unityspace/store/notifications_store.dart';
import 'package:unityspace/store/projects_store.dart';
import 'package:unityspace/store/reglaments_store.dart';
import 'package:unityspace/store/spaces_store.dart';
import 'package:unityspace/store/user_store.dart';
import 'package:unityspace/utils/localization_helper.dart';
import 'package:unityspace/utils/logger_plugin.dart';
import 'package:wstore/wstore.dart';

class LoadingScreenStore extends WStore {
  WStoreStatus status = WStoreStatus.init;
  String error = '';

  void loadData(String loadError) {
    if (status == WStoreStatus.loading) return;
    //
    setStore(() {
      status = WStoreStatus.loading;
      error = '';
    });
    // Методы, которые нужно ждать
    subscribe(
      subscriptionId: 1,
      future: Future.wait([
        UserStore().getUserData(),
        UserStore().getOrganizationData(),
        SpacesStore().getSpacesData(),
        NotificationsStore().getFirstUnreadNotification(),
        GroupsStore().getGroups(),
      ]),
      onData: (_) {
        setStore(() {
          status = WStoreStatus.loaded;
        });
      },
      onError: (e, stack) {
        logger.e('LoadingScreenStore loadData error=$e\nstack=$stack');
        setStore(() {
          status = WStoreStatus.error;
          error = loadError;
        });
        throw Exception(e);
      },
    );
    // Дополнительные данные, которые можно загрузить после
    subscribe(
      subscriptionId: 2,
      future: Future.wait([
        ProjectsStore().getAllProjects(),
        ReglamentsStore().getReglaments(),
      ]),
      onError: (e, stack) {
        logger.d(
          'LoadingScreenStore load additional Data error=$e\nstack=$stack',
        );
      },
    );
  }

  @override
  LoadingScreen get widget => super.widget as LoadingScreen;
}

class LoadingScreen extends WStoreWidget<LoadingScreenStore> {
  const LoadingScreen({
    super.key,
  });

  @override
  LoadingScreenStore createWStore() => LoadingScreenStore();

  @override
  Widget build(BuildContext context, LoadingScreenStore store) {
    final localization = LocalizationHelper.getLocalizations(context);
    store.loadData(localization.load_error);
    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F0),
      body: SafeArea(
        child: Center(
          child: WStoreStatusBuilder(
            store: store,
            watch: (store) => store.status,
            builderError: (context) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      store.error,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: const Color(0xFF111012).withOpacity(0.8),
                        fontSize: 20,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ColorButtonWidget(
                      width: double.infinity,
                      onPressed: () {
                        store.loadData(localization.load_error);
                      },
                      text: localization.replay,
                      loading: false,
                      colorBackground: const Color(0xFF111012),
                      colorText: Colors.white.withOpacity(0.9),
                    ),
                  ],
                ),
              );
            },
            builderLoading: (context) {
              return Lottie.asset(
                AppIcons.mainLoader,
                width: 200,
                height: 200,
              );
            },
            builder: (context, _) {
              return const SizedBox.shrink();
            },
            onStatusLoaded: (context) {
              Navigator.of(context).pushReplacementNamed('/home');
            },
          ),
        ),
      ),
    );
  }
}
