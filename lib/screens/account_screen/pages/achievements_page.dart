import 'package:flutter/material.dart';
import 'package:unityspace/utils/localization_helper.dart';
import 'package:wstore/wstore.dart';

class AchievementsPageStore extends WStore {
  // TODO: add data here...

  @override
  AchievementsPage get widget => super.widget as AchievementsPage;
}

class AchievementsPage extends WStoreWidget<AchievementsPageStore> {
  const AchievementsPage({
    super.key,
  });

  @override
  AchievementsPageStore createWStore() => AchievementsPageStore();

  @override
  Widget build(BuildContext context, AchievementsPageStore store) {
    final localization = LocalizationHelper.getLocalizations(context);
    return ColoredBox(
      color: Colors.blue,
      child: Center(
        child: Text(localization.achievements),
      ),
    );
  }
}
