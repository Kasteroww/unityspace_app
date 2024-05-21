import 'package:flutter/material.dart';
import 'package:wstore/wstore.dart';

class RegulationsPageStore extends WStore {
  @override
  RegulationsPage get widget => super.widget as RegulationsPage;
}

class RegulationsPage extends WStoreWidget<RegulationsPageStore> {
  const RegulationsPage({
    super.key,
  });

  @override
  RegulationsPageStore createWStore() => RegulationsPageStore();

  @override
  Widget build(BuildContext context, RegulationsPageStore store) {
    return Container();
  }
}
