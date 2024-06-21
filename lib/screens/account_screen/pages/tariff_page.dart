import 'package:flutter/material.dart';
import 'package:unityspace/screens/widgets/stubs/work_in_progress_stub.dart';
import 'package:unityspace/utils/localization_helper.dart';
import 'package:wstore/wstore.dart';

class TariffPageStore extends WStore {
  bool isWorkInProgress = true;

  @override
  TariffPage get widget => super.widget as TariffPage;
}

class TariffPage extends WStoreWidget<TariffPageStore> {
  const TariffPage({
    super.key,
  });

  @override
  TariffPageStore createWStore() => TariffPageStore();

  @override
  Widget build(BuildContext context, TariffPageStore store) {
    final localization = LocalizationHelper.getLocalizations(context);
    return store.isWorkInProgress
        ? const WorkInProgressStub()
        : Text(localization.payment_and_tariffs);
  }
}
