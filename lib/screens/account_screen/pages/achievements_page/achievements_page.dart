import 'package:flutter/material.dart';
import 'package:unityspace/models/achievement_models.dart';
import 'package:unityspace/resources/constants.dart';
import 'package:unityspace/resources/errors.dart';
import 'package:unityspace/screens/account_screen/pages/achievements_page/widgets/achievement_card.dart';
import 'package:unityspace/screens/widgets/paddings.dart';
import 'package:unityspace/store/user_store.dart';
import 'package:unityspace/utils/localization_helper.dart';
import 'package:unityspace/utils/logger_plugin.dart';
import 'package:wstore/wstore.dart';

class AchievementsPageStore extends WStore {
  WStoreStatus status = WStoreStatus.init;
  ActionsErrors error = ActionsErrors.none;

  List<AchievementResponse>? get achievements => computedFromStore(
        store: UserStore(),
        getValue: (store) => store.achievements,
        keyName: 'history',
      );

  Future<void> loadData() async {
    if (status == WStoreStatus.loading) return;
    setStore(() {
      status = WStoreStatus.loading;
      error = ActionsErrors.none;
    });
    try {
      await UserStore().getAchievements();

      setStore(() {
        status = WStoreStatus.loaded;
      });
    } catch (e, stack) {
      logger.d('on Achievements Page'
          'AchievementPage getAchievements error=$e\nstack=$stack');
      setStore(() {
        status = WStoreStatus.error;
        error = ActionsErrors.loadingDataError;
      });
    }
  }

  @override
  AchievementsPage get widget => super.widget as AchievementsPage;
}

class AchievementsPage extends WStoreWidget<AchievementsPageStore> {
  const AchievementsPage({
    super.key,
  });

  @override
  AchievementsPageStore createWStore() => AchievementsPageStore()..loadData();

  @override
  Widget build(BuildContext context, AchievementsPageStore store) {
    return PaddingHorizontal(
      20,
      child: WStoreStatusBuilder(
        store: store,
        watch: (store) => store.status,
        builder: (context, _) {
          return const SizedBox.shrink();
        },
        builderLoaded: (context) {
          return const AchievementsList();
        },
        builderLoading: (context) {
          return const SizedBox.shrink();
        },
        builderError: (context) {
          return const Text(ConstantStrings.error);
        },
      ),
    );
  }
}

class AchievementsList extends StatefulWidget {
  const AchievementsList({super.key});

  @override
  State<AchievementsList> createState() => _AchievementsListState();
}

class _AchievementsListState extends State<AchievementsList> {
  @override
  Widget build(BuildContext context) {
    final localization = LocalizationHelper.getLocalizations(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, right: 4, bottom: 10),
          child: Text('${localization.collected}: ${context.wstore<AchievementsPageStore>().achievements?.length}'),
        ),
        WStoreBuilder<AchievementsPageStore>(
          watch: (store) => [store.achievements],
          store: context.wstore<AchievementsPageStore>(),
          builder: (context, store) {
            return ListView.builder(
              itemCount: store.achievements?.length,
              primary: false,
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              itemBuilder: (BuildContext context, int index) => const AchievementCard(),
            );
          },
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: Material(
            borderRadius: const BorderRadius.all(Radius.circular(6)),
            color: const Color(0x0D111012),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              child: Column(
                children: [
                  Text(
                    localization.section_is_development,
                    style: const TextStyle(
                      fontSize: 17,
                      color: Color(0xFF111012),
                    ),
                  ),
                  Text(
                    localization.section_is_development_desc,
                    style: const TextStyle(
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
