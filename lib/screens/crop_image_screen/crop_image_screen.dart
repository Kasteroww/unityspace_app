import 'dart:io';
import 'dart:typed_data';

import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';
import 'package:unityspace/screens/widgets/app_dialog/app_dialog_primary_button.dart';
import 'package:unityspace/utils/errors.dart';
import 'package:unityspace/utils/logger_plugin.dart';
import 'package:wstore/wstore.dart';
import 'package:unityspace/utils/localization_helper.dart';

class CropImageScreenStore extends WStore {
  final controller = CropController();

  WStoreStatus statusLoadData = WStoreStatus.init;
  bool isProcessing = false;
  Uint8List? imageData;

  String error = '';

  bool get hasImage => imageData != null && imageData!.isNotEmpty;

  void loadImageData(String loadImageError) {
    if (statusLoadData != WStoreStatus.init) return;
    //
    setStore(() {
      statusLoadData = WStoreStatus.loading;
      error = '';
    });
    listenFuture(
      Future(() async {
        final file = File(widget.imageFilePath);
        final imageData = await file.readAsBytes();
        if (imageData.isEmpty) throw ImageErrors.imageIsEmpty;
        return imageData;
      }),
      id: 1,
      onData: (imageData) {
        setStore(() {
          this.imageData = imageData;
          statusLoadData = WStoreStatus.loaded;
        });
      },
      onError: (e, stack) {
        logger.d('CropImageScreenStore loadImageData error=$e\nstack=$stack');
        setStore(() {
          statusLoadData = WStoreStatus.error;
          error = loadImageError;
        });
      },
    );
  }

  void crop() {
    setStore(() {
      isProcessing = true;
    });
    controller.crop();
  }

  @override
  CropImageScreen get widget => super.widget as CropImageScreen;
}

class CropImageScreen extends WStoreWidget<CropImageScreenStore> {
  final String imageFilePath;

  const CropImageScreen({
    super.key,
    required this.imageFilePath,
  });

  @override
  CropImageScreenStore createWStore() => CropImageScreenStore();

  @override
  Widget build(BuildContext context, CropImageScreenStore store) {
    final localization = LocalizationHelper.getLocalizations(context);
    store.loadImageData(localization.load_image_error);
    return Scaffold(
      appBar: AppBar(
        title: Text(localization.change_avatar),
      ),
      body: SafeArea(
        child: WStoreStatusBuilder(
          store: store,
          watch: (store) => store.statusLoadData,
          builderLoading: (context) {
            return const Center(child: CircularProgressIndicator());
          },
          builderError: (context) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48),
                child: Text(
                  store.error,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: const Color(0xFF111012).withOpacity(0.8),
                    fontSize: 20,
                    height: 1.2,
                  ),
                ),
              ),
            );
          },
          builder: (context, _) {
            return const SizedBox.shrink();
          },
          builderLoaded: (context) {
            return WStoreValueBuilder(
              store: store,
              watch: (store) => store.isProcessing,
              builder: (context, isProcessing) {
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: AspectRatio(
                        aspectRatio: 1.0,
                        child: Crop(
                          controller: store.controller,
                          image: store.imageData!,
                          initialSize: 0.5,
                          aspectRatio: 1,
                          progressIndicator: const Center(
                            child: CircularProgressIndicator(),
                          ),
                          onCropped: (cropped) {
                            Navigator.of(context).pop(cropped);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: AppDialogPrimaryButton(
                        onPressed: () {
                          store.crop();
                        },
                        text: localization.change,
                        loading: isProcessing,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Spacer(),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
