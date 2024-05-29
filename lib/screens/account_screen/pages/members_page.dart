import 'package:flutter/material.dart';
import 'package:unityspace/utils/localization_helper.dart';
import 'package:wstore/wstore.dart';

class MembersPageStore extends WStore {
  // TODO: add data here...

  @override
  MembersPage get widget => super.widget as MembersPage;
}

class MembersPage extends WStoreWidget<MembersPageStore> {
  const MembersPage({
    super.key,
  });

  @override
  MembersPageStore createWStore() => MembersPageStore();

  @override
  Widget build(BuildContext context, MembersPageStore store) {
    final localization = LocalizationHelper.getLocalizations(context);
    return ColoredBox(
      color: Colors.blue,
      child: Center(
        child: Text(localization.members_of_the_organization),
      ),
    );
  }
}
