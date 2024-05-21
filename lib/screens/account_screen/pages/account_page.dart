import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:unityspace/models/user_models.dart';
import 'package:unityspace/screens/crop_image_screen/crop_image_screen.dart';
import 'package:unityspace/screens/dialogs/user_change_birthday_dialog.dart';
import 'package:unityspace/screens/dialogs/user_change_githublink_dialog.dart';
import 'package:unityspace/screens/dialogs/user_change_job_dialog.dart';
import 'package:unityspace/screens/dialogs/user_change_name_dialog.dart';
import 'package:unityspace/screens/dialogs/user_change_password_dialog.dart';
import 'package:unityspace/screens/dialogs/user_change_phone_dialog.dart';
import 'package:unityspace/screens/dialogs/user_change_tg_link_dialog.dart';
import 'package:unityspace/screens/widgets/user_avatar_widget.dart';
import 'package:unityspace/store/user_store.dart';
import 'package:unityspace/utils/constants.dart';
import 'package:unityspace/utils/errors.dart';
import 'package:unityspace/utils/logger_plugin.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wstore/wstore.dart';
import 'package:unityspace/utils/localization_helper.dart';

class AccountPageStore extends WStore {
  String imageFilePath = '';
  String message = '';
  WStoreStatus statusAvatar = WStoreStatus.init;

  User? get currentUser => computedFromStore(
        store: UserStore(),
        getValue: (store) => store.user,
        keyName: 'currentUser',
      );

  int get currentUserId => computed(
        getValue: () => currentUser?.id ?? 0,
        watch: () => [currentUser],
        keyName: 'currentUserId',
      );

  bool get currentUserHasAvatar => computed(
        getValue: () => currentUser?.avatarLink != null,
        watch: () => [currentUser],
        keyName: 'currentUserHasAvatar',
      );

  String get currentUserName => computed(
        getValue: () => currentUser?.name ?? '',
        watch: () => [currentUser],
        keyName: 'currentUserName',
      );

  String get currentUserBirthday => computed(
        getValue: () {
          final birthDate = currentUser?.birthDate;
          if (birthDate == null) return '';
          return DateFormat('dd MMMM yyyy', 'ru_RU').format(birthDate);
        },
        watch: () => [currentUser],
        keyName: 'currentUserBirthday',
      );

  String get currentUserEmail => computed(
        getValue: () => currentUser?.email ?? '',
        watch: () => [currentUser],
        keyName: 'currentUserEmail',
      );

  String get currentUserPhone => computed(
        getValue: () => currentUser?.phoneNumber ?? '',
        watch: () => [currentUser],
        keyName: 'currentUserPhone',
      );

  String get currentUserJobTitle => computed(
        getValue: () => currentUser?.jobTitle ?? '',
        watch: () => [currentUser],
        keyName: 'currentUserJobTitle',
      );

  String get currentUserTelegram => computed(
        getValue: () => currentUser?.telegramLink ?? '',
        watch: () => [currentUser],
        keyName: 'currentUserTelegram',
      );

  String get currentUserGithub => computed(
        getValue: () => currentUser?.githubLink ?? '',
        watch: () => [currentUser],
        keyName: 'currentUserGithub',
      );

  void clearAvatar(String deleteAvatarError) {
    if (statusAvatar == WStoreStatus.loading) return;
    //
    setStore(() {
      statusAvatar = WStoreStatus.loading;
    });
    //
    listenFuture(
      UserStore().removeUserAvatar(),
      id: 3,
      onData: (_) {
        setStore(() {
          statusAvatar = WStoreStatus.loaded;
        });
      },
      onError: (error, stack) {
        logger.e('removeUserAvatar error', error: error, stackTrace: stack);
        setStore(() {
          statusAvatar = WStoreStatus.error;
          message = deleteAvatarError;
        });
      },
    );
  }

  void setAvatar(Uint8List avatarImage, String loadAvatarError) {
    if (statusAvatar == WStoreStatus.loading) return;
    //
    setStore(() {
      statusAvatar = WStoreStatus.loading;
    });
    //
    listenFuture(
      UserStore().setUserAvatar(avatarImage),
      id: 5,
      onData: (_) {
        setStore(() {
          statusAvatar = WStoreStatus.loaded;
        });
      },
      onError: (error, stack) {
        logger.e('setUserAvatar error', error: error, stackTrace: stack);
        setStore(() {
          statusAvatar = WStoreStatus.error;
          message = loadAvatarError;
        });
      },
    );
  }

  void copy(
      final String text, final String successMessage, final String copyError) {
    listenFuture(
      _copyToClipboard(text),
      id: 1,
      onData: (_) {
        setStore(() {
          message = successMessage;
        });
      },
      onError: (error, stack) {
        logger.e('copyToClipboard error', error: error, stackTrace: stack);
        setStore(() {
          message = copyError;
        });
      },
    );
  }

  void open(final String link, final String openLinkError) {
    listenFuture(
      _gotoLink(link),
      id: 2,
      onData: (_) {},
      onError: (error, stack) {
        logger.e('gotoLink error', error: error, stackTrace: stack);
        setStore(() {
          message = openLinkError;
        });
      },
    );
  }

  Future<void> _copyToClipboard(final String text) async {
    if (text.isEmpty) throw TextErrors.textIsEmpty;
    final data = ClipboardData(text: text);
    await Clipboard.setData(data);
  }

  Future<void> _gotoLink(final String link) async {
    if (link.isEmpty) throw LinkErrors.linkIsEmpty;
    final url = Uri.parse(link);
    bool result = await launchUrl(url, mode: LaunchMode.externalApplication);
    if (!result) throw '${LinkErrors.couldNotLaunch} $link';
  }

  void pickAvatar(String pickAvatarError) async {
    setStore(() {
      statusAvatar = WStoreStatus.loading;
    });
    listenFuture(
      _pickImage(),
      id: 4,
      onData: (filePath) {
        setStore(() {
          if (filePath != null) {
            imageFilePath = filePath;
          }
          statusAvatar = WStoreStatus.loaded;
        });
      },
      onError: (error, stack) {
        logger.e('pickAvatar error', error: error, stackTrace: stack);
        setStore(() {
          statusAvatar = WStoreStatus.error;
          message = pickAvatarError;
        });
      },
    );
  }

  void pickPhoto(String pickPhotoError) async {
    setStore(() {
      statusAvatar = WStoreStatus.loading;
    });
    listenFuture(
      _pickPhoto(),
      id: 5,
      onData: (filePath) {
        setStore(() {
          if (filePath != null) {
            imageFilePath = filePath;
          }
          statusAvatar = WStoreStatus.loaded;
        });
      },
      onError: (error, stack) {
        logger.e('pickPhoto error', error: error, stackTrace: stack);
        setStore(() {
          statusAvatar = WStoreStatus.error;
          message = pickPhotoError;
        });
      },
    );
  }

  Future<String?> _pickImage() async {
    final xFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    return xFile?.path;
  }

  Future<String?> _pickPhoto() async {
    final xFile = await ImagePicker().pickImage(source: ImageSource.camera);
    return xFile?.path;
  }

  @override
  AccountPage get widget => super.widget as AccountPage;
}

class AccountPage extends WStoreWidget<AccountPageStore> {
  const AccountPage({
    super.key,
  });

  @override
  AccountPageStore createWStore() => AccountPageStore();

  @override
  Widget build(BuildContext context, AccountPageStore store) {
    final localization = LocalizationHelper.getLocalizations(context);
    return WStoreStringListener(
      store: store,
      watch: (store) => store.message,
      reset: (store) => store.message = '',
      onNotEmpty: (context, message) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
          ),
        );
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
            ),
            constraints: const BoxConstraints(maxWidth: 660),
            child: AccountContentWidget(
              avatar: WStoreStringListener(
                store: store,
                watch: (store) => store.imageFilePath,
                reset: (store) => store.imageFilePath = '',
                onNotEmpty: (context, imageFilePath) async {
                  Uint8List? avatarImage =
                      await Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => CropImageScreen(
                                imageFilePath: imageFilePath,
                              )));
                  if (avatarImage != null) {
                    store.setAvatar(
                        avatarImage, localization.load_avatar_error);
                  }
                },
                child: WStoreValueBuilder(
                  store: store,
                  watch: (store) => store.currentUserHasAvatar,
                  builder: (context, hasAvatar) => AccountAvatarWidget(
                    hasAvatar: hasAvatar,
                    onChangeAvatar: () {
                      store.pickAvatar(localization.change_avatar_error);
                    },
                    onChangePhoto: () {
                      store.pickPhoto(localization.pick_photo_error);
                    },
                    onClearAvatar: () {
                      store.clearAvatar(localization.delete_avatar_error);
                    },
                  ),
                ),
              ),
              children: [
                WStoreValueBuilder(
                  store: store,
                  watch: (store) => store.currentUserName,
                  builder: (context, name) => AccountItemWidget(
                    text: localization.name,
                    value: name.isNotEmpty ? name : localization.not_specified,
                    iconAssetName: ConstantIcons.accountName,
                    onTapChange: () {
                      showUserChangeNameDialog(context, name);
                    },
                    onTapValue: name.isNotEmpty
                        ? () => store.copy(
                              name,
                              localization.name_copied_to_clipboard,
                              localization.copy_error,
                            )
                        : null,
                  ),
                ),
                WStoreValueBuilder(
                  store: store,
                  watch: (store) => store.currentUserBirthday,
                  builder: (context, birthday) => AccountItemWidget(
                    text: localization.date_of_birth,
                    value: birthday.isNotEmpty
                        ? birthday
                        : localization.not_specified,
                    iconAssetName: ConstantIcons.accountBirthday,
                    onTapChange: () {
                      showUserChangeBirthdayDialog(
                        context,
                        store.currentUser?.birthDate,
                      );
                    },
                    onTapValue: birthday.isNotEmpty
                        ? () => store.copy(
                              birthday,
                              localization.date_of_birth_copied_to_clipboard,
                              localization.copy_error,
                            )
                        : null,
                  ),
                ),
                WStoreValueBuilder(
                  store: store,
                  watch: (store) => store.currentUserEmail,
                  builder: (context, email) => AccountItemWidget(
                    text: localization.email,
                    value:
                        email.isNotEmpty ? email : localization.not_specified,
                    iconAssetName: ConstantIcons.accountEmail,
                    onTapChange: () {},
                    onTapValue: email.isNotEmpty
                        ? () => store.copy(
                              email,
                              localization.email_copied_to_clipboard,
                              localization.copy_error,
                            )
                        : null,
                  ),
                ),
                WStoreValueBuilder(
                  store: store,
                  watch: (store) => store.currentUserPhone,
                  builder: (context, phone) => AccountItemWidget(
                    text: localization.phone,
                    value:
                        phone.isNotEmpty ? phone : localization.not_specified,
                    iconAssetName: ConstantIcons.accountPhone,
                    onTapChange: () {
                      showUserChangePhoneDialog(context, phone);
                    },
                    onTapValue: phone.isNotEmpty
                        ? () => store.copy(
                              phone,
                              localization.phone_copied_to_clipboard,
                              localization.copy_error,
                            )
                        : null,
                  ),
                ),
                WStoreValueBuilder(
                  store: store,
                  watch: (store) => store.currentUserJobTitle,
                  builder: (context, jobTitle) => AccountItemWidget(
                    text: localization.work_position,
                    value: jobTitle.isNotEmpty
                        ? jobTitle
                        : localization.not_specified,
                    iconAssetName: ConstantIcons.accountJob,
                    onTapChange: () {
                      showUserChangeJobDialog(context, jobTitle);
                    },
                    onTapValue: jobTitle.isNotEmpty
                        ? () => store.copy(
                              jobTitle,
                              localization.work_position_copied_to_clipboard,
                              localization.copy_error,
                            )
                        : null,
                  ),
                ),
                WStoreValueBuilder(
                  store: store,
                  watch: (store) => store.currentUserTelegram,
                  builder: (context, telegram) => AccountItemWidget(
                    text: localization.profile_in_telegram,
                    value: telegram.isNotEmpty
                        ? telegram
                        : localization.not_specified,
                    iconAssetName: ConstantIcons.accountTelegram,
                    onTapChange: () {
                      showUserChangeTgLinkDialog(context, telegram);
                    },
                    onTapValue: telegram.isNotEmpty
                        ? () =>
                            store.open(telegram, localization.open_link_error)
                        : null,
                    onLongTapValue: telegram.isNotEmpty
                        ? () => store.copy(
                              telegram,
                              localization.link_copied_to_clipboard,
                              localization.copy_error,
                            )
                        : null,
                  ),
                ),
                WStoreValueBuilder(
                  store: store,
                  watch: (store) => store.currentUserGithub,
                  builder: (context, github) => AccountItemWidget(
                    text: localization.profile_in_github,
                    value:
                        github.isNotEmpty ? github : localization.not_specified,
                    iconAssetName: ConstantIcons.accountGithub,
                    onTapChange: () {
                      showUserChangeGitHubLinkDialog(context, github);
                    },
                    onTapValue: github.isNotEmpty
                        ? () => store.open(github, localization.open_link_error)
                        : null,
                    onLongTapValue: github.isNotEmpty
                        ? () => store.copy(
                              github,
                              localization.link_copied_to_clipboard,
                              localization.copy_error,
                            )
                        : null,
                  ),
                ),
                AccountItemWidget(
                  text: localization.password,
                  value: ConstantStrings.hiddenPassword,
                  iconAssetName: ConstantIcons.accountPassword,
                  onTapChange: () {
                    showUserChangePasswordDialog(context);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AccountItemWidget extends StatelessWidget {
  final String text;
  final String value;
  final String iconAssetName;
  final VoidCallback onTapChange;
  final VoidCallback? onTapValue;
  final VoidCallback? onLongTapValue;

  const AccountItemWidget({
    super.key,
    required this.text,
    required this.value,
    required this.iconAssetName,
    required this.onTapChange,
    this.onTapValue,
    this.onLongTapValue,
  });

  @override
  Widget build(BuildContext context) {
    final localization = LocalizationHelper.getLocalizations(context);
    const titleColor = Color(0x99111012);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const SizedBox(width: 12),
            SvgPicture.asset(
              iconAssetName,
              width: 18,
              height: 18,
              theme: const SvgTheme(currentColor: titleColor),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  color: titleColor,
                  fontSize: 16,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            TextButton(
              style: ButtonStyle(
                minimumSize: WidgetStateProperty.all(const Size(40, 40)),
              ),
              onPressed: onTapChange,
              child: Text(
                localization.change,
              ),
            ),
          ],
        ),
        TextButton(
          style: ButtonStyle(
            minimumSize: WidgetStateProperty.all(
              const Size(double.infinity, 40),
            ),
            padding: WidgetStateProperty.all<EdgeInsets>(
              const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            ),
            alignment: Alignment.centerLeft,
          ),
          onPressed: onTapValue,
          onLongPress: onLongTapValue,
          child: FittedBox(
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xCC111012),
                fontSize: 20,
                fontWeight: FontWeight.w500,
                height: 32 / 20,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }
}

class AccountAvatarWidget extends StatelessWidget {
  final VoidCallback onChangeAvatar;
  final VoidCallback onChangePhoto;
  final VoidCallback onClearAvatar;
  final bool hasAvatar;

  const AccountAvatarWidget({
    super.key,
    required this.hasAvatar,
    required this.onChangeAvatar,
    required this.onChangePhoto,
    required this.onClearAvatar,
  });

  @override
  Widget build(BuildContext context) {
    final localization = LocalizationHelper.getLocalizations(context);
    return Column(
      children: [
        WStoreValueBuilder<AccountPageStore, int>(
          watch: (store) => store.currentUserId,
          builder: (context, currentUserId) => UserAvatarWidget(
            id: currentUserId,
            width: 120,
            height: 120,
            fontSize: 48,
            radius: 16,
          ),
        ),
        const SizedBox(height: 4),
        MenuAnchor(
          menuChildren: [
            MenuItemButton(
              onPressed: onChangePhoto,
              child: Text(localization.take_a_new_photo),
            ),
            MenuItemButton(
              onPressed: onChangeAvatar,
              child: Text(localization.select_photo_from_the_gallery),
            ),
            if (hasAvatar)
              MenuItemButton(
                onPressed: onClearAvatar,
                child: Text(localization.delete_photo),
              ),
          ],
          builder: (context, controller, _) {
            return WStoreStatusBuilder<AccountPageStore>(
              watch: (store) => store.statusAvatar,
              builder: (context, status) {
                final loading = status == WStoreStatus.loading;
                return TextButton(
                  style: ButtonStyle(
                    minimumSize: WidgetStateProperty.all(const Size(120, 40)),
                  ),
                  onPressed: loading
                      ? null
                      : () {
                          if (controller.isOpen) {
                            controller.close();
                          } else {
                            controller.open();
                          }
                        },
                  child: loading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : Text(localization.change),
                );
              },
            );
          },
        ),
      ],
    );
  }
}

class AccountContentWidget extends StatelessWidget {
  final Widget avatar;
  final List<Widget> children;

  const AccountContentWidget({
    super.key,
    required this.avatar,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 496) {
          return Column(
            children: [
              avatar,
              const SizedBox(height: 16),
              const Divider(
                height: 1,
                thickness: 1,
                color: Color(0xFFE5E7EB),
                indent: 12,
                endIndent: 12,
              ),
              ...children.expand(
                (child) => [
                  const SizedBox(height: 16),
                  child,
                ],
              ),
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(width: 12),
            avatar,
            const SizedBox(width: 32),
            Expanded(
              child: Container(
                padding: const EdgeInsets.only(left: 16),
                decoration: const BoxDecoration(
                  border: Border(
                    left: BorderSide(
                      color: Color(0xFFE5E7EB),
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    if (children.isNotEmpty)
                      ...children
                          .expand(
                            (child) => [
                              child,
                              const SizedBox(height: 16),
                            ],
                          )
                          .take(children.length * 2 - 1),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
