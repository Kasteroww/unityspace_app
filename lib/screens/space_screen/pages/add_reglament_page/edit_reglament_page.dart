import 'package:flutter/material.dart';
import 'package:wstore/wstore.dart';

class EditReglamentPageStore extends WStore {
  WStoreStatus statusCreateReglament = WStoreStatus.init;
  String createReglamentError = '';
  String reglamentName = '';
  int columnId = 0;

  void initValues({required String reglamentName, required int columnId}) {
    setStore(() {
      this.reglamentName = reglamentName;
      this.columnId = columnId;
    });
  }

  @override
  EditReglamentPage get widget => super.widget as EditReglamentPage;
}

class EditReglamentPage extends WStoreWidget<EditReglamentPageStore> {
  final int columnId;
  final String reglamentName;
  const EditReglamentPage({
    required this.reglamentName,
    required this.columnId,
    super.key,
  });

  @override
  EditReglamentPageStore createWStore() => EditReglamentPageStore()
    ..initValues(reglamentName: reglamentName, columnId: columnId);

  @override
  Widget build(BuildContext context, EditReglamentPageStore store) {
    return Scaffold(
      appBar: AppBar(title: Text(store.reglamentName)),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextFormField(
                initialValue: store.reglamentName,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
