import 'package:flutter/widgets.dart';
import 'package:unityspace/resources/theme/theme.dart';
import 'package:unityspace/utils/localization_helper.dart';

class EmptyNotificationsStub extends StatelessWidget {
  final bool isArchivePage;
  const EmptyNotificationsStub({
    required this.isArchivePage,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final localization = LocalizationHelper.getLocalizations(context);
    final width = MediaQuery.of(context).size.width;
    return SizedBox(
      width: width,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(
            left: 44,
            right: 44,
            top: 56,
            bottom: 44,
          ),
          child: Column(
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 600,
                ),
                child: Image.asset(
                  isArchivePage
                      ? 'assets/images/empty_archive.png'
                      : 'assets/images/relaxing_after_work.png',
                ),
              ),
              const SizedBox(
                height: 44,
              ),
              Text(
                isArchivePage
                    ? '${localization.your_archive_is_empty}!'
                    : '${localization.you_aware_all_the_work}!',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                  height: 23.44 / 20,
                  color: ColorConstants.grey01,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 16,
              ),
              Text(
                isArchivePage
                    ? localization.this_section_store_archive_notifications
                    : localization
                        .important_notifications_will_shown_in_this_section,
                style: const TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                  height: 18.75 / 16,
                  color: ColorConstants.grey04,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
